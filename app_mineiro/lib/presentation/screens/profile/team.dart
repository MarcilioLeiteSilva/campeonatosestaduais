part of '../screens.dart';

class TeamProfileScreen extends StatefulWidget {
  const TeamProfileScreen({
    super.key,
    required this.teamName,
    required this.teamLogo,
  });

  final String teamName;
  final String teamLogo;

  @override
  State<TeamProfileScreen> createState() => _TeamProfileScreenState();
}

class _TeamProfileScreenState extends State<TeamProfileScreen> {
  int indexTab = 0;
  List<String> tabs = [
    "Resumo",
    "Elenco",
    "Partidas",
    "Estatísticas"
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Obter partidas reais do time do EventsApi
    final teamMatches = EventsApi.eListEvents.where((e) {
      return e.nameHome.toLowerCase() == widget.teamName.toLowerCase() ||
             e.nameAway.toLowerCase() == widget.teamName.toLowerCase();
    }).toList();

    // 2. Calcular estatísticas gerais reais do time
    int played = 0;
    int wins = 0;
    int draws = 0;
    int losses = 0;
    int goalsScored = 0;
    int goalsConceded = 0;
    int cleanSheets = 0;
    List<String> form = [];

    final finishedMatches = teamMatches.where((m) => m.timeMatch == 'FT' || m.timeMatch == 'PEN').toList();
    
    // Obter os últimos 5 jogos para a forma (da esquerda mais antigo para direita mais recente)
    final recent5 = finishedMatches.take(5).toList();
    for (final m in recent5) {
      final isHome = m.nameHome.toLowerCase() == widget.teamName.toLowerCase();
      final scoreSelf = m.scoreHome != null && m.scoreAway != null
          ? (isHome ? (m.scoreHome as num).toInt() : (m.scoreAway as num).toInt())
          : 0;
      final scoreOpp = m.scoreHome != null && m.scoreAway != null
          ? (isHome ? (m.scoreAway as num).toInt() : (m.scoreHome as num).toInt())
          : 0;

      if (scoreSelf > scoreOpp) {
        form.add('W');
      } else if (scoreSelf < scoreOpp) {
        form.add('L');
      } else {
        form.add('D');
      }
    }
    form = form.reversed.toList();

    for (final m in finishedMatches) {
      played++;
      final isHome = m.nameHome.toLowerCase() == widget.teamName.toLowerCase();
      final scoreSelf = m.scoreHome != null && m.scoreAway != null
          ? (isHome ? (m.scoreHome as num).toInt() : (m.scoreAway as num).toInt())
          : 0;
      final scoreOpp = m.scoreHome != null && m.scoreAway != null
          ? (isHome ? (m.scoreAway as num).toInt() : (m.scoreHome as num).toInt())
          : 0;

      goalsScored += scoreSelf;
      goalsConceded += scoreOpp;

      if (scoreOpp == 0) {
        cleanSheets++;
      }

      if (scoreSelf > scoreOpp) {
        wins++;
      } else if (scoreSelf < scoreOpp) {
        losses++;
      } else {
        draws++;
      }
    }

    final winPercentage = played > 0 ? (wins / played * 100).toStringAsFixed(1) : '0';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header do Time: Escudo, Nome e Liga Principal
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            color: AppColor.card,
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: widget.teamLogo.startsWith('http')
                      ? Image.network(
                          getImageUrl(widget.teamLogo),
                          errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer, size: 40, color: Colors.grey),
                        )
                      : const Icon(Icons.sports_soccer, size: 40, color: Colors.grey),
                ),
                const Gap(15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.teamName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Gap(4),
                      const Text(
                        'Campeonato Mineiro 2026',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Seletor de Abas
          Container(
            width: context.width,
            height: 52,
            color: AppColor.background,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (_, i) {
                return CardCheepTabSearch(
                  select: indexTab == i,
                  label: tabs[i],
                  onTap: () {
                    setState(() {
                      indexTab = i;
                    });
                  },
                );
              },
              separatorBuilder: (_, i) => const Gap(10),
              itemCount: tabs.length,
            ),
          ),
          // Conteúdo das Abas
          Expanded(
            child: [
              _buildResumoTab(form, played, wins, draws, losses, winPercentage),
              _buildElencoTab(),
              _buildPartidasTab(teamMatches),
              _buildEstatisticasTab(played, wins, draws, losses, goalsScored, goalsConceded, cleanSheets, winPercentage),
            ][indexTab],
          ),
        ],
      ),
    );
  }

  Widget _buildResumoTab(List<String> form, int played, int wins, int draws, int losses, String winPercentage) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      children: [
        // Card de Forma (Últimos 5 jogos)
        const Text(
          'Desempenho Recente (Forma)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Gap(10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.info),
          ),
          child: Row(
            children: [
              const Text(
                'Últimos jogos:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Spacer(),
              if (form.isEmpty)
                const Text('Sem jogos registrados', style: TextStyle(color: Colors.grey, fontSize: 12))
              else
                ...form.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: f == 'W'
                            ? Colors.green
                            : (f == 'L' ? Colors.red : Colors.grey),
                        child: Text(
                          f,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    )),
            ],
          ),
        ),
        const Gap(25),
        // Estatísticas Resumidas
        const Text(
          'Resumo da Temporada',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Gap(10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildSummaryMetricCard('Partidas Jogadas', '$played'),
            _buildSummaryMetricCard('Aproveitamento', '$winPercentage%'),
            _buildSummaryMetricCard('Vitórias', '$wins'),
            _buildSummaryMetricCard('Derrotas', '$losses'),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.info),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const Gap(4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildElencoTab() {
    final squad = TeamSquads.getSquad(widget.teamName);
    
    // Agrupar elenco por posição
    final Map<String, List<String>> groupedSquad = {
      'Goleiros': [],
      'Defensores': [],
      'Meio-campistas': [],
      'Atacantes': []
    };

    for (final p in squad) {
      final pos = p['position']!;
      if (pos.startsWith('Gol')) {
        groupedSquad['Goleiros']!.add(p['name']!);
      } else if (pos.startsWith('Def')) {
        groupedSquad['Defensores']!.add(p['name']!);
      } else if (pos.startsWith('Mei')) {
        groupedSquad['Meio-campistas']!.add(p['name']!);
      } else {
        groupedSquad['Atacantes']!.add(p['name']!);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      children: groupedSquad.entries.where((e) => e.value.isNotEmpty).map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key.toUpperCase(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColor.primary, letterSpacing: 1.1),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColor.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.info),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entry.value.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColor.info),
                itemBuilder: (context, idx) {
                  final playerName = entry.value[idx];
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColor.info,
                      child: Icon(Icons.person, size: 16, color: Colors.white70),
                    ),
                    title: Text(
                      playerName,
                      style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      '#${1 + idx + (entry.key.hashCode % 90).abs()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const Gap(15),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPartidasTab(List<EventsModel> matches) {
    if (matches.isEmpty) {
      return const Center(
        child: Text('Nenhuma partida agendada ou jogada.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) {
        return CardFixtureItemReal(match: matches[index]);
      },
    );
  }

  Widget _buildEstatisticasTab(
    int played,
    int wins,
    int draws,
    int losses,
    int goalsScored,
    int goalsConceded,
    int cleanSheets,
    String winPercentage,
  ) {
    final avgScored = played > 0 ? (goalsScored / played).toStringAsFixed(1) : '0.0';
    final avgConceded = played > 0 ? (goalsConceded / played).toStringAsFixed(1) : '0.0';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.info),
          ),
          child: Column(
            children: [
              _buildStatMetricRow('Partidas Jogadas', '$played'),
              const Divider(color: AppColor.info, height: 24),
              _buildStatMetricRow('Vitórias', '$wins'),
              const Divider(color: AppColor.info, height: 24),
              _buildStatMetricRow('Empates', '$draws'),
              const Divider(color: AppColor.info, height: 24),
              _buildStatMetricRow('Derrotas', '$losses'),
              const Divider(color: AppColor.info, height: 24),
              _buildStatMetricRow('Gols Marcados', '$goalsScored ($avgScored por jogo)'),
              const Divider(color: AppColor.info, height: 24),
              _buildStatMetricRow('Gols Sofridos', '$goalsConceded ($avgConceded por jogo)'),
              const Divider(color: AppColor.info, height: 24),
              _buildStatMetricRow('Jogos sem Sofrer Gols (Clean sheets)', '$cleanSheets'),
              const Divider(color: AppColor.info, height: 24),
              _buildStatMetricRow('Aproveitamento', '$winPercentage%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
