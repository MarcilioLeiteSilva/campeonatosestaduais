import PocketBase from 'pocketbase';
import axios from 'axios';
import dotenv from 'dotenv';
import admin from 'firebase-admin';
import { getMessaging } from 'firebase-admin/messaging';
import fs from 'fs';

dotenv.config();

let firebaseMessaging = null;
try {
  let serviceAccount = null;

  // Prioridade 1: variáveis individuais (mais robusta para Docker/EasyPanel)
  // Configure: FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY
  if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
    let privateKey = process.env.FIREBASE_PRIVATE_KEY.trim();
    // Decodificar Base64 se necessário
    if (!privateKey.startsWith('-----')) {
      privateKey = Buffer.from(privateKey, 'base64').toString('utf8');
    }
    // Normalizar quebras de linha
    privateKey = privateKey.replace(/\\n/g, '\n').replace(/\r/g, '');
    serviceAccount = {
      type: 'service_account',
      project_id: process.env.FIREBASE_PROJECT_ID,
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      private_key: privateKey,
    };
    console.log("Firebase: Credenciais carregadas das variáveis individuais (FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY).");

  // Prioridade 2: arquivo local service-account.json (para desenvolvimento local)
  } else if (fs.existsSync('./service-account.json')) {
    serviceAccount = JSON.parse(fs.readFileSync('./service-account.json', 'utf8'));
    console.log("Firebase: Credenciais carregadas do arquivo 'service-account.json'.");
  } else {
    console.warn("AVISO: Credenciais do Firebase não encontradas. Configure as variáveis FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL e FIREBASE_PRIVATE_KEY no EasyPanel. As notificações push não serão enviadas.");
  }

  if (serviceAccount) {
    admin.initializeApp({
      credential: admin.cert(serviceAccount)
    });
    firebaseMessaging = getMessaging();
    console.log("Firebase Admin SDK inicializado com sucesso para envio de notificações!");
  }
} catch (err) {
  console.error("Erro ao inicializar o Firebase Admin SDK:", err.message);
}

function formatTopic(name) {
  if (!name) return '';
  return name.toLowerCase()
             .replace(/[^\w\s]+/g, '')
             .replace(/ /g, '_');
}

async function sendPushNotification(topicName, title, body) {
  if (!firebaseMessaging) return;
  const sanitized = formatTopic(topicName);
  const topic = `time_${sanitized}`;
  const message = {
    notification: {
      title: title,
      body: body
    },
    topic: topic
  };

  try {
    await firebaseMessaging.send(message);
    console.log(`Notificação enviada para o tópico '${topic}': "${title} - ${body}"`);
  } catch (e) {
    console.error(`Erro ao enviar notificação para o tópico '${topic}':`, e.message);
  }
}

async function sendMatchPushNotification(matchId, title, body) {
  if (!firebaseMessaging) return;
  const topic = `match_${matchId}`;
  const message = {
    notification: {
      title: title,
      body: body
    },
    topic: topic
  };

  try {
    await firebaseMessaging.send(message);
    console.log(`Notificação enviada para o tópico da partida '${topic}': "${title} - ${body}"`);
  } catch (e) {
    console.error(`Erro ao enviar notificação para a partida '${topic}':`, e.message);
  }
}

const pbUrl = process.env.POCKETBASE_URL || 'http://127.0.0.1:8090';
const pbAdminEmail = process.env.POCKETBASE_ADMIN_EMAIL;
const pbAdminPassword = process.env.POCKETBASE_ADMIN_PASSWORD;
const zapscoreUrl = process.env.ZAPSCORE_API_URL || 'https://zapscore-zapscore-api.gtalg3.easypanel.host';

if (!pbAdminEmail || !pbAdminPassword) {
  console.error("ERRO: Variáveis POCKETBASE_ADMIN_EMAIL e POCKETBASE_ADMIN_PASSWORD são obrigatórias.");
  process.exit(1);
}

const pb = new PocketBase(pbUrl);

// Desativa o auto-cancellation do PocketBase JS SDK para scripts de backend de longa execução
pb.autoCancellation(false);

