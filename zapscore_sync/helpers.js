import axios from 'axios';

// Map of common team variations to clean, standardized slugs
export const TEAM_SLUG_MAP = {
  'atletico mineiro': 'atletico-mg',
  'atletico-mg': 'atletico-mg',
  'atletico mg': 'atletico-mg',
  'galo': 'atletico-mg',
  'cruzeiro': 'cruzeiro',
  'cruzeiro mg': 'cruzeiro',
  'america mineiro': 'america-mg',
  'america-mg': 'america-mg',
  'america mg': 'america-mg',
  'tombense': 'tombense',
  'pouso alegre': 'pouso-alegre',
  'patrocinense': 'patrocinense',
  'uberlandia': 'uberlandia',
  'villa nova': 'villa-nova',
  'caldense': 'caldense',
  'democrata gv': 'democrata-gv',
  'democrata-gv': 'democrata-gv',
  'democrata sl': 'democrata-sl',
  'democrata-sl': 'democrata-sl',
  'ipatinga': 'ipatinga',
  'aymores': 'aymores',
  'guarani mg': 'guarani-mg',
  'guarani-mg': 'guarani-mg',
  'boa esporte': 'boa',
  'boa': 'boa',
  'mamore': 'mamore',
  'coimbra': 'coimbra',
  'valeriodoce': 'valeriodoce',
  'cap': 'pouso-alegre',
  'uberaba': 'uberaba',
  'athletic club': 'athletic-club',
  'athletic': 'athletic-club',
  'betim': 'betim',
  'north esporte': 'north-esporte',
  'uniao trabalhadores': 'uniao-trabalhadores',
  'itabirito': 'itabirito'
};

const USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

/**
 * Normalizes team names to a standard, simplified slug representation.
 */
