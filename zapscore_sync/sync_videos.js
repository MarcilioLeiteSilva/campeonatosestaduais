import axios from 'axios';

// Canais oficiais e parceiros que transmitem o Campeonato Mineiro (para conteúdos gerais)
const YOUTUBE_CHANNELS = [
  { name: 'FMF TV', id: 'UC3A-kV77_Q9vSsLmgNO2m9Q' }, // Canal FMF Oficial
  { name: 'Lance! Esporte', id: 'UC4j3XkBc2WYNHjLResS5usQ' }, // Lance! TV
  { name: 'Rede Minas', id: 'UCvmjnRirYcvH60tuOGTAE6A' }, // Rede Minas
  { name: 'Itatiaia Esporte', id: 'UC9T0ZAarQHL4cJGFzORVsFg' } // Itatiaia
];

/**
 * Normaliza uma string para comparação (sem acentos, minúsculo, sem caracteres especiais)
 */
function normalizeString(str) {
  if (!str) return '';
  return str
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^\w\s]/g, '')
    .trim();
}

/**
 * Helper para pausar execução (evitar limites de requisição)
 */
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Faz o parsing básico do XML do feed RSS do YouTube
 */
function parseYoutubeRss(xmlText) {
  const videos = [];
  const entryRegex = /<entry>([\s\S]*?)<\/entry>/g;
  let match;
  while ((match = entryRegex.exec(xmlText)) !== null) {
    const entry = match[1];
    const titleMatch = entry.match(/<title>([^<]+)<\/title>/);
    const videoIdMatch = entry.match(/<yt:videoId>([^<]+)<\/yt:videoId>/);
    const publishedMatch = entry.match(/<published>([^<]+)<\/published>/);
    const thumbMatch = entry.match(/<media:thumbnail[^>]*url="([^"]+)"/);
    const authorMatch = entry.match(/<author>[\s\S]*?<name>([^<]+)<\/name>/);

    if (videoIdMatch && titleMatch) {
      videos.push({
        title: titleMatch[1].trim(),
        url: `https://www.youtube.com/watch?v=${videoIdMatch[1].trim()}`,
        thumbnail: thumbMatch ? thumbMatch[1] : `https://img.youtube.com/vi/${videoIdMatch[1].trim()}/hqdefault.jpg`,
        date: publishedMatch ? publishedMatch[1] : new Date().toISOString(),
        channelName: authorMatch ? authorMatch[1].trim() : 'YouTube'
      });
    }
  }
  return videos;
}

/**
 * Realiza uma busca no YouTube por melhores momentos de uma partida específica
 */
async function searchFixtureVideo(pb, fixture) {
  const homeTeam = fixture.expand.homeTeamId;
  const awayTeam = fixture.expand.awayTeamId;
  const league = fixture.expand.leagueId;
  
  if (!homeTeam || !awayTeam || !league) return null;
  
  const isModulo2 = league.externalId === 619;
  const leagueTerm = isModulo2 ? 'modulo ii' : 'modulo i';
  const query = `${homeTeam.name} x ${awayTeam.name} melhores momentos campeonato mineiro ${leagueTerm} 2026`;
  
  const url = `https://www.youtube.com/results?search_query=${encodeURIComponent(query)}`;
  
  try {
    const response = await axios.get(url, {
      timeout: 10000,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
        'Cache-Control': 'no-cache'
      }
    });

    const html = response.data;
    const regex = /var ytInitialData = ({[\s\S]*?});/;
    const match = html.match(regex);
    if (!match) return null;

    const data = JSON.parse(match[1]);
    const contents = data.contents?.twoColumnSearchResultsRenderer?.primaryContents?.sectionListRenderer?.contents;
    if (!contents) return null;

    const normHome = normalizeString(homeTeam.name);
    const normAway = normalizeString(awayTeam.name);

    for (const content of contents) {
      const itemSection = content.itemSectionRenderer;
      if (!itemSection || !itemSection.contents) continue;
      
      for (const item of itemSection.contents) {
        const videoRenderer = item.videoRenderer;
        if (!videoRenderer) continue;
        
        const videoId = videoRenderer.videoId;
        const title = videoRenderer.title?.runs?.[0]?.text;
        const thumbnail = videoRenderer.thumbnail?.thumbnails?.[0]?.url;
        const channelName = videoRenderer.ownerText?.runs?.[0]?.text || 'YouTube';
        
        if (videoId && title) {
          const normTitle = normalizeString(title);
          
          // Excluir se for de outra competição (como Brasileirão Série D, Copa do Brasil, etc.)
          const isOtherCompetition = normTitle.includes('brasileirao') ||
                                     normTitle.includes('serie a') ||
                                     normTitle.includes('serie b') ||
                                     normTitle.includes('serie c') ||
                                     normTitle.includes('serie d') ||
                                     normTitle.includes('copa do brasil') ||
                                     normTitle.includes('sulamericana') ||
                                     normTitle.includes('libertadores');

          if (isOtherCompetition) continue;

          // Verificação de relevância: o título deve conter os nomes de ambos os times
          // OU conter pelo menos um time e palavras-chave do campeonato mineiro
          const containsHome = normTitle.includes(normHome);
          const containsAway = normTitle.includes(normAway);
          const containsMineiroOrModulo = normTitle.includes('mineiro') || normTitle.includes('modulo');

          const isRelevant = (containsHome && containsAway) || 
                             ((containsHome || containsAway) && containsMineiroOrModulo);

          if (isRelevant) {
            return {
              title,
              url: `https://www.youtube.com/watch?v=${videoId}`,
              thumbnail: thumbnail || `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`,
              date: fixture.date || new Date().toISOString(), // Usar data da partida
              leagueId: league.externalId.toString(),
              fixtureId: fixture.id,
              channelName
            };
          }
        }
      }
    }
  } catch (err) {
    console.error(`❌ Erro ao buscar vídeo para ${homeTeam.name} x ${awayTeam.name}:`, err.message);
  }
  return null;
}