async function authenticate() {
  console.log(`Conectando ao PocketBase em: ${pbUrl}`);
  try {
    // Tenta primeiro o método do Pocketbase v0.23+ (Superusers)
    try {
      await pb.collection('_superusers').authWithPassword(pbAdminEmail, pbAdminPassword);
      console.log("Autenticado com sucesso como Superuser no PocketBase!");
    } catch (e) {
      // Se retornar 404, tenta o método de administração legado (v0.22 ou inferior)
      if (e.status === 404 || (e.message && e.message.includes('not found'))) {
        await pb.admins.authWithPassword(pbAdminEmail, pbAdminPassword);
        console.log("Autenticado com sucesso como Administrador (legado) no PocketBase!");
      } else {
        throw e;
      }
    }
  } catch (error) {
    console.error("Erro na autenticação do PocketBase:", error.message);
    throw error;
  }
}


/**
 * Garante que as coleções secundárias ou ausentes no schema inicial existam
 */
async function ensureCollectionsExist() {
  const collections = [
    {
      name: 'teams',
      type: 'base',
      schema: [
        { name: 'name', type: 'text', required: true },
        { name: 'logo', type: 'text' },
        { name: 'externalId', type: 'number', required: true, unique: true },
        { name: 'code', type: 'text' },
        { name: 'country', type: 'text' },
        { name: 'founded', type: 'number' },
        { name: 'national', type: 'bool' },
        { name: 'picked', type: 'bool' }
      ]
    },
    {
      name: 'news',
      type: 'base',
      schema: [
        { name: 'title', type: 'text', required: true },
        { name: 'category', type: 'text' },
        { name: 'image', type: 'text' },
        { name: 'date', type: 'text' },
        { name: 'body', type: 'text' }
      ]
    },
    {
      name: 'fixture_lineups',
      type: 'base',
      schema: [
        { name: 'fixtureId', type: 'text', required: true },
        { name: 'fixtureExternalId', type: 'number', required: true },
        { name: 'teamId', type: 'text', required: true },
        { name: 'formation', type: 'text' },
        { name: 'playerName', type: 'text', required: true },
        { name: 'playerNumber', type: 'number' },
        { name: 'playerPos', type: 'text' },
        { name: 'isSubstitute', type: 'bool' }
      ]
    },
    {
      name: 'fixture_statistics',
      type: 'base',
      schema: [
        { name: 'fixtureId', type: 'text', required: true },
        { name: 'fixtureExternalId', type: 'number', required: true },
        { name: 'teamId', type: 'text', required: true },
        { name: 'statType', type: 'text', required: true },
        { name: 'statValue', type: 'text', required: true }
      ]
    }
  ];

  for (const col of collections) {
    try {
      await pb.collections.getOne(col.name);
      console.log(`Coleção '${col.name}' já existe.`);
    } catch (e) {
      console.log(`Coleção '${col.name}' não encontrada. Criando...`);
      try {
        await pb.collections.create({
          name: col.name,
          type: col.type,
          schema: col.schema,
          listRule: "",
          viewRule: "",
          createRule: null,
          updateRule: null,
          deleteRule: null
        });
        console.log(`Coleção '${col.name}' criada com sucesso!`);
      } catch (err) {
        console.error(`Erro ao criar coleção '${col.name}':`, err.message);
      }
    }
  }
}

/**
 * Busca competições da ZapScore API e sincroniza
 */
async function syncCompetitions() {
  console.log("Sincronizando competições...");
  try {
    const response = await axios.get(`${zapscoreUrl}/competitions`);
    const competitions = response.data;

    // Filtramos apenas as ligas mineiras desejadas (629 - Módulo 1, 619 - Módulo 2)
    const targetIds = [629, 619];
    const mineiroCompetitions = competitions.filter(c => targetIds.includes(c.externalId));

    for (const comp of mineiroCompetitions) {
      let existingRecord = null;
      try {
        existingRecord = await pb.collection('competitions').getFirstListItem(`externalId = ${comp.externalId}`);
      } catch (e) {
        // Record não existe
      }

      const data = {
        externalId: comp.externalId,
        name: comp.name,
        country: comp.country || 'Brazil',
        logo: comp.logo || '',
        type: comp.type || 'league',
        activeSeasons: comp.activeSeasons || [2026]
      };

      if (existingRecord) {
        await pb.collection('competitions').update(existingRecord.id, data);
        console.log(`Competição '${comp.name}' atualizada.`);
      } else {
        await pb.collection('competitions').create(data);
        console.log(`Competição '${comp.name}' criada.`);
      }
    }
  } catch (error) {
    console.error("Erro na sincronização de competições:", error.message);
  }
}