export function normalizeTeamName(name) {
  if (!name) return '';
  let normalized = name.normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // remove accents
    .toLowerCase()
    .trim()
    .replace(/\s+/g, ' ')
    // Remove common suffixes
    .replace(/\b(esporte clube|esporte|fc|futebol clube|sub-17|sub-20|feminino|mg|mineiro)\b/g, '')
    .trim();
    
  if (TEAM_SLUG_MAP[normalized]) {
    return TEAM_SLUG_MAP[normalized];
  }
  
  // Final slug conversion
  return normalized
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

/**
 * Compares two team names for similarity.
 */
export function areTeamsSimilar(name1, name2) {
  const norm1 = normalizeTeamName(name1);
  const norm2 = normalizeTeamName(name2);
  
  if (!norm1 || !norm2) return false;
  if (norm1 === norm2) return true;
  
  // Substring matching
  if (norm1.includes(norm2) || norm2.includes(norm1)) return true;
  
  return false;
}

/**
 * Formats a Date object or date string to DD-MM-YYYY format
 */
export function formatDateDMY(dateStr) {
  if (!dateStr) return '';
  if (dateStr instanceof Date) {
    const day = String(dateStr.getDate()).padStart(2, '0');
    const month = String(dateStr.getMonth() + 1).padStart(2, '0');
    const year = dateStr.getFullYear();
    return `${day}-${month}-${year}`;
  }
  
  const cleanDateStr = dateStr.split(' ')[0];
  const parts = cleanDateStr.split('-');
  if (parts.length === 3) {
    return `${parts[2]}-${parts[1]}-${parts[0]}`;
  }
  
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return '';
  const day = String(d.getUTCDate()).padStart(2, '0');
  const month = String(d.getUTCMonth() + 1).padStart(2, '0');
  const year = d.getUTCFullYear();
  return `${day}-${month}-${year}`;
}

/**
 * Formats date string to YYYYMMDD (required by ESPN)
 */
export function formatDateYMD(dateStr) {
  if (!dateStr) return '';
  const cleanDateStr = dateStr.split(' ')[0];
  return cleanDateStr.replace(/-/g, '');
}

/**
 * Source 3: Placar de Futebol Scraper
 */
export async function fetchPlacarMatchData(homeName, awayName, dateStr, leagueSlug = 'mineiro-modulo-2') {
  const homeSlug = normalizeTeamName(homeName);
  const awaySlug = normalizeTeamName(awayName);
  const formattedDate = formatDateDMY(dateStr);
  
  const homeSlugs = [homeSlug];
  if (homeSlug === 'boa') homeSlugs.push('boa-esporte');
  const awaySlugs = [awaySlug];
  if (awaySlug === 'boa') awaySlugs.push('boa-esporte');
  
  const urlsToTry = [];
  for (const h of homeSlugs) {
    for (const a of awaySlugs) {
      urlsToTry.push(`https://www.placardefutebol.com.br/amp/${leagueSlug}/${formattedDate}-${h}-x-${a}.html`);
      urlsToTry.push(`https://www.placardefutebol.com.br/amp/${leagueSlug}/${formattedDate}-${a}-x-${h}.html`);
    }
  }
  
  // Add some fallback slugs for other leagues
  if (leagueSlug === 'mineiro-modulo-2') {
    for (const h of homeSlugs) {
      for (const a of awaySlugs) {
        urlsToTry.push(`https://www.placardefutebol.com.br/amp/campeonato-mineiro/${formattedDate}-${h}-x-${a}.html`);
      }
    }
  }

  for (const url of urlsToTry) {
    try {
      const response = await axios.get(url, { headers: { 'User-Agent': USER_AGENT }, timeout: 5000 });
      if (response.status === 200) {
        const html = response.data;
        const scores = [...html.matchAll(/<span class="match-summary__board-score__regular-score">([^<]+)<\/span>/g)].map(m => m[1].trim());
        const homeGoals = scores[0] ? parseInt(scores[0], 10) : null;
        const awayGoals = scores[1] ? parseInt(scores[1], 10) : null;
        
        const trRegex = /<tr>([\s\S]*?)<\/tr>/gi;
        let match;
        const events = [];
        
        while ((match = trRegex.exec(html)) !== null) {
          const trContent = match[1];
          if (!trContent.includes('amp-img') && !trContent.includes('timeline-table')) continue;
          
          const tdRegex = /<td>([\s\S]*?)<\/td>/gi;
          const tds = [];
          let tdMatch;
          while ((tdMatch = tdRegex.exec(trContent)) !== null) {
            tds.push(tdMatch[1].trim());
          }
          
          if (tds.length >= 3) {
            const timeStr = tds[1].replace(/<[^>]+>/g, '').trim();
            const leftContent = tds[0];
            const rightContent = tds[2];
            
            const parseCell = (content, teamSide) => {
              if (!content.includes('amp-img')) return null;
              const playerMatch = content.match(/<b>([^<]+)<\/b>/i);
              const player = playerMatch ? playerMatch[1].trim() : '';
              const imgMatch = content.match(/src="([^"]+)"/i);
              const imgSrc = imgMatch ? imgMatch[1] : '';
              
              let type = 'text';
              let detail = '';
              
              if (imgSrc.includes('goal.png') || imgSrc.includes('gol.png')) {
                type = 'gol';
                detail = 'Gol';
              } else if (imgSrc.includes('yellow-card') || imgSrc.includes('amarelo')) {
                type = 'card';
                detail = 'Yellow Card';
              } else if (imgSrc.includes('red-card') || imgSrc.includes('vermelho')) {
                type = 'card';
                detail = 'Red Card';
              } else if (imgSrc.includes('substitution') || imgSrc.includes('substitu')) {
                type = 'subst';
                detail = 'Substitution';
              }
              
              return {
                time: parseInt(timeStr.replace(/\D/g, ''), 10) || 0,
                teamSide,
                player,
                type,
                detail
              };
            };
            
            const leftEvent = parseCell(leftContent, 'home');
            if (leftEvent) events.push(leftEvent);
            
            const rightEvent = parseCell(rightContent, 'away');
            if (rightEvent) events.push(rightEvent);
          }
        }
        
        return {
          source: 'Placar de Futebol',
          homeGoals,
          awayGoals,
          events,
          url
        };
      }
    } catch (e) {
      // Quiet fail to try next URL
    }
  }
  return null;
}

/**
 * Source 4: Futebol Interior Live Gamelist Scraper
 */
export async function fetchFIMatchData(homeName, awayName) {
  try {
    const pageUrl = 'https://www.futebolinterior.com.br/placar-ao-vivo/';
    const pageResp = await axios.get(pageUrl, { headers: { 'User-Agent': USER_AGENT }, timeout: 6000 });
    const html = pageResp.data;
    
    const nonceMatch = html.match(/&quot;nonce&quot;:&quot;([a-f0-9]+)&quot;/i) || html.match(/"nonce":"([a-f0-9]+)"/i);
    const nonce = nonceMatch ? nonceMatch[1] : null;
    if (!nonce) return null;
    
    const gamelistUrl = 'https://www.futebolinterior.com.br/wp-json/api/miniscore_get_gamelist';
    const listResp = await axios.get(gamelistUrl, {
      headers: { 'User-Agent': USER_AGENT, 'X-WP-Nonce': nonce },
      timeout: 6000
    });
    
    const games = listResp.data || {};
    for (const matchId of Object.keys(games)) {
      const g = games[matchId];
      if (g && g.mandante && g.visitante) {
        if (areTeamsSimilar(g.mandante.nome, homeName) && areTeamsSimilar(g.visitante.nome, awayName)) {
          // Found game!
          // We can fetch live score if there's any or return standard structure
          return {
            source: 'Futebol Interior',
            homeGoals: g.gols_mandante !== undefined ? parseInt(g.gols_mandante, 10) : null,
            awayGoals: g.gols_visitante !== undefined ? parseInt(g.gols_visitante, 10) : null,
            status: g.periodo || 'LIVE'
          };
        }
      }
    }
  } catch (e) {
    // Quiet fail
  }
  return null;
}

