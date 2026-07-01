import axios from 'axios';

// Canais oficiais e parceiros que transmitem o Campeonato Mineiro
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
 * Função principal para sincronizar vídeos do YouTube no Pocketbase
 * @param {PocketBase} pb - Instância autenticada do PocketBase
 */
export async function syncVideos(pb) {
  console.log('🎬 Iniciando sincronização de vídeos do Campeonato Mineiro...');
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

    // 2. Carregar todas as partidas para mapear times e associar fixtures aos vídeos
    const fixtures = await pb.collection('fixtures').getFullList({
      expand: 'homeTeamId,awayTeamId,leagueId',
      sort: '-date'
    });

    // Criar um mapeamento de times para a liga correspondente com base nas partidas
    const teamLeagueMap = {}; // { 'nome_do_time_normalizado': '629' | '619' }
    const teamIdMap = {}; // { 'nome_do_time_normalizado': pbTeamId }
    
    for (const f of fixtures) {
      const homeTeam = f.expand.homeTeamId;
      const awayTeam = f.expand.awayTeamId;
      const league = f.expand.leagueId;

      if (!homeTeam || !awayTeam || !league) continue;

      const leagueIdStr = league.externalId.toString(); // "629" ou "619"

      const normHome = normalizeString(homeTeam.name);
      const normAway = normalizeString(awayTeam.name);

      teamLeagueMap[normHome] = leagueIdStr;
      teamLeagueMap[normAway] = leagueIdStr;
      
      teamIdMap[normHome] = homeTeam.id;
      teamIdMap[normAway] = awayTeam.id;
    }

    // 3. Buscar os feeds RSS de cada canal do YouTube
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
        console.log(`📹 Encontrados ${channelVideos.length} vídeos no feed.`);
        allFetchedVideos.push(...channelVideos);
      } catch (err) {
        console.error(`❌ Erro ao buscar feed do canal ${channel.name}:`, err.message);
      }
    }

    console.log(`🔍 Processando total de ${allFetchedVideos.length} vídeos...`);

    let addedCount = 0;
    let updatedCount = 0;

    for (const video of allFetchedVideos) {
      const normTitle = normalizeString(video.title);

      // Excluir se for de outra competição (como Brasileirão Série D, Série B, Copa do Brasil, etc.)
      const isOtherCompetition = normTitle.includes('brasileirao') ||
                                 normTitle.includes('serie a') ||
                                 normTitle.includes('serie b') ||
                                 normTitle.includes('serie c') ||
                                 normTitle.includes('serie d') ||
                                 normTitle.includes('copa do brasil') ||
                                 normTitle.includes('sulamericana') ||
                                 normTitle.includes('libertadores');

      // Critério básico de relevância: o título deve mencionar o campeonato ou os times
      const isMineiroMatch = (normTitle.includes('mineiro') || 
                              normTitle.includes('modulo') || 
                              normTitle.includes('fmf') ||
                              Object.keys(teamLeagueMap).some(teamName => normTitle.includes(teamName))) &&
                             !isOtherCompetition;

      if (!isMineiroMatch) {
        // Ignorar vídeos não relacionados ao Campeonato Mineiro
        continue;
      }

      // 4. Classificar a liga (Módulo 1 vs Módulo 2)
      let leagueId = null;

      // Prioridade 1: indicação explícita no título
      if (normTitle.includes('modulo i ') || normTitle.includes('modulo 1') || normTitle.includes('primeira divisao')) {
        leagueId = '629';
      } else if (normTitle.includes('modulo ii') || normTitle.includes('modulo 2') || normTitle.includes('segunda divisao')) {
        leagueId = '619';
      } else {
        // Prioridade 2: verificar os times envolvidos no título
        let m1Score = 0;
        let m2Score = 0;

        for (const [teamName, leagueIdStr] of Object.entries(teamLeagueMap)) {
          if (normTitle.includes(teamName)) {
            if (leagueIdStr === '629') m1Score++;
            if (leagueIdStr === '619') m2Score++;
          }
        }

        if (m1Score > m2Score) {
          leagueId = '629';
        } else if (m2Score > m1Score) {
          leagueId = '619';
        } else if (m1Score > 0 && m1Score === m2Score) {
          // Empate ou menções mistas (ex: amistoso, notícias gerais)
          leagueId = '629'; // Default Módulo 1
        }
      }

      // Se não conseguimos determinar, assumimos Módulo 1 como padrão se for relacionado ao campeonato
      if (!leagueId) {
        leagueId = '629';
      }

      // 5. Tentar encontrar se o vídeo corresponde a uma partida (fixture) específica
      let matchedFixtureId = '';
      let bestMatchScore = 0;

      for (const f of fixtures) {
        const homeTeam = f.expand.homeTeamId;
        const awayTeam = f.expand.awayTeamId;
        if (!homeTeam || !awayTeam) continue;

        const normHome = normalizeString(homeTeam.name);
        const normAway = normalizeString(awayTeam.name);

        let matchScore = 0;
        // Se ambos os times estão no título do vídeo, é um match perfeito!
        if (normTitle.includes(normHome) && normTitle.includes(normAway)) {
          matchScore = 3;
        } else if (normTitle.includes(normHome) || normTitle.includes(normAway)) {
          // Apenas um time é mencionado
          matchScore = 1;
        }

        if (matchScore > bestMatchScore) {
          bestMatchScore = matchScore;
          matchedFixtureId = f.id;
        }
      }

      // 6. Salvar ou atualizar no Pocketbase
      const videoData = {
        title: video.title,
        url: video.url,
        thumbnail: video.thumbnail,
        date: video.date,
        leagueId: leagueId,
        fixtureId: matchedFixtureId || null,
        channelName: video.channelName
      };

      try {
        let existingRecord = null;
        try {
          existingRecord = await pb.collection('videos').getFirstListItem(`url = "${video.url}"`);
        } catch (e) {
          // Registro não existe
        }

        if (existingRecord) {
          await pb.collection('videos').update(existingRecord.id, videoData);
          updatedCount++;
        } else {
          await pb.collection('videos').create(videoData);
          addedCount++;
          console.log(`🆕 Novo vídeo adicionado: "${video.title}" (Liga: ${leagueId})`);
        }
      } catch (dbErr) {
        console.error(`❌ Erro ao salvar vídeo no Pocketbase [${video.title}]:`, dbErr.message);
      }
    }

    console.log(`📊 Sincronização concluída: ${addedCount} criados, ${updatedCount} atualizados.`);
  } catch (err) {
    console.error('❌ Falha geral na sincronização de vídeos:', err.message);
  }
}