/**
 * Busca times da ZapScore API de uma determinada liga e sincroniza no Pocketbase
 */
async function syncTeams(leagueId) {
  console.log(`Sincronizando times para a liga ${leagueId}...`);
  try {
    const response = await axios.get(`${zapscoreUrl}/teams?leagueId=${leagueId}`);
    const teams = response.data;

    for (const team of teams) {
      let existingRecord = null;
      try {
        existingRecord = await pb.collection('teams').getFirstListItem(`externalId = ${team.externalId}`);
      } catch (e) {
        // Record não existe
      }

      const data = {
        name: team.name,
        logo: team.logo || '',
        externalId: team.externalId,
        code: team.code || '',
        country: team.country || 'Brazil',
        founded: team.founded || null,
        national: team.national || false,
        picked: false // O usuário escolhe no app
      };

      if (existingRecord) {
        await pb.collection('teams').update(existingRecord.id, data);
      } else {
        await pb.collection('teams').create(data);
        console.log(`Time '${team.name}' criado.`);
      }
    }
  } catch (error) {
    console.error(`Erro ao sincronizar times da liga ${leagueId}:`, error.message);
  }
}

/**
 * Busca partidas (fixtures) da ZapScore API de uma determinada liga e sincroniza
 */
async function syncFixtures(leagueId, season = 2026) {
  console.log(`Sincronizando partidas da liga ${leagueId} (Temporada ${season})...`);
  try {
    const response = await axios.get(`${zapscoreUrl}/fixtures?leagueId=${leagueId}&season=${season}&limit=200`);
    const fixtures = response.data;

    // Cache de competições e times em memória para resolver relações
    const competitionsRecords = await pb.collection('competitions').getFullList();
    const teamsRecords = await pb.collection('teams').getFullList();

    for (const f of fixtures) {
      let existingRecord = null;
      try {
        existingRecord = await pb.collection('fixtures').getFirstListItem(`externalId = ${f.externalId}`);
      } catch (e) {
        // Record não existe
      }

      const competitionRecord = competitionsRecords.find(r => r.externalId === leagueId || r.externalId === f.leagueId);
      
      const extHomeId = f.homeTeam?.externalId || f.homeTeamId;
      const extAwayId = f.awayTeam?.externalId || f.awayTeamId;

      const homeRecord = teamsRecords.find(r => r.externalId === extHomeId);
      const awayRecord = teamsRecords.find(r => r.externalId === extAwayId);

      if (!competitionRecord) {
        console.log(`Aviso: Competição com externalId = ${leagueId} não encontrada no Pocketbase. Pulando partida.`);
        continue;
      }

      if (!homeRecord || !awayRecord) {
        console.log(`Aviso: Times [Home: ${extHomeId}, Away: ${extAwayId}] não encontrados no Pocketbase. Pulando partida.`);
        continue;
      }

      const data = {
        externalId: f.externalId,
        leagueId: competitionRecord.id, // ID da relação no Pocketbase
        season: f.season || season,
        date: f.date,
        round: f.round || '',
        statusLong: f.statusLong || '',
        statusShort: f.statusShort || '',
        elapsed: f.elapsed !== null ? f.elapsed : null,
        venueName: f.venueName || '',
        venueCity: f.venueCity || '',
        homeTeamId: homeRecord.id, // ID da relação no Pocketbase
        awayTeamId: awayRecord.id, // ID da relação no Pocketbase
        homeGoals: f.homeGoals !== null ? f.homeGoals : null,
        awayGoals: f.awayGoals !== null ? f.awayGoals : null,
        oddsHome: f.oddsHome !== null ? f.oddsHome : null,
        oddsDraw: f.oddsDraw !== null ? f.oddsDraw : null,
        oddsAway: f.oddsAway !== null ? f.oddsAway : null
      };

      let pbFixtureId = null;

      try {
        if (existingRecord) {
          // Detectar alterações para notificações
          const oldStatus = existingRecord.statusShort;
          const newStatus = f.statusShort || '';

          const oldHomeGoals = existingRecord.homeGoals;
          const newHomeGoals = f.homeGoals !== null ? f.homeGoals : null;
          const oldAwayGoals = existingRecord.awayGoals;
          const newAwayGoals = f.awayGoals !== null ? f.awayGoals : null;

          // 1. Detectar Início de Jogo (NS -> 1H ou similar)
          if ((oldStatus === 'NS' || oldStatus === '') && (newStatus === '1H' || newStatus === 'LIVE' || f.elapsed > 0)) {
            const title = `⏱️ JOGO INICIADO!`;
            const body = `${homeRecord.name} vs ${awayRecord.name} começou no campeonato!`;
            await sendPushNotification(homeRecord.name, title, body);
            await sendPushNotification(awayRecord.name, title, body);
            await sendMatchPushNotification(f.externalId, title, body);
          }

          // 2. Detectar Fim de Jogo (Não era encerrado, e agora é: FT ou PEN ou AET)
          const isOldFinished = oldStatus === 'FT' || oldStatus === 'PEN' || oldStatus === 'AET';
          const isNewFinished = newStatus === 'FT' || newStatus === 'PEN' || newStatus === 'AET';
          if (!isOldFinished && isNewFinished) {
            const title = `🏁 FIM DE JOGO!`;
            const body = `${homeRecord.name} ${newHomeGoals !== null ? newHomeGoals : 0} x ${newAwayGoals !== null ? newAwayGoals : 0} ${awayRecord.name} (Fim da partida)`;
            await sendPushNotification(homeRecord.name, title, body);
            await sendPushNotification(awayRecord.name, title, body);
            await sendMatchPushNotification(f.externalId, title, body);
          }

          // 3. Detectar Alteração de Placar (Gols)
          if (newHomeGoals !== null && oldHomeGoals !== null && newHomeGoals > oldHomeGoals) {
            const title = `⚽ GOL DO ${homeRecord.name.toUpperCase()}!`;
            const body = `Placar: ${homeRecord.name} ${newHomeGoals} x ${newAwayGoals !== null ? newAwayGoals : 0} ${awayRecord.name}`;
            await sendPushNotification(homeRecord.name, title, body);
            await sendPushNotification(awayRecord.name, title, body);
            await sendMatchPushNotification(f.externalId, title, body);
          }
          if (newAwayGoals !== null && oldAwayGoals !== null && newAwayGoals > oldAwayGoals) {
            const title = `⚽ GOL DO ${awayRecord.name.toUpperCase()}!`;
            const body = `Placar: ${homeRecord.name} ${newHomeGoals !== null ? newHomeGoals : 0} x ${newAwayGoals} ${awayRecord.name}`;
            await sendPushNotification(homeRecord.name, title, body);
            await sendPushNotification(awayRecord.name, title, body);
            await sendMatchPushNotification(f.externalId, title, body);
          }

          const updated = await pb.collection('fixtures').update(existingRecord.id, data);
          pbFixtureId = updated.id;
        } else {
          const created = await pb.collection('fixtures').create(data);
          pbFixtureId = created.id;
          console.log(`Partida [${homeRecord.name} vs ${awayRecord.name}] criada.`);
        }
      } catch (err) {
        console.error(`Erro ao salvar partida ID=${f.externalId}:`, err.message, JSON.stringify(err.data));
        continue;
      }

      // Buscar e sincronizar eventos da partida via endpoint separado
      if (pbFixtureId) {
        try {
          await delay(400);
          const eventsRes = await requestWithRetry(`${zapscoreUrl}/fixtures/events?fixtureId=${f.externalId}`);
          const events = eventsRes?.data;
          if (events && Array.isArray(events) && events.length > 0) {
            await syncFixtureEvents(pbFixtureId, events, extHomeId, extAwayId);
          }
        } catch (evErr) {
          console.error(`Erro ao buscar eventos da partida ${f.externalId}:`, evErr.message);
        }
      }

      // Sincronizar escalações e estatísticas reais da ZapScore
      if (pbFixtureId) {
        await syncFixtureLineups(pbFixtureId, f.externalId);
        await syncFixtureStatistics(pbFixtureId, f.externalId);
      }
    }
  } catch (error) {
    console.error(`Erro ao sincronizar partidas da liga ${leagueId}:`, error.message);
  }
}