/**
 * Função principal para sincronizar vídeos do YouTube no Pocketbase
 * @param {PocketBase} pb - Instância autenticada do PocketBase
 */
export async function syncVideos(pb) {
  console.log('🎬 Iniciando sincronização inteligente de vídeos...');
  try {
    // 0. Limpar vídeos de outras competições cadastrados incorretamente (como Brasileirão Série D)
    console.log('🧹 Limpando vídeos antigos de outras competições (Brasileirão, Série D, etc.)...');
    try {
      const existingVideos = await pb.collection('videos').getFullList();
      let deletedCount = 0;
      for (const v of existingVideos) {
        const normVTitle = normalizeString(v.title);
        const isOther = normVTitle.includes('brasileirao') ||
                        normVTitle.includes('serie a') ||
                        normVTitle.includes('serie b') ||
                        normVTitle.includes('serie c') ||
                        normVTitle.includes('serie d') ||
                        normVTitle.includes('copa do brasil') ||
                        normVTitle.includes('sulamericana') ||
                        normVTitle.includes('libertadores');
        if (isOther) {
          await pb.collection('videos').delete(v.id);
          deletedCount++;
        }
      }
      if (deletedCount > 0) {
        console.log(`🧹 Removidos ${deletedCount} vídeos inválidos do banco.`);
      }
    } catch (cleanErr) {
      console.warn('⚠️ Alerta durante limpeza de vídeos inválidos:', cleanErr.message);
    }

    // 1. Carregar competições do PocketBase para obter os IDs internos
    const comps = await pb.collection('competitions').getFullList();
    const compModulo1 = comps.find(c => c.externalId === 629);
    const compModulo2 = comps.find(c => c.externalId === 619);

    if (!compModulo1 || !compModulo2) {
      console.warn('⚠️ Ligas Módulo 1 (629) e/ou Módulo 2 (619) não encontradas no PocketBase.');
      return;
    }

    // Mapeamento de ID externo para ID Pocketbase
    const leagueMap = {
      '629': compModulo1.id,
      '619': compModulo2.id
    };

    // 2. Carregar todas as partidas finalizadas para buscar vídeos delas
    const fixtures = await pb.collection('fixtures').getFullList({
      expand: 'homeTeamId,awayTeamId,leagueId',
      filter: "statusShort = 'FT' || statusShort = 'AET' || statusShort = 'PEN' || statusShort = 'LIVE'",
      sort: '-date'
    });

    console.log(`⚽ Encontradas ${fixtures.length} partidas finalizadas ou ao vivo para verificação.`);

    // 3. Obter os IDs de partidas que já possuem vídeos no banco
    const existingVideos = await pb.collection('videos').getFullList();
    const fixturesWithVideo = new Set(existingVideos.map(v => v.fixtureId).filter(id => id));

    // Filtrar partidas que ainda não possuem vídeos vinculados
    const fixturesPendingVideo = fixtures.filter(f => !fixturesWithVideo.has(f.id));
    console.log(`🔍 Partidas sem vídeo vinculado: ${fixturesPendingVideo.length}`);

    // Limite de buscas por execução para evitar rate limit do YouTube
    const SEARCH_LIMIT = 15;
    let searchCount = 0;
    let addedCount = 0;

    for (const fixture of fixturesPendingVideo) {
      if (searchCount >= SEARCH_LIMIT) {
        console.log(`⏳ Limite de ${SEARCH_LIMIT} buscas atingido nesta rodada. O restante será processado no próximo ciclo.`);
        break;
      }

      const home = fixture.expand.homeTeamId?.name;
      const away = fixture.expand.awayTeamId?.name;
      console.log(`📡 Buscando melhores momentos no YouTube: ${home} x ${away}...`);
      
      searchCount++;
      const videoResult = await searchFixtureVideo(pb, fixture);
      
      if (videoResult) {
        try {
          // Salvar o vídeo na coleção
          await pb.collection('videos').create({
            title: videoResult.title,
            url: videoResult.url,
            thumbnail: videoResult.thumbnail,
            date: videoResult.date,
            leagueId: videoResult.leagueId,
            fixtureId: videoResult.fixtureId,
            channelName: videoResult.channelName
          });
          addedCount++;
          console.log(`🆕 Vídeo associado e cadastrado: "${videoResult.title}"`);
        } catch (saveErr) {
          console.error(`❌ Erro ao salvar vídeo da partida:`, saveErr.message);
        }
      }

      // Delay de cortesia entre buscas do YouTube
      await delay(1500);
    }

    // 4. Buscar os feeds RSS gerais como fonte secundária (para rodadas, lives gerais, etc.)
    console.log('📡 Coletando conteúdos adicionais nos feeds RSS oficiais...');
    const allFetchedVideos = [];
    for (const channel of YOUTUBE_CHANNELS) {
      try {
        const rssUrl = `https://www.youtube.com/feeds/videos.xml?channel_id=${channel.id}`;
        const response = await axios.get(rssUrl, {
          timeout: 10000,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Cache-Control': 'no-cache'
          }
        });
        const channelVideos = parseYoutubeRss(response.data);
        allFetchedVideos.push(...channelVideos);
      } catch (err) {
        console.error(`❌ Erro ao buscar feed do canal ${channel.name}:`, err.message);
      }
    }

    // Mapeamento dos nomes de times para catalogar feeds RSS gerais
    const teamLeagueMap = {};
    for (const f of fixtures) {
      const homeTeam = f.expand.homeTeamId;
      const awayTeam = f.expand.awayTeamId;
      const league = f.expand.leagueId;
      if (!homeTeam || !awayTeam || !league) continue;

      const leagueIdStr = league.externalId.toString();
      teamLeagueMap[normalizeString(homeTeam.name)] = leagueIdStr;
      teamLeagueMap[normalizeString(awayTeam.name)] = leagueIdStr;
    }

    let feedAddedCount = 0;
    for (const video of allFetchedVideos) {
      const normTitle = normalizeString(video.title);

      // Ignorar se for de outra liga
      const isOtherCompetition = normTitle.includes('brasileirao') ||
                                 normTitle.includes('serie a') ||
                                 normTitle.includes('serie b') ||
                                 normTitle.includes('serie c') ||
                                 normTitle.includes('serie d') ||
                                 normTitle.includes('copa do brasil') ||
                                 normTitle.includes('sulamericana') ||
                                 normTitle.includes('libertadores');

      if (isOtherCompetition) continue;

      const isMineiroMatch = normTitle.includes('mineiro') || 
                             normTitle.includes('modulo') || 
                             normTitle.includes('fmf') ||
                             Object.keys(teamLeagueMap).some(teamName => normTitle.includes(teamName));

      if (!isMineiroMatch) continue;

      // Classificar liga
      let leagueId = '629'; // Default Módulo 1
      if (normTitle.includes('modulo ii') || normTitle.includes('modulo 2')) {
        leagueId = '619';
      } else if (normTitle.includes('modulo i ') || normTitle.includes('modulo 1')) {
        leagueId = '629';
      } else {
        // Pelo nome do time
        for (const [teamName, leagueIdStr] of Object.entries(teamLeagueMap)) {
          if (normTitle.includes(teamName)) {
            leagueId = leagueIdStr;
            break;
          }
        }
      }

      // Salvar apenas se o URL for inédito
      try {
        let existingRecord = null;
        try {
          existingRecord = await pb.collection('videos').getFirstListItem(`url = "${video.url}"`);
        } catch (e) {}

        if (!existingRecord) {
          await pb.collection('videos').create({
            title: video.title,
            url: video.url,
            thumbnail: video.thumbnail,
            date: video.date,
            leagueId: leagueId,
            fixtureId: null, // Sem partida específica vinculada pelo RSS geral
            channelName: video.channelName
          });
          feedAddedCount++;
          console.log(`🆕 Vídeo de feed adicionado: "${video.title}" (Liga: ${leagueId})`);
        }
      } catch (dbErr) {
        console.error(`❌ Erro ao salvar vídeo RSS [${video.title}]:`, dbErr.message);
      }
    }

    console.log(`📊 Sincronização inteligente concluída: ${addedCount} de partidas e ${feedAddedCount} de feeds cadastrados.`);
  } catch (err) {
    console.error('❌ Falha geral na sincronização de vídeos:', err.message);
  }
}
