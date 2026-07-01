/**
 * backfill_comments.js
 * Processa retroativamente todas as partidas finalizadas do Módulo 1 e 2 
 * utilizando ge.globo, Placar de Futebol e ESPN para preencher lances,
 * eventos e placares consolidados.
 * 
 * Execute com: node backfill_comments.js
 */

import PocketBase from 'pocketbase';
import axios from 'axios';
import vm from 'vm';
import dotenv from 'dotenv';
import { 
  normalizeTeamName, 
  formatDateDMY, 
  fetchPlacarMatchData, 
  fetchEspnMatchData, 
  mergeFixtureInfo, 
  mergeFixtureEvents 
} from './helpers.js';

dotenv.config();

const pb = new PocketBase(process.env.POCKETBASE_URL);

const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

const extractMinute = (momentStr) => {
  if (!momentStr) return null;
  if (momentStr.includes(':')) {
    const parts = momentStr.split(':');
    const min = parseInt(parts[0], 10);
    return isNaN(min) ? null : `${min}'`;
  }
  if (momentStr.includes("'")) return momentStr;
  const min = parseInt(momentStr, 10);
  return isNaN(min) ? null : `${min}'`;
};

// ── URL BUILDER (ge.globo) ───────────────────────────────────────────────────
const TEAM_SLUG_MAP = {
  'Atlético Mineiro': 'atletico-mg',
  'Atletico Mineiro': 'atletico-mg',
  'Cruzeiro': 'cruzeiro',
  'América-MG': 'america-mg',
  'America-MG': 'america-mg',
  'América MG': 'america-mg',
  'America MG': 'america-mg',
  'Tombense': 'tombense',
  'Pouso Alegre': 'pouso-alegre',
  'Patrocinense': 'patrocinense',
  'Uberlândia': 'uberlandia',
  'Uberlandia': 'uberlandia',
  'Villa Nova': 'villa-nova',
  'Caldense': 'caldense',
  'Democrata GV': 'democrata-gv',
  'Democrata SL': 'democrata-sl',
  'Ipatinga': 'ipatinga',
  'Aymorés': 'aymores',
  'Aymores': 'aymores',
  'Guarani MG': 'guarani-mg',
  'BOA Esporte': 'boa-esporte',
  'BOA': 'boa-esporte',
  'Mamoré': 'mamore',
  'Mamore': 'mamore',
  'Coimbra': 'coimbra',
  'Valeriodoce': 'valeriodoce',
  'Valério': 'valeriodoce',
  'CAP': 'pouso-alegre',
  'Uberaba': 'uberaba',
};

function toSlug(name) {
  if (!name) return '';
  const normalized = name.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
  return normalized.replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function getTeamSlug(name) {
  if (TEAM_SLUG_MAP[name]) return TEAM_SLUG_MAP[name];
  return toSlug(name);
}

async function findGloboUrl(homeTeamName, awayTeamName, dateStr) {
  const homeSlug = getTeamSlug(homeTeamName);
  const awaySlug = getTeamSlug(awayTeamName);
  const d = new Date(dateStr);
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  const formattedDate = `${day}-${month}-${year}`;

  const baseUrls = [
    'https://ge.globo.com/mg/futebol/campeonato-mineiro/',
    'https://ge.globo.com/mg/futebol/campeonato-mineiro-modulo-2/',
  ];

  const headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Accept': 'text/html,application/xhtml+xml'
  };

  for (const baseUrl of baseUrls) {
    try {
      const resp = await axios.get(baseUrl, { headers, timeout: 10000 });
      const html = resp.data;
      const linkRegex = /href="([^"]*\/jogo\/[^"]*)"/gi;
      let match;
      while ((match = linkRegex.exec(html)) !== null) {
        const href = match[1];
        if (href.includes(homeSlug) || href.includes(awaySlug)) {
          const url = href.startsWith('http') ? href : `https://ge.globo.com${href}`;
          return url;
        }
      }
    } catch (e) {}
  }
  
  // Fallback: URL direta
  for (const basePath of [
    'https://ge.globo.com/mg/futebol/campeonato-mineiro/jogo',
    'https://ge.globo.com/mg/futebol/campeonato-mineiro-modulo-2/jogo',
  ]) {
    const url = `${basePath}/${formattedDate}/${homeSlug}-${awaySlug}.ghtml`;
    try {
      const resp = await axios.get(url, { headers, timeout: 8000 });
      if (resp.status === 200 && resp.data.includes('window.trv2')) {
        return url;
      }
    } catch (e) {}
  }
  
  return null;
}