/**
 * Sincroniza eventos de uma partida
 */
async function syncFixtureEvents(pbFixtureId, events, homeId, awayId) {
  for (const e of events) {
    let existingRecord = null;
    try {
      // Como eventos não têm ID externo único na API de forma simples,
      // podemos usar uma chave composta ou limpar e reinserir para evitar duplicados
      existingRecord = await pb.collection('fixture_events').getFirstListItem(
        `fixtureId = '${pbFixtureId}' && time = ${e.time?.elapsed || 0} && player = '${e.player?.name || ''}' && type = '${e.type || ''}'`
      );
    } catch (err) {
      // Record não existe
    }

    const data = {
      fixtureId: pbFixtureId,
      time: e.time?.elapsed || 0,
      teamId: e.team?.id || (e.team?.name === 'home' ? homeId : awayId),
      player: e.player?.name || '',
      assist: e.assist?.name || '',
      type: e.type || '',
      detail: e.detail || '',
      playerPhoto: '',
      externalPlayerId: e.player?.id || null
    };

    if (!existingRecord) {
      await pb.collection('fixture_events').create(data);

      // Enviar notificações para novos eventos (Substituições e Cartões Vermelhos)
      try {
        const fixture = await pb.collection('fixtures').getOne(pbFixtureId, { expand: 'homeTeamId,awayTeamId' });
        const homeName = fixture.expand.homeTeamId.name;
        const awayName = fixture.expand.awayTeamId.name;
        const eventTeamName = e.team?.name === 'home' || e.team?.id === homeId ? homeName : awayName;

        const minutes = e.time?.elapsed || 0;
        const player = e.player?.name || '';
        const assist = e.assist?.name || '';

        // 1. Substituição (subst)
        if (e.type === 'subst' || e.type?.toLowerCase() === 'subst') {
          const title = `🔄 Substituição no ${eventTeamName}`;
          const body = `(${minutes}') Sai: ${assist || 'Jogador'}, Entra: ${player}`;
          await sendPushNotification(homeName, title, body);
          await sendPushNotification(awayName, title, body);
          await sendMatchPushNotification(fixture.externalId, title, body);
        }

        // 2. Cartão Vermelho (Red Card)
        if ((e.type === 'Card' || e.type?.toLowerCase() === 'card') && 
            (e.detail?.toLowerCase().includes('red') || e.detail?.toLowerCase() === 'red card')) {
          const title = `🟥 CARTÃO VERMELHO!`;
          const body = `(${minutes}') ${player} do ${eventTeamName} foi expulso do jogo!`;
          await sendPushNotification(homeName, title, body);
          await sendPushNotification(awayName, title, body);
          await sendMatchPushNotification(fixture.externalId, title, body);
        }
      } catch (err) {
        console.error("Erro ao despachar notificação para evento de jogo:", err.message);
      }
    }
  }
}

