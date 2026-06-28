import PocketBase from 'pocketbase';
import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

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
    const response = await axios.get(`${zapscoreUrl}/fixtures?leagueId=${leagueId}&season=${season}`);
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

      // Sincronizar eventos se houver dados
      if (f.events && f.events.length > 0 && pbFixtureId) {
        await syncFixtureEvents(pbFixtureId, f.events, extHomeId, extAwayId);
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
    }
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
