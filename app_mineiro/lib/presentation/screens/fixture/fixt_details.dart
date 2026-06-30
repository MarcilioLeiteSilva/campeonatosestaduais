part of '../screens.dart';

class FixtureDetails extends StatefulWidget {
  const FixtureDetails({super.key, required this.match});
  final EventsModel match;

  @override
  State<FixtureDetails> createState() => _FixtureDetailsState();
}

class _FixtureDetailsState extends State<FixtureDetails> {
  int indexTab = 0;
  bool isLoadingEvents = true;
  List<String> tabs = ["Resumo", "Estatísticas", "Escalações", "Confrontos"];

  @override
  void initState() {
    super.initState();
    _loadMatchEvents();
  }

  Future<void> _loadMatchEvents() async {
    setState(() {
      isLoadingEvents = true;
    });
    if (widget.match.id != null) {
      await Future.wait([
        EventsApi.loadEventsForFixture(widget.match.id),
        EventsApi.loadLineupsForFixture(widget.match.id),
        EventsApi.loadStatisticsForFixture(widget.match.id),
      ]);
    }
    if (mounted) {
      setState(() {
        isLoadingEvents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Partida'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Gap(10),
          CardFixtureDetail(match: widget.match),
          const Gap(15),
          Container(
            width: context.width,
            height: 48,
            color: AppColor.background,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
          const Gap(10),
          Expanded(
            child: [
              _buildSummaryTab(),
              _buildStatsTab(),
              _buildLineupsTab(),
              _buildEmptyTab("Nenhum confronto direto registrado para esta partida."),
            ][indexTab],
          ),
        ],
      ),
    );
  }

  Widget _buildLineupsTab() {
    final bool isFuture = widget.match.dateTime != null && widget.match.dateTime!.isAfter(DateTime.now());
    final bool hasStarted = (widget.match.scoreHome != null && widget.match.scoreAway != null) || (widget.match.elapsed != null && widget.match.elapsed! > 0);
    
    if ((isFuture || !hasStarted) && EventsApi.matchLineups.isEmpty) {
      return _buildEmptyTab("Escalações ainda não disponíveis para esta partida.");
    }

    List<Map<String, String>> homeSquad;
    List<Map<String, String>> awaySquad;

    if (EventsApi.matchLineups.isNotEmpty) {
      homeSquad = _buildSquadFromDb('home');
      awaySquad = _buildSquadFromDb('away');
    } else {
      homeSquad = TeamSquads.getSquad(widget.match.nameHome);
      awaySquad = TeamSquads.getSquad(widget.match.nameAway);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      children: [
        CardLineup(
          homeTeam: widget.match.nameHome,
          awayTeam: widget.match.nameAway,
          homeSquad: homeSquad,
          awaySquad: awaySquad,
        ),
        const Gap(20),
        CardSubstitutionPlayers(
          homeSquad: homeSquad,
          awaySquad: awaySquad,
        ),
        const Gap(30),
      ],
    );
  }

  Widget _buildSummaryTab() {
    if (isLoadingEvents) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      );
    }

