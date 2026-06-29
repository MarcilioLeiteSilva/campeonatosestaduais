import axios from 'axios';

const zapscoreUrl = 'https://zapscore-zapscore-api.gtalg3.easypanel.host';

async function scanAllFixtures() {
  console.log("=== ESCANEANDO PARTIDAS MÓDULO 1 POR DETALHES ===");
  try {
    const res = await axios.get(`${zapscoreUrl}/fixtures?leagueId=629&season=2026&limit=100`);
    const fixtures = res.data;
    console.log(`Total de partidas encontradas: ${fixtures.length}`);

    for (const f of fixtures) {
      const extId = f.externalId;
      // Consultar se tem events, lineups ou stats
      const [evRes, lineRes, statRes] = await Promise.all([
        axios.get(`${zapscoreUrl}/fixtures/events?fixtureId=${extId}`).catch(() => ({ data: [] })),
        axios.get(`${zapscoreUrl}/fixtures/lineups?fixtureId=${extId}`).catch(() => ({ data: [] })),
        axios.get(`${zapscoreUrl}/fixtures/statistics?fixtureId=${extId}`).catch(() => ({ data: [] })),
      ]);

      const evCount = evRes.data?.length || 0;
      const lineCount = lineRes.data?.length || 0;
      const statCount = statRes.data?.length || 0;

      if (evCount > 0 || lineCount > 0 || statCount > 0) {
        console.log(`Partida [${extId}] ${f.homeTeam?.name} vs ${f.awayTeam?.name}:`);
        console.log(`  - Events: ${evCount}`);
        console.log(`  - Lineups: ${lineCount}`);
        console.log(`  - Stats: ${statCount}`);
      }
    }
    console.log("Varredura concluída.");
  } catch (e) {
    console.error("Erro geral:", e.message);
  }
}

scanAllFixtures();
