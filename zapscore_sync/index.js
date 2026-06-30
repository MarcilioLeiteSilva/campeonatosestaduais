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

async function sendPushNotification(topicName, subTopic, title, body) {
  if (!firebaseMessaging) return;
  const sanitized = formatTopic(topicName);
  const topic = `time_${sanitized}_${subTopic}`;
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

async function sendMatchPushNotification(matchId, subTopic, title, body) {
  if (!firebaseMessaging) return;
  const topic = `match_${matchId}_${subTopic}`;
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
async function syncFixtures(leagueId, season = 2026, isLiveWindow = false) {
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

          // Notificações apenas durante janela de jogo ao vivo
          if (isLiveWindow) {
            // 1. Detectar Início de Jogo (NS -> 1H ou similar)
            if ((oldStatus === 'NS' || oldStatus === '') && (newStatus === '1H' || newStatus === 'LIVE' || f.elapsed > 0)) {
              const title = `⏱️ JOGO INICIADO!`;
              const body = `${homeRecord.name} vs ${awayRecord.name} começou no campeonato!`;
              await sendPushNotification(homeRecord.name, 'placar', title, body);
              await sendPushNotification(awayRecord.name, 'placar', title, body);
              await sendMatchPushNotification(f.externalId, 'placar', title, body);
            }

            // 2. Detectar Fim de Jogo (Não era encerrado, e agora é: FT ou PEN ou AET)
            const isOldFinished = oldStatus === 'FT' || oldStatus === 'PEN' || oldStatus === 'AET';
            const isNewFinished = newStatus === 'FT' || newStatus === 'PEN' || newStatus === 'AET';
            if (!isOldFinished && isNewFinished) {
              const title = `🏁 FIM DE JOGO!`;
              const body = `${homeRecord.name} ${newHomeGoals !== null ? newHomeGoals : 0} x ${newAwayGoals !== null ? newAwayGoals : 0} ${awayRecord.name} (Fim da partida)`;
              await sendPushNotification(homeRecord.name, 'placar', title, body);
              await sendPushNotification(awayRecord.name, 'placar', title, body);
              await sendMatchPushNotification(f.externalId, 'placar', title, body);
            }

            // 3. Detectar Alteração de Placar (Gols)
            if (newHomeGoals !== null && oldHomeGoals !== null && newHomeGoals > oldHomeGoals) {
              const title = `⚽ GOL DO ${homeRecord.name.toUpperCase()}!`;
              const body = `Placar: ${homeRecord.name} ${newHomeGoals} x ${newAwayGoals !== null ? newAwayGoals : 0} ${awayRecord.name}`;
              await sendPushNotification(homeRecord.name, 'gols', title, body);
              await sendPushNotification(awayRecord.name, 'gols', title, body);
              await sendMatchPushNotification(f.externalId, 'gols', title, body);
            }
            if (newAwayGoals !== null && oldAwayGoals !== null && newAwayGoals > oldAwayGoals) {
              const title = `⚽ GOL DO ${awayRecord.name.toUpperCase()}!`;
              const body = `Placar: ${homeRecord.name} ${newHomeGoals !== null ? newHomeGoals : 0} x ${newAwayGoals} ${awayRecord.name}`;
              await sendPushNotification(homeRecord.name, 'gols', title, body);
              await sendPushNotification(awayRecord.name, 'gols', title, body);
              await sendMatchPushNotification(f.externalId, 'gols', title, body);
            }
          } else {
            // Fora da janela ao vivo: apenas atualiza status sem notificar
            const isOldFinished = oldStatus === 'FT' || oldStatus === 'PEN' || oldStatus === 'AET';
            const isNewFinished = newStatus === 'FT' || newStatus === 'PEN' || newStatus === 'AET';
            void isOldFinished; void isNewFinished; // suprime warning de lint
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

      // Buscar eventos apenas para partidas finalizadas/ao vivo E que ainda não têm eventos no PocketBase
      // E apenas se a partida for recente (iniciada a menos de 24 horas) para evitar 429 com jogos passados
      const statusQueTemEventos = ['FT', 'AET', 'PEN', '1H', 'HT', '2H', 'ET', 'BT', 'LIVE'];
      const statusAtual = f.statusShort || '';
      const isLive = ['1H', 'HT', '2H', 'ET', 'BT', 'LIVE'].includes(statusAtual);
      const isFinished = ['FT', 'AET', 'PEN'].includes(statusAtual);

      // Calcular diferença em horas
      const matchDate = new Date(f.date);
      const now = new Date();
      const diffMs = now - matchDate;
      const diffHours = diffMs / (1000 * 60 * 60);
      const isRecentOrLive = diffHours < 24 && diffHours > -2; // iniciou de 2h no futuro a 24h no passado

      if (pbFixtureId && statusQueTemEventos.includes(statusAtual) && isRecentOrLive) {
        try {
          // Para partidas já finalizadas, verificar se já existem eventos no banco antes de chamar a API
          if (isFinished) {
            const existingEvents = await pb.collection('fixture_events').getList(1, 1, {
              filter: `fixtureId = '${pbFixtureId}'`
            });
            if (existingEvents.totalItems > 0) {
              // Já tem eventos, pular busca na API (economiza rate limit)
              continue;
            }
          }

          await delay(1000);
          const eventsRes = await requestWithRetry(`${zapscoreUrl}/fixtures/events?fixtureId=${f.externalId}`);
          const events = eventsRes?.data;
          if (events && Array.isArray(events) && events.length > 0) {
            await syncFixtureEvents(pbFixtureId, events, extHomeId, extAwayId, isLiveWindow);
            console.log(`Eventos sincronizados para partida ${f.externalId}: ${events.length} eventos.`);
          }
        } catch (evErr) {
          console.error(`Erro ao buscar eventos da partida ${f.externalId}:`, evErr.message);
        }
      }

      // Verificar e notificar escalação confirmada (somente durante janela ao vivo)
      if (isLiveWindow && pbFixtureId) {
        await checkAndNotifyLineups(
          pbFixtureId,
          f.externalId,
          homeRecord.name,
          awayRecord.name,
          f.statusShort || ''
        );
      }
      // Nota: lineups e statistics podem não estar disponíveis pela ZapScore para o Campeonato Mineiro
    }
  } catch (error) {
    console.error(`Erro ao sincronizar partidas da liga ${leagueId}:`, error.message);
  }
}


/**
 * Sincroniza eventos de uma partida
 */
async function syncFixtureEvents(pbFixtureId, events, homeId, awayId, isLiveWindow = false) {
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

      // Enviar notificações apenas durante janela ao vivo
      if (isLiveWindow) {
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
            await sendPushNotification(homeName, 'substituicoes', title, body);
            await sendPushNotification(awayName, 'substituicoes', title, body);
            await sendMatchPushNotification(fixture.externalId, 'substituicoes', title, body);
          }

          // 2. Cartão Vermelho (Red Card)
          if ((e.type === 'Card' || e.type?.toLowerCase() === 'card') &&
              (e.detail?.toLowerCase().includes('red') || e.detail?.toLowerCase() === 'red card')) {
            const title = `🟥 CARTÃO VERMELHO!`;
            const body = `(${minutes}') ${player} do ${eventTeamName} foi expulso do jogo!`;
            await sendPushNotification(homeName, 'cartoes', title, body);
            await sendPushNotification(awayName, 'cartoes', title, body);
            await sendMatchPushNotification(fixture.externalId, 'cartoes', title, body);
          }
        } catch (err) {
          console.error('Erro ao despachar notificação para evento de jogo:', err.message);
        }
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


// ─────────────────────────────────────────────────────────────────────────────
// CONTROLE DE ESTADO GLOBAL DO CICLO
// ─────────────────────────────────────────────────────────────────────────────

/** Timestamp da última sincronização de dados estáticos (competições e times) */
let lastStaticSyncAt = null;

/** Intervalo mínimo para dados estáticos: 24 horas */
const STATIC_SYNC_INTERVAL_MS = 24 * 60 * 60 * 1000;

/** Janela de ativação antes do jogo (em minutos) */
const PRE_MATCH_WINDOW_MIN = 30;

/** Janela de ativação após o jogo (em minutos) */
const POST_MATCH_WINDOW_MIN = 30;

/** Intervalo de sincronização durante janela ao vivo: 1 minuto */
const LIVE_INTERVAL_MS = 1 * 60 * 1000;

/** Intervalo de sincronização fora de janela ao vivo: 1 hora */
const IDLE_INTERVAL_MS = 60 * 60 * 1000;

// ─────────────────────────────────────────────────────────────────────────────
// DETECÇÃO DA JANELA DE JOGO AO VIVO
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Consulta o PocketBase para verificar se existe partida ativa, prestes a começar
 * ou recentemente encerrada (dentro das janelas PRÉ/PÓS-jogo configuradas).
 * Retorna { isLive: bool, reason: string }
 */
async function detectLiveWindow() {
  try {
    const now = new Date();
    const allFixtures = await pb.collection('fixtures').getFullList({
      filter: `season = 2026`,
      fields: 'id,statusShort,date,elapsed',
    });

    for (const f of allFixtures) {
      const status = f.statusShort || '';
      const matchDate = f.date ? new Date(f.date) : null;

      // Partida em andamento agora
      const isLiveStatus = ['1H', 'HT', '2H', 'ET', 'BT', 'P', 'LIVE'].includes(status);
      if (isLiveStatus) {
        return { isLive: true, reason: `Partida ao vivo (status=${status})` };
      }

      if (matchDate) {
        const diffMin = (now - matchDate) / 60000;

        // Partida prestes a começar (dentro da janela PRÉ-jogo)
        if (status === 'NS' && diffMin >= -PRE_MATCH_WINDOW_MIN && diffMin <= 0) {
          return { isLive: true, reason: `Partida começa em ${Math.round(-diffMin)} min` };
        }

        // Partida recém-encerrada (dentro da janela PÓS-jogo)
        const isFinishedStatus = ['FT', 'AET', 'PEN'].includes(status);
        if (isFinishedStatus && diffMin >= 0 && diffMin <= (90 + POST_MATCH_WINDOW_MIN)) {
          return { isLive: true, reason: `Partida encerrada há ~${Math.round(diffMin - 90)} min (janela pós-jogo)` };
        }
      }
    }

    return { isLive: false, reason: 'Sem janela de jogo ativa' };
  } catch (e) {
    console.warn('Erro ao detectar janela de jogo ao vivo:', e.message);
    return { isLive: false, reason: 'Erro na detecção (fallback IDLE)' };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTROLE DE NOTIFICAÇÃO DE ESCALAÇÃO
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Verifica se as escalações de uma partida acabaram de ser disponibilizadas
 * e, se sim, envia notificação push para os torcedores dos dois times.
 * O PocketBase já deve ter os dados de lineup atualizados antes de chamar isso.
 */
async function checkAndNotifyLineups(pbFixtureId, fixtureExternalId, homeTeamName, awayTeamName, statusShort) {
  try {
    // Só notifica se a partida ainda não começou ou está na janela pré-jogo
    const activeStatuses = ['NS', '1H', 'HT'];
    if (!activeStatuses.includes(statusShort)) return;

    const lineups = await pb.collection('fixture_lineups').getList(1, 1, {
      filter: `fixtureId = '${pbFixtureId}'`,
    });

    if (lineups.totalItems === 0) return; // Sem escalação ainda

    // Verifica se já enviamos notificação (usando um campo de controle ou checando quantidade mínima)
    // Estratégia: verificar se há pelo menos 11 jogadores de um time (escalação completa)
    const allLineups = await pb.collection('fixture_lineups').getFullList({
      filter: `fixtureId = '${pbFixtureId}' && isSubstitute = false`,
    });

    if (allLineups.length < 11) return; // Escalação incompleta, aguardar

    // Verifica se a notificação já foi enviada (usando campo sentLineupNotif na fixture)
    const fixture = await pb.collection('fixtures').getOne(pbFixtureId, { fields: 'id,sentLineupNotif' });
    if (fixture.sentLineupNotif) return; // Já enviada anteriormente

    // Envia a notificação para ambos os times
    const title = `📋 Escalação Confirmada!`;
    const body = `A escalação de ${homeTeamName} vs ${awayTeamName} está definida! Confira quem vai a campo.`;

    await sendPushNotification(homeTeamName, 'placar', title, body);
    await sendPushNotification(awayTeamName, 'placar', title, body);
    await sendMatchPushNotification(fixtureExternalId, 'placar', title, body);

    // Marca que a notificação de escalação foi enviada
    await pb.collection('fixtures').update(pbFixtureId, { sentLineupNotif: true });

    console.log(`📋 Notificação de escalação enviada para partida ${fixtureExternalId}.`);
  } catch (e) {
    // sentLineupNotif pode não existir ainda na coleção — ignorar silenciosamente
    if (!e.message?.includes('sentLineupNotif')) {
      console.warn(`Erro ao verificar/notificar escalação da partida ${fixtureExternalId}:`, e.message);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CICLO PRINCIPAL DE SINCRONIZAÇÃO
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Sincroniza dados estáticos (competições e times) apenas se passaram 24h.
 */
async function syncStaticDataIfNeeded() {
  const now = Date.now();
  if (lastStaticSyncAt && (now - lastStaticSyncAt) < STATIC_SYNC_INTERVAL_MS) {
    console.log('Dados estáticos (competições/times): já atualizados hoje, pulando.');
    return;
  }

  console.log('Sincronizando dados estáticos (competições e times)...');
  await syncCompetitions();
  const ligas = [629, 619];
  for (const id of ligas) {
    await syncTeams(id);
  }

  lastStaticSyncAt = now;
  console.log('Dados estáticos sincronizados e cache renovado por 24h.');
}

/**
 * Sincroniza partidas e eventos dinâmicos das ligas ativas.
 * As notificações de eventos são disparadas APENAS durante a janela ao vivo.
 */
async function syncDynamicData(isLiveWindow) {
  const ligas = [629, 619];
  for (const id of ligas) {
    await syncFixtures(id, 2026, isLiveWindow);
  }
}

/**
 * Função principal de um ciclo completo de sincronização.
 * @param {boolean} isLiveWindow - Se verdadeiro, notificações de eventos são enviadas.
 */
async function runSyncCycle(isLiveWindow) {
  try {
    console.log(`\n═══════════════════════════════════════════════`);
    console.log(`🔄 Ciclo de sincronização [${isLiveWindow ? '⚡ AO VIVO' : '💤 NORMAL'}]`);
    console.log(`═══════════════════════════════════════════════`);

    await authenticate();
    await ensureCollectionsExist();

    // Dados estáticos: somente 1x por dia
    await syncStaticDataIfNeeded();

    // Dados dinâmicos: sempre, passando flag de janela ao vivo para controle de notificações
    await syncDynamicData(isLiveWindow);

    console.log('✅ Ciclo de sincronização concluído com sucesso!\n');
  } catch (error) {
    console.error('❌ Falha geral no ciclo de sincronização:', error.message);
  }
}

/**
 * Loop adaptativo: determina o intervalo do próximo ciclo baseado na
 * detecção de jogos ao vivo e agenda o próximo setTimeout automaticamente.
 */
async function scheduledLoop() {
  // Detecta se estamos dentro de uma janela de jogo
  const { isLive, reason } = await detectLiveWindow();

  // Executa o ciclo de sincronização
  await runSyncCycle(isLive);

  // Re-detecta após o ciclo (o status pode ter mudado durante a execução)
  const { isLive: isLiveAfter, reason: reasonAfter } = await detectLiveWindow();

  const nextInterval = isLiveAfter ? LIVE_INTERVAL_MS : IDLE_INTERVAL_MS;
  const nextLabel = isLiveAfter ? '1 minuto ⚡' : '1 hora 💤';

  console.log(`⏱  Próximo ciclo em ${nextLabel} — Motivo: ${reasonAfter}`);
  setTimeout(scheduledLoop, nextInterval);
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRADA DO SCRIPT
// ─────────────────────────────────────────────────────────────────────────────

// Inicialização: executa imediatamente, depois o loop auto-agenda
console.log('🚀 Iniciando zapscore_sync com agendamento dinâmico...');
scheduledLoop();