// ── COMMENT SCRAPER (ge.globo) ───────────────────────────────────────────────
async function scrapeAndSaveComments(pbFixtureId, globoUrl) {
  const response = await axios.get(globoUrl, {
    headers: { 'User-Agent': 'Mozilla/5.0' },
    timeout: 12000
  });

  const html = response.data;
  const scriptRegex = /<script\b[^>]*>([\s\S]*?)<\/script>/gi;
  let match;
  let trv2Script = null;
  while ((match = scriptRegex.exec(html)) !== null) {
    if (match[1].includes('window.trv2')) {
      trv2Script = match[1];
      break;
    }
  }

  if (!trv2Script) return [];

  const sandbox = { window: {} };
  sandbox.window.window = sandbox.window;
  vm.createContext(sandbox);
  vm.runInContext(trv2Script, sandbox);

  const trv2 = sandbox.window.trv2;
  if (!trv2 || !trv2.plays) return [];

  const plays = Array.isArray(trv2.plays) ? trv2.plays : Object.values(trv2.plays);
  const events = [];

  for (const play of plays) {
    if (!play) continue;

    const timeStr = extractMinute(play.moment);
    if (!timeStr) continue;

    let commentText = '';
    if (play.body && Array.isArray(play.body.blocks)) {
      commentText = play.body.blocks.map(b => b.text || '').join('\n').trim();
    }
    if (!commentText && play.description) commentText = play.description.trim();
    if (!commentText && play.title) commentText = play.title.trim();
    
    if (commentText) {
      // Verifica duplicata de comentário local antes de salvar
      const existing = await pb.collection('fixture_comments').getFullList({
        filter: `fixtureId = '${pbFixtureId}' && time = '${timeStr}'`
      });
      if (!existing.find(e => e.text === commentText)) {
        await pb.collection('fixture_comments').create({
          fixtureId: pbFixtureId,
          time: timeStr,
          period: play.period?.abbreviation || play.period?.label || '',
          text: commentText,
          type: play.type || 'text',
        });
      }
    }

    // Capture event if it is a goal/card/sub
    const allowedTypes = ['gol', 'card', 'subst', 'substituicao', 'cartao'];
    if (play.type && allowedTypes.includes(play.type.toLowerCase())) {
      events.push({
        time: parseInt(timeStr.replace(/\D/g, ''), 10) || 0,
        teamSide: play.team?.type === 'away' || play.team?.name === 'away' ? 'away' : 'home',
        player: play.player?.name || play.playerIn?.name || '',
        type: play.type.toLowerCase(),
        detail: play.cardType || ''
      });
    }
  }

  return events;
}