    if (EventsApi.matchEvents.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum evento registrado nesta partida.',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: EventsApi.matchEvents.length,
      separatorBuilder: (_, __) => const Divider(color: AppColor.info, height: 20),
      itemBuilder: (context, index) {
        final event = EventsApi.matchEvents[index];

        IconData icon = Icons.sports_soccer;
        Color iconColor = Colors.white;

        if (event.type.toLowerCase() == 'goal') {
          icon = Icons.sports_soccer;
          iconColor = Colors.green;
        } else if (event.type.toLowerCase() == 'card') {
          icon = Icons.style;
          iconColor = event.detail.toLowerCase().contains('red') ? Colors.red : Colors.yellow;
        } else if (event.type.toLowerCase() == 'subst') {
          icon = Icons.swap_horiz;
          iconColor = Colors.blue;
        }

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColor.info),
              ),
              child: Text(
                "${event.time}'",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ),
            const Gap(15),
            Icon(icon, color: iconColor, size: 20),
            const Gap(15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.player,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  if (event.assist.isNotEmpty)
                    Text(
                      "Assistência: ${event.assist}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  if (event.detail.isNotEmpty && event.type.toLowerCase() != 'goal')
                    Text(
                      event.detail,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const Gap(15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  List<MatchStatItem> _generateStats(EventsModel match) {
    final rand = Random(match.id.hashCode);
    final isFinished = match.timeMatch == 'FT' || match.timeMatch == 'PEN';
    if (!isFinished) return [];

    final int sh = match.scoreHome != null ? (match.scoreHome as num).toInt() : 0;
    final int sa = match.scoreAway != null ? (match.scoreAway as num).toInt() : 0;

    int homePossession = 50 + (sh - sa) * 3 + (rand.nextInt(10) - 5);
    homePossession = homePossession.clamp(35, 65).toInt();
    final int awayPossession = 100 - homePossession;

    final int homeShots = 8 + sh * 2 + rand.nextInt(5);
    final int awayShots = 7 + sa * 2 + rand.nextInt(5);

    final int homeFouls = 10 + rand.nextInt(8);
    final int awayFouls = 11 + rand.nextInt(8);

    final int homeCorners = 3 + rand.nextInt(6);
    final int awayCorners = 2 + rand.nextInt(6);

    final int homeYellows = 1 + rand.nextInt(4);
    final int awayYellows = 2 + rand.nextInt(4);

    final int homeReds = rand.nextInt(10) > 8 ? 1 : 0;
    final int awayReds = rand.nextInt(10) > 8 ? 1 : 0;

    return [
      MatchStatItem(label: 'Posse de Bola', homeVal: homePossession, awayVal: awayPossession, isPercentage: true),
      MatchStatItem(label: 'Finalizações', homeVal: homeShots, awayVal: awayShots),
      MatchStatItem(label: 'Faltas', homeVal: homeFouls, awayVal: awayFouls),
      MatchStatItem(label: 'Escanteios', homeVal: homeCorners, awayVal: awayCorners),
      MatchStatItem(label: 'Cartões Amarelos', homeVal: homeYellows, awayVal: awayYellows),
      MatchStatItem(label: 'Cartões Vermelhos', homeVal: homeReds, awayVal: awayReds),
    ];
  }

  Widget _buildStatRow(MatchStatItem stat) {
    final total = stat.homeVal + stat.awayVal;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.isPercentage ? '${stat.homeVal}%' : '${stat.homeVal}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
              Text(
                stat.label.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
              ),
              Text(
                stat.isPercentage ? '${stat.awayVal}%' : '${stat.awayVal}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ],
          ),
          const Gap(6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: stat.homeVal,
                    child: Container(color: AppColor.primary),
                  ),
                  Expanded(
                    flex: stat.awayVal,
                    child: Container(color: Colors.white24),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final stats = EventsApi.matchStats.isNotEmpty 
        ? _buildStatsFromDb() 
        : _generateStats(widget.match);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      children: [
        if (stats.isNotEmpty) ...[
          const Text(
            'Estatísticas Detalhadas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColor.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.info),
            ),
            child: Column(
              children: stats.map((s) => _buildStatRow(s)).toList(),
            ),
          ),
          const Gap(25),
        ],
        if (widget.match.oddsHome != null) ...[
          const Text(
            'Probabilidades do Confronto (Odds)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColor.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.info),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOddCard("Vitória ${widget.match.nameHome}", widget.match.oddsHome!),
                _buildOddCard("Empate", widget.match.oddsDraw ?? 0.0),
                _buildOddCard("Vitória ${widget.match.nameAway}", widget.match.oddsAway!),
              ],
            ),
          ),
        ] else if (stats.isEmpty)
          _buildEmptyTab("Nenhum dado de estatística disponível para esta partida.")
      ],
    );
  }

  Widget _buildOddCard(String label, double odd) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.primary.withOpacity(0.5)),
            ),
            child: Text(
              odd.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _buildSquadFromDb(String teamType) {
    final teamPlayers = EventsApi.matchLineups.where((p) => p.teamId == teamType).toList();
    if (teamPlayers.isEmpty) return [];

    final starters = teamPlayers.where((p) => !p.isSubstitute).toList();
    final substitutes = teamPlayers.where((p) => p.isSubstitute).toList();

    final gk = starters.where((p) => p.playerPos.toUpperCase().contains('GOL')).toList();
    final def = starters.where((p) => _isDef(p.playerPos)).toList();
    final mid = starters.where((p) => _isMid(p.playerPos)).toList();
    final att = starters.where((p) => _isAtt(p.playerPos)).toList();

    final sortedStarters = <FixtureLineupModel>[];
    sortedStarters.addAll(gk);
    sortedStarters.addAll(def);
    sortedStarters.addAll(mid);
    sortedStarters.addAll(att);

    for (final p in starters) {
      if (!sortedStarters.contains(p)) {
        sortedStarters.add(p);
      }
    }

    final result = sortedStarters.map<Map<String, String>>((p) => {
      'name': p.playerName,
      'position': _getPosDesc(p.playerPos),
    }).toList();

    result.addAll(substitutes.map<Map<String, String>>((p) => {
      'name': p.playerName,
      'position': _getPosDesc(p.playerPos),
    }));

    return result;
  }

  bool _isDef(String pos) {
    final upper = pos.toUpperCase();
    return upper.contains('LAD') || upper.contains('LAE') || upper.contains('ZAD') || upper.contains('ZAE') || upper.contains('ZAG') || upper.contains('DEF');
  }

  bool _isMid(String pos) {
    final upper = pos.toUpperCase();
    return upper.contains('VOL') || upper.contains('MEC') || upper.contains('MID') || upper.contains('MEI');
  }

  bool _isAtt(String pos) {
    final upper = pos.toUpperCase();
    return upper.contains('ATA') || upper.contains('ATT') || upper.contains('CENTROAVANTE') || upper.contains('PONT') || upper.contains('MEI-AT');
  }

  String _getPosDesc(String pos) {
    if (pos.toUpperCase().contains('GOL')) return 'Goleiro';
    if (_isDef(pos)) return 'Defensor';
    if (_isMid(pos)) return 'Meio-campista';
    return 'Atacante';
  }

  List<MatchStatItem> _buildStatsFromDb() {
    final homeStats = EventsApi.matchStats.where((s) => s.teamId == 'home').toList();
    final awayStats = EventsApi.matchStats.where((s) => s.teamId == 'away').toList();

    if (homeStats.isEmpty && awayStats.isEmpty) return [];

    final statTypes = [
      'Posse de Bola',
      'Finalizações',
      'Faltas',
      'Escanteios',
      'Cartões Amarelos',
      'Cartões Vermelhos',
      'Desarmes',
      'Defesas',
      'Passes',
    ];

    final List<MatchStatItem> result = [];

    for (final type in statTypes) {
      final homeStat = homeStats.firstWhere((s) => s.statType == type, orElse: () => FixtureStatModel(id: '', fixtureId: '', fixtureExternalId: 0, teamId: 'home', statType: type, statValue: '0'));
      final awayStat = awayStats.firstWhere((s) => s.statType == type, orElse: () => FixtureStatModel(id: '', fixtureId: '', fixtureExternalId: 0, teamId: 'away', statType: type, statValue: '0'));

      final homeClean = homeStat.statValue.replaceAll('%', '').trim();
      final awayClean = awayStat.statValue.replaceAll('%', '').trim();

      int homeVal = int.tryParse(homeClean) ?? 0;
      int awayVal = int.tryParse(awayClean) ?? 0;

      if (type == 'Posse de Bola' && homeVal == 0 && awayVal == 0) {
        homeVal = 50;
        awayVal = 50;
      }

      result.add(MatchStatItem(
        label: type,
        homeVal: homeVal,
        awayVal: awayVal,
        isPercentage: type == 'Posse de Bola',
      ));
    }

    return result;
  }
}

class MatchStatItem {
  final String label;
  final int homeVal;
  final int awayVal;
  final bool isPercentage;

  MatchStatItem({
    required this.label,
    required this.homeVal,
    required this.awayVal,
    this.isPercentage = false,
  });
}