/**
 * Aguarda o tempo especificado em milissegundos
 */
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Faz uma requisição GET com retry automático em caso de 429 (rate limit)
 */
async function requestWithRetry(url, retries = 3, backoff = 2000) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await axios.get(url);
      return response;
    } catch (error) {
      if (error.response?.status === 429 && i < retries - 1) {
        const waitTime = backoff * (i + 1);
        console.log(`Rate limit atingido. Aguardando ${waitTime}ms antes de tentar novamente...`);
        await delay(waitTime);
      } else {
        throw error;
      }
    }
  }
}

async function syncFixtureLineups(pbFixtureId, fixtureExternalId) {
  try {
    await delay(1500); // Respeitar rate limit da ZapScore API
    const response = await requestWithRetry(`${zapscoreUrl}/fixtures/lineups?fixtureId=${fixtureExternalId}`);
    const lineups = response?.data;
    if (!lineups || lineups === "" || !Array.isArray(lineups)) return;

    // Remove lineups antigas para evitar duplicidade
    try {
      const oldLineups = await pb.collection('fixture_lineups').getFullList({
        filter: `fixtureId = '${pbFixtureId}'`
      });
      for (const old of oldLineups) {
        await pb.collection('fixture_lineups').delete(old.id);
      }
    } catch (e) {}

    for (const lineup of lineups) {
      const teamType = lineup.team?.name === 'home' || lineup.team?.id === lineup.teamId ? 'home' : 'away';
      const formation = lineup.formation || '';

      if (lineup.startXI && Array.isArray(lineup.startXI)) {
        for (const item of lineup.startXI) {
          const p = item.player;
          if (p) {
            await pb.collection('fixture_lineups').create({
              fixtureId: pbFixtureId,
              fixtureExternalId: fixtureExternalId,
              teamId: teamType,
              formation: formation,
              playerName: p.name || '',
              playerNumber: p.number || null,
              playerPos: p.pos || '',
              isSubstitute: false
            });
          }
        }
      }

      if (lineup.substitutes && Array.isArray(lineup.substitutes)) {
        for (const item of lineup.substitutes) {
          const p = item.player;
          if (p) {
            await pb.collection('fixture_lineups').create({
              fixtureId: pbFixtureId,
              fixtureExternalId: fixtureExternalId,
              teamId: teamType,
              formation: formation,
              playerName: p.name || '',
              playerNumber: p.number || null,
              playerPos: p.pos || '',
              isSubstitute: true
            });
          }
        }
      }
    }
  } catch (error) {
    console.error(`Erro ao sincronizar lineups da partida ${fixtureExternalId}:`, error.message);
  }
}

