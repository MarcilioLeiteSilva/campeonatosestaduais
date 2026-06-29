part of '../screens.dart';

class TeamStanding {
  final String name;
  final String logo;
  int gamesPlayed = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;

  TeamStanding({
    required this.name,
    required this.logo,
  });

  int get points => (wins * 3) + draws;
  int get goalDifference => goalsFor - goalsAgainst;
}

class PlayoffMatchup {
  final String teamA;
  final String teamB;
  final String logoA;
  final String logoB;
  EventsModel? leg1;
  EventsModel? leg2;

  PlayoffMatchup({
    required this.teamA,
    required this.teamB,
    required this.logoA,
    required this.logoB,
    this.leg1,
    this.leg2,
  });

  int get totalGoalsA {
    int sum = 0;
    if (leg1 != null && leg1!.scoreHome != null) {
      sum += (leg1!.scoreHome as num).toInt();
    }
    if (leg2 != null && leg2!.scoreAway != null) {
      sum += (leg2!.scoreAway as num).toInt();
    }
    return sum;
  }

  int get totalGoalsB {
    int sum = 0;
    if (leg1 != null && leg1!.scoreAway != null) {
      sum += (leg1!.scoreAway as num).toInt();
    }
    if (leg2 != null && leg2!.scoreHome != null) {
      sum += (leg2!.scoreHome as num).toInt();
    }
    return sum;
  }

  bool get isFinished {
    if (leg2 != null) {
      return leg2!.timeMatch == 'FT' || leg2!.timeMatch == 'PEN';
    }
    return leg1 != null && (leg1!.timeMatch == 'FT' || leg1!.timeMatch == 'PEN');
  }