// ── MAIN ──────────────────────────────────────────────────────────────────────
async function run() {
  console.log('🔐 Autenticando no PocketBase...');
  await pb.collection('_superusers').authWithPassword(
    process.env.POCKETBASE_ADMIN_EMAIL,
    process.env.POCKETBASE_ADMIN_PASSWORD
  );
  console.log('✅ Autenticado!\n');

  // Busca todas as partidas do Módulo 1 (629) e Módulo 2 (619)
  const leagues = await pb.collection('competitions').getFullList({
    filter: 'externalId = 629 || externalId = 619'
  });
  const leagueIds = leagues.map(l => l.id);
  console.log(`📋 Ligas encontradas: ${leagues.map(l => l.name).join(', ')}`);

  if (leagueIds.length === 0) {
    console.log('❌ Nenhuma liga encontrada!');
    return;
  }

  // Busca todas as partidas
  const fixtures = await pb.collection('fixtures').getFullList({
    expand: 'homeTeamId,awayTeamId',
    filter: leagueIds.map(id => `leagueId = '${id}'`).join(' || '),
    sort: 'date'
  });

  const finishedStatuses = ['FT', 'AET', 'PEN'];
  const finished = fixtures.filter(f => finishedStatuses.includes(f.statusShort));
  console.log(`\n🏟️ Total de partidas finalizadas: ${finished.length}`);

  let successCount = 0;
  let failCount = 0;

  for (let i = 0; i < finished.length; i++) {
    const f = finished[i];
    const homeTeam = f.expand?.homeTeamId?.[0] || f.expand?.homeTeamId;
    const awayTeam = f.expand?.awayTeamId?.[0] || f.expand?.awayTeamId;
    const homeName = homeTeam?.name || '?';
    const awayName = awayTeam?.name || '?';
    const dateStr = f.date?.substring(0, 10) || '';

    console.log(`[${i + 1}/${finished.length}] ${homeName} x ${awayName} (${dateStr})`);

    try {
      const collectedSources = [];
      let globoEvents = [];

      // 1. ge.globo
      const globoUrl = await findGloboUrl(homeName, awayName, f.date);
      if (globoUrl) {
        console.log(`  🌐 URL ge.globo: ${globoUrl}`);
        globoEvents = await scrapeAndSaveComments(f.id, globoUrl);
        console.log(`  ✅ Processado ge.globo (${globoEvents.length} eventos extraídos)`);
      } else {
        console.log('  ⚠ URL do ge.globo não encontrada.');
      }

      // 2. Placar de Futebol
      const placarLeagueSlug = f.leagueId === leagues.find(l => l.externalId === 619)?.id ? 'mineiro-modulo-2' : 'campeonato-mineiro';
      const placarData = await fetchPlacarMatchData(homeName, awayName, f.date, placarLeagueSlug);
      if (placarData) {
        console.log(`  🌐 URL Placar de Futebol: ${placarData.url}`);
        collectedSources.push(placarData);
      }

      // 3. ESPN (Somente Módulo 1)
      if (f.leagueId === leagues.find(l => l.externalId === 629)?.id) {
        const espnData = await fetchEspnMatchData(homeName, awayName, f.date, 'bra.camp.mineiro');
        if (espnData) {
          collectedSources.push(espnData);
        }
      }

      // Consolidar dados se alguma fonte retornou resultado
      if (collectedSources.length > 0) {
        const mergedInfo = mergeFixtureInfo(
          { homeGoals: f.homeGoals, awayGoals: f.awayGoals, statusShort: f.statusShort, elapsed: f.elapsed },
          collectedSources
        );

        if (mergedInfo.homeGoals !== f.homeGoals || mergedInfo.awayGoals !== f.awayGoals) {
          console.log(`  🛠️ Consolidado placar: ${f.homeGoals}x${f.awayGoals} -> ${mergedInfo.homeGoals}x${mergedInfo.awayGoals}`);
          await pb.collection('fixtures').update(f.id, {
            homeGoals: mergedInfo.homeGoals,
            awayGoals: mergedInfo.awayGoals
          });
        }

        // Merge e persistência de eventos
        const allEvents = [];
        if (globoEvents.length > 0) allEvents.push(globoEvents);
        collectedSources.forEach(s => {
          if (s.events && s.events.length > 0) allEvents.push(s.events);
        });

        if (allEvents.length > 0) {
          const mergedEvents = mergeFixtureEvents(allEvents);
          const currentEvents = await pb.collection('fixture_events').getFullList({
            filter: `fixtureId = '${f.id}'`
          });

          for (const ev of mergedEvents) {
            const exists = currentEvents.some(dbE => {
              const timeDiff = Math.abs(dbE.time - ev.time);
              const sameTime = timeDiff <= 1;
              const sameSide = (dbE.teamId === homeTeam.externalId && ev.teamSide === 'home') || (dbE.teamId === awayTeam.externalId && ev.teamSide === 'away');
              const sameType = dbE.type?.toLowerCase() === ev.type?.toLowerCase();
              return sameTime && sameSide && sameType;
            });

            if (!exists) {
              await pb.collection('fixture_events').create({
                fixtureId: f.id,
                time: ev.time,
                teamId: ev.teamSide === 'home' ? homeTeam.externalId : awayTeam.externalId,
                player: ev.player || '',
                type: ev.type || '',
                detail: ev.detail || '',
                playerPhoto: '',
                externalPlayerId: null
              });
              console.log(`  ➕ Adicionado evento: ${ev.time}' ${ev.type} (${ev.player})`);
            }
          }
        }
        successCount++;
      } else {
        if (!globoUrl) {
          console.log('  ⚠ Nenhuma fonte de dados respondeu para esta partida. Pulando...');
          failCount++;
        } else {
          successCount++;
        }
      }
    } catch (err) {
      console.log(`  ❌ Erro ao processar partida: ${err.message}`);
      failCount++;
    }

    await delay(1500);
  }

  console.log(`\n🎉 Backfill concluído!`);
  console.log(`   ✅ Partidas processadas com sucesso: ${successCount}`);
  console.log(`   ❌ Partidas com falha/sem fonte: ${failCount}`);
}

run().catch(console.error);