/**
 * Sincroniza estatísticas de uma partida
 */
async function syncFixtureStatistics(pbFixtureId, fixtureExternalId) {
  try {
    await delay(1500); // Respeitar rate limit da ZapScore API
    const response = await requestWithRetry(`${zapscoreUrl}/fixtures/statistics?fixtureId=${fixtureExternalId}`);
    const statsData = response?.data;
    if (!statsData || statsData === "" || !Array.isArray(statsData)) return;

    // Remove estatísticas antigas para evitar duplicidade
    try {
      const oldStats = await pb.collection('fixture_statistics').getFullList({
        filter: `fixtureId = '${pbFixtureId}'`
      });
      for (const old of oldStats) {
        await pb.collection('fixture_statistics').delete(old.id);
      }
    } catch (e) {}

    for (const item of statsData) {
      const teamType = item.team?.name === 'home' || item.team?.id === item.teamId ? 'home' : 'away';

      if (item.statistics && Array.isArray(item.statistics)) {
        for (const stat of item.statistics) {
          await pb.collection('fixture_statistics').create({
            fixtureId: pbFixtureId,
            fixtureExternalId: fixtureExternalId,
            teamId: teamType,
            statType: stat.type || '',
            statValue: stat.value !== null ? String(stat.value) : ''
          });
        }
      }
    }
  } catch (error) {
    console.error(`Erro ao sincronizar statistics da partida ${fixtureExternalId}:`, error.message);
  }
}


/**
 * Função principal de execução periódica
 */
async function startSync() {
  try {
    await authenticate();
    await ensureCollectionsExist();

    // Sincroniza ligas
    await syncCompetitions();

    // Sincroniza times e fixtures das ligas 629 (Módulo 1) e 619 (Módulo 2)
    const ligas = [629, 619];
    for (const id of ligas) {
      await syncTeams(id);
      await syncFixtures(id, 2026);
    }

    console.log("Sincronização concluída com sucesso!");
  } catch (error) {
    console.error("Falha geral no processo de sincronização:", error.message);
  }
}

// Execução inicial
startSync();

// Executa periodicamente a cada 10 minutos
const SYNC_INTERVAL = 10 * 60 * 1000;
setInterval(() => {
  console.log("Iniciando ciclo de sincronização agendado...");
  startSync();
}, SYNC_INTERVAL);