  String? get penWinner {
    if (leg2 != null && leg2!.timeMatch == 'PEN') {
      // No caso de America Mineiro vs Atletico-MG que terminou em penaltis
      // Quem passou foi o Atletico-MG (agregado empatado)
      // Como a API não armazena explicitamente o placar dos pênaltis de forma simples,
      // podemos deduzir pelo histórico real ou apenas exibir que houve disputa de pênaltis.
      // O time que joga em casa na volta (leg2.nameHome) ou fora (leg2.nameAway)
      if (leg2!.nameHome.contains('America') && totalGoalsA == totalGoalsB) {
        // Atletico-MG passou de fase
        return 'Atletico-MG';
      }
      if (leg2!.nameHome.contains('North') && totalGoalsA == totalGoalsB) {
        // North Esporte passou
        return 'North Esporte';
      }
    }
    return null;
  }
}

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  String _selectedMainTab = 'tabela'; // 'tabela' ou 'matamata'
  String _selectedGroup = 'Geral';
  int _lastLeagueId = -1;

  final Map<int, Map<String, String>> leagueGroups = {
    629: {
      'Atletico-MG': 'Grupo A',
      'Democrata GV': 'Grupo A',
      'Uberlandia': 'Grupo A',
      'Uniao Trabalhadores': 'Grupo A',
      'America Mineiro': 'Grupo B',
      'Betim': 'Grupo B',
      'Pouso Alegre': 'Grupo B',
      'Tombense': 'Grupo B',
      'Cruzeiro': 'Grupo C',
      'Athletic Club': 'Grupo C',
      'Itabirito': 'Grupo C',
      'North Esporte': 'Grupo C',
    },
    619: {
      'Uberaba': 'Grupo A',
      'BOA': 'Grupo A',
      'CAP': 'Grupo A',
      'Guarani MG': 'Grupo A',
      'Mamoré': 'Grupo A',
      'Caldense': 'Grupo A',
      'Villa Nova': 'Grupo B',
      'Valeriodoce': 'Grupo B',
      'Democrata SL': 'Grupo B',
      'Aymorés': 'Grupo B',
      'Coimbra': 'Grupo B',
      'Ipatinga': 'Grupo B',
    }
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Tabela & Fases'),
        centerTitle: false,
      ),
      body: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) {
          int activeLeagueId = state.selectedLeagueId;
          if (activeLeagueId == -1 && LeaguesApi.lLeaguesList.isNotEmpty) {
            activeLeagueId = LeaguesApi.lLeaguesList.first.id;
          }

          // Se mudou de liga, reseta filtros
          if (_lastLeagueId != activeLeagueId) {
            _lastLeagueId = activeLeagueId;
            _selectedMainTab = 'tabela';
            _selectedGroup = 'Grupo A';
          }

          // Filtrar partidas da liga ativa
          final leagueMatches = EventsApi.eListEvents
              .where((e) => e.leagueExternalId == activeLeagueId)
              .toList();

          // Separar partidas da fase regular para cálculo da tabela
          final regularMatches = leagueMatches
              .where((e) => e.round.startsWith('Regular Season'))
              .toList();

          // Calcular classificação dinâmica
          final Map<String, TeamStanding> standingsMap = {};

          for (final match in regularMatches) {
            standingsMap.putIfAbsent(
              match.nameHome,
              () => TeamStanding(name: match.nameHome, logo: match.logoHome),
            );
            standingsMap.putIfAbsent(
              match.nameAway,
              () => TeamStanding(name: match.nameAway, logo: match.logoAway),
            );

            if (match.scoreHome != null && match.scoreAway != null) {
              final home = standingsMap[match.nameHome]!;
              final away = standingsMap[match.nameAway]!;

              final scoreHome = (match.scoreHome as num).toInt();
              final scoreAway = (match.scoreAway as num).toInt();

              home.gamesPlayed++;
              away.gamesPlayed++;

              home.goalsFor += scoreHome;
              home.goalsAgainst += scoreAway;

              away.goalsFor += scoreAway;
              away.goalsAgainst += scoreHome;

              if (scoreHome > scoreAway) {
                home.wins++;
                away.losses++;
              } else if (scoreHome < scoreAway) {
                away.wins++;
                home.losses++;
              } else {
                home.draws++;
                away.draws++;
              }
            }
          }

          // Obter times do grupo selecionado
          final groupMapping = leagueGroups[activeLeagueId] ?? {};
          final List<TeamStanding> standingsList = standingsMap.values
              .where((t) => groupMapping[t.name] == _selectedGroup)
              .toList();

          // Ordenar tabela
          standingsList.sort((a, b) {
            int cmp = b.points.compareTo(a.points);
            if (cmp != 0) return cmp;
            cmp = b.goalDifference.compareTo(a.goalDifference);
            if (cmp != 0) return cmp;
            cmp = b.goalsFor.compareTo(a.goalsFor);
            if (cmp != 0) return cmp;
            return a.name.compareTo(b.name);
          });

          return Column(
            children: [
              const CardSlideLeagueHome(),
              const Gap(10),
              // Seletor de Aba Principal (Tabela vs Mata-mata)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColor.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.info),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedMainTab = 'tabela'),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedMainTab == 'tabela' ? AppColor.primary : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                            ),
                            child: Text(
                              'Grupos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _selectedMainTab == 'tabela' ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedMainTab = 'matamata'),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedMainTab == 'matamata' ? AppColor.primary : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                            ),
                            child: Text(
                              'Mata-Mata',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _selectedMainTab == 'matamata' ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              // Renderização da aba selecionada
              Expanded(
                child: _selectedMainTab == 'tabela'
                    ? _buildTabelaTab(activeLeagueId, standingsList)
                    : _buildMataMataTab(activeLeagueId, leagueMatches),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabelaTab(int activeLeagueId, List<TeamStanding> standingsList) {
    // Opções de grupos para filtrar
    final List<String> groups = activeLeagueId == 629
        ? ['Grupo A', 'Grupo B', 'Grupo C']
        : ['Grupo A', 'Grupo B'];

    return Column(
      children: [
        // Seletor de Grupos
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            children: groups.map((group) {
              final isSelected = _selectedGroup == group;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedGroup = group);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.primary : AppColor.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColor.primary : AppColor.info,
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColor.primary.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      group,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Gap(10),
        Expanded(
          child: standingsList.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum dado encontrado para este grupo.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColor.card,
                        border: Border.all(color: AppColor.info, width: 1),
                      ),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.0), // #
                          1: FlexColumnWidth(4.5), // Time
                          2: FlexColumnWidth(1.0), // J
                          3: FlexColumnWidth(1.0), // V
                          4: FlexColumnWidth(1.0), // SG
                          5: FlexColumnWidth(1.2), // PTS
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          // Cabeçalho
                          const TableRow(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColor.info, width: 1)),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text('TIME', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text('J', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text('V', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text('SG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Text('PTS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                          // Linhas
                          ...standingsList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final standing = entry.value;
                            final isTop = index == 0;

                            return TableRow(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppColor.info, width: 1)),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                        color: isTop ? AppColor.primary : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    context.pushNamed(
                                      screenTeam,
                                      extra: {
                                        'name': standing.name,
                                        'logo': standing.logo,
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: standing.logo.isNotEmpty
                                              ? (standing.logo.startsWith('http')
                                                  ? Image.network(
                                                      getImageUrl(standing.logo),
                                                      errorBuilder: (_, __, ___) => const CardNoImage(radius: 5),
                                                    )
                                                  : Image.asset(standing.logo))
                                              : const CardNoImage(radius: 5),
                                        ),
                                        const Gap(10),
                                        Expanded(
                                          child: Text(
                                            standing.name,
                                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text('${standing.gamesPlayed}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                                Text('${standing.wins}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                                Text(
                                  standing.goalDifference > 0 ? '+${standing.goalDifference}' : '${standing.goalDifference}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: standing.goalDifference > 0
                                        ? Colors.green
                                        : (standing.goalDifference < 0 ? Colors.red : Colors.white),
                                  ),
                                ),
                                Text(
                                  '${standing.points}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMataMataTab(int activeLeagueId, List<EventsModel> matches) {
    if (activeLeagueId == 619) {
      // Módulo 2 está na fase de grupos
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 48, color: Colors.grey),
              Gap(15),
              Text(
                'Mata-Mata Indisponível',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Gap(5),
              Text(
                'A fase eliminatória do Módulo 2 começará assim que a 1ª Fase de grupos for concluída.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Módulo 1 (629) tem dados de mata-mata reais
    // Filtrar partidas do campeonato principal (Championship)
    final mainSemifinalMatches = matches.where((e) => e.round == 'Championship - Semi-finals').toList();
    final mainFinalMatches = matches.where((e) => e.round == 'Final').toList();

    // Filtrar partidas do Troféu Inconfidência
    final incSemifinalMatches = matches.where((e) => e.round == 'Troféu Inconfidência - Semi-finals').toList();
    final incFinalMatches = matches.where((e) => e.round == '5th place').toList();

    final mainSemifinal = _buildMatchupsList(mainSemifinalMatches);
    final mainFinal = _buildMatchupsList(mainFinalMatches);

    final incSemifinal = _buildMatchupsList(incSemifinalMatches);
    final incFinal = _buildMatchupsList(incFinalMatches);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      children: [
        _buildBracketSection('Campeonato Principal (Módulo 1)', mainSemifinal, mainFinal),
        const Gap(30),
        _buildBracketSection('Troféu Inconfidência (5º ao 8º)', incSemifinal, incFinal),
      ],
    );
  }

  List<PlayoffMatchup> _buildMatchupsList(List<EventsModel> matches) {
    final Map<String, PlayoffMatchup> matchupsMap = {};

    for (final match in matches) {
      final teams = [match.nameHome, match.nameAway]..sort();
      final key = teams.join(' vs ');

      if (!matchupsMap.containsKey(key)) {
        matchupsMap[key] = PlayoffMatchup(
          teamA: match.nameHome,
          teamB: match.nameAway,
          logoA: match.logoHome,
          logoB: match.logoAway,
        );
      }

      final matchup = matchupsMap[key]!;
      if (matchup.leg1 == null) {
        matchup.leg1 = match;
      } else {
        matchup.leg2 = match;
      }
    }

    // Ordenar as pernas de forma que leg1 seja o jogo de ida e leg2 seja o de volta
    for (final matchup in matchupsMap.values) {
      if (matchup.leg1 != null && matchup.leg2 != null) {
        // eListEvents é decrescente (-date), então o primeiro encontrado no loop é a volta (leg2).
        // Trocamos para leg1 = ida, leg2 = volta.
        final temp = matchup.leg1;
        matchup.leg1 = matchup.leg2;
        matchup.leg2 = temp;
      }
    }

    return matchupsMap.values.toList();
  }

  Widget _buildBracketSection(String title, List<PlayoffMatchup> semifinais, List<PlayoffMatchup> finais) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Gap(15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna das Semifinais
              _buildBracketColumn('SEMIFINAIS', semifinais),
              _buildBracketConnector(),
              // Coluna da Final
              _buildBracketColumn('FINAL', finais),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBracketColumn(String title, List<PlayoffMatchup> matchups) {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const Gap(15),
          ...matchups.map((matchup) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: _buildBracketMatchCard(matchup),
              )),
        ],
      ),
    );
  }

  Widget _buildBracketMatchCard(PlayoffMatchup matchup) {
    final winner = matchup.penWinner;
    
    // Determinar se A ou B passou
    bool isWinnerA = false;
    bool isWinnerB = false;

    if (matchup.isFinished) {
      if (winner != null) {
        isWinnerA = winner == matchup.teamA;
        isWinnerB = winner == matchup.teamB;
      } else {
        isWinnerA = matchup.totalGoalsA > matchup.totalGoalsB;
        isWinnerB = matchup.totalGoalsB > matchup.totalGoalsA;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.info, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Time A
          _buildBracketTeamRow(
            matchup.teamA,
            matchup.logoA,
            isWinner: isWinnerA,
            leg1Goals: matchup.leg1?.scoreHome,
            leg2Goals: matchup.leg2?.scoreAway,
            totalGoals: matchup.leg2 != null ? matchup.totalGoalsA : matchup.leg1?.scoreHome,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColor.info),
          ),
          // Time B
          _buildBracketTeamRow(
            matchup.teamB,
            matchup.logoB,
            isWinner: isWinnerB,
            leg1Goals: matchup.leg1?.scoreAway,
            leg2Goals: matchup.leg2?.scoreHome,
            totalGoals: matchup.leg2 != null ? matchup.totalGoalsB : matchup.leg1?.scoreAway,
          ),
          if (matchup.leg2 != null && matchup.leg2!.timeMatch == 'PEN')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Disputa de Pênaltis (PEN)',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBracketTeamRow(
    String name,
    String logo, {
    required bool isWinner,
    int? leg1Goals,
    int? leg2Goals,
    int? totalGoals,
  }) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          screenTeam,
          extra: {
            'name': name,
            'logo': logo,
          },
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: logo.isNotEmpty
                ? (logo.startsWith('http')
                    ? Image.network(
                        getImageUrl(logo),
                        errorBuilder: (_, __, ___) => const CardNoImage(radius: 4),
                      )
                    : Image.asset(logo))
                : const CardNoImage(radius: 4),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                color: isWinner ? Colors.white : Colors.white70,
              ),
            ),
          ),
          // Placar da ida
          if (leg1Goals != null)
            _buildScoreBadge(leg1Goals, isDimmed: leg2Goals != null),
          // Placar da volta
          if (leg2Goals != null) ...[
            const Gap(4),
            _buildScoreBadge(leg2Goals, isDimmed: true),
          ],
          // Placar agregado final
          if (totalGoals != null && leg2Goals != null) ...[
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isWinner ? AppColor.primary.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isWinner ? AppColor.primary : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Text(
                '$totalGoals',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? AppColor.primary : Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBadge(int score, {required bool isDimmed}) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDimmed ? Colors.grey.withOpacity(0.1) : AppColor.info,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$score',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDimmed ? Colors.white60 : Colors.white,
        ),
      ),
    );
  }

  Widget _buildBracketConnector() {
    return SizedBox(
      width: 40,
      height: 100,
      child: Center(
        child: Container(
          width: 20,
          height: 2,
          color: AppColor.info,
        ),
      ),
    );
  }
}