/**
 * Source 5: ESPN Scoreboard API
 */
export async function fetchEspnMatchData(homeName, awayName, dateStr, leagueSlug = 'bra.camp.mineiro') {
  const formattedDate = formatDateYMD(dateStr);
  const url = `https://site.api.espn.com/apis/site/v2/sports/soccer/${leagueSlug}/scoreboard?dates=${formattedDate}`;
  
  try {
    const response = await axios.get(url, { headers: { 'User-Agent': USER_AGENT }, timeout: 5000 });
    const events = response.data?.events || [];
    
    for (const e of events) {
      const competitors = e.competitions?.[0]?.competitors || [];
      const homeComp = competitors.find(c => c.homeAway === 'home');
      const awayComp = competitors.find(c => c.homeAway === 'away');
      
      if (homeComp && awayComp) {
        if (areTeamsSimilar(homeComp.team?.name, homeName) && areTeamsSimilar(awayComp.team?.name, awayName)) {
          const homeGoals = homeComp.score !== undefined ? parseInt(homeComp.score, 10) : null;
          const awayGoals = awayComp.score !== undefined ? parseInt(awayComp.score, 10) : null;
          const statusShort = e.status?.type?.shortDetail || e.status?.type?.state === 'post' ? 'FT' : 'LIVE';
          
          return {
            source: 'ESPN',
            homeGoals,
            awayGoals,
            status: statusShort,
            events: [] // ESPN events need a separate game summary call, skip for simplicity unless needed
          };
        }
      }
    }
  } catch (e) {
    // Quiet fail
  }
  return null;
}

/**
 * Merges scores and status from all sources based on priority
 */
export function mergeFixtureInfo(pbFixture, sourcesData) {
  // Priority: ge.globo > ZapScore API > Placar de Futebol > ESPN > Futebol Interior
  const priorities = ['ge.globo', 'ZapScore API', 'Placar de Futebol', 'ESPN', 'Futebol Interior'];
  
  let bestHomeGoals = pbFixture.homeGoals;
  let bestAwayGoals = pbFixture.awayGoals;
  let bestStatus = pbFixture.statusShort;
  let bestElapsed = pbFixture.elapsed;
  
  // Sort sources by priority
  const sortedSources = [...sourcesData].sort((a, b) => {
    return priorities.indexOf(a.source) - priorities.indexOf(b.source);
  });
  
  for (const s of sortedSources) {
    if (s.homeGoals !== null && s.homeGoals !== undefined) {
      bestHomeGoals = s.homeGoals;
    }
    if (s.awayGoals !== null && s.awayGoals !== undefined) {
      bestAwayGoals = s.awayGoals;
    }
    if (s.status) {
      bestStatus = s.status;
    }
    if (s.elapsed !== undefined && s.elapsed !== null) {
      bestElapsed = s.elapsed;
    }
  }
  
  return {
    homeGoals: bestHomeGoals,
    awayGoals: bestAwayGoals,
    statusShort: bestStatus,
    elapsed: bestElapsed
  };
}

/**
 * Deduplicates and merges events from multiple sources
 */
export function mergeFixtureEvents(eventsFromSources) {
  const merged = [];
  
  for (const list of eventsFromSources) {
    if (!list || !Array.isArray(list)) continue;
    for (const e of list) {
      // Find if this event already exists in merged list
      const isDuplicate = merged.some(existing => {
        const timeDiff = Math.abs((existing.time || 0) - (e.time || 0));
        const sameTime = timeDiff <= 1; // Allow 1 min difference
        const sameSide = existing.teamSide === e.teamSide;
        const sameType = existing.type === e.type;
        
        let samePlayer = false;
        if (existing.player && e.player) {
          const p1 = normalizeTeamName(existing.player);
          const p2 = normalizeTeamName(e.player);
          samePlayer = p1.includes(p2) || p2.includes(p1);
        } else {
          // If player name is missing on one side, match only on time/type/side
          samePlayer = true;
        }
        
        return sameTime && sameSide && sameType && samePlayer;
      });
      
      if (!isDuplicate) {
        merged.push(e);
      } else {
        // Find and enrich the existing one if needed
        const idx = merged.findIndex(existing => {
          const timeDiff = Math.abs((existing.time || 0) - (e.time || 0));
          return timeDiff <= 1 && existing.teamSide === e.teamSide && existing.type === e.type;
        });
        if (idx !== -1) {
          // Keep longer player name or detail if richer
          if (e.player && (!merged[idx].player || e.player.length > merged[idx].player.length)) {
            merged[idx].player = e.player;
          }
          if (e.detail && (!merged[idx].detail || e.detail.length > merged[idx].detail.length)) {
            merged[idx].detail = e.detail;
          }
          if (e.assist && (!merged[idx].assist || e.assist.length > merged[idx].assist.length)) {
            merged[idx].assist = e.assist;
          }
        }
      }
    }
  }
  
  return merged;
}
