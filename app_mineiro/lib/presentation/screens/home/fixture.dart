part of '../screens.dart';

class FixturePage extends StatefulWidget {
  const FixturePage({super.key});

  @override
  State<FixturePage> createState() => _FixturePageState();
}

class _FixturePageState extends State<FixturePage> {
  int? _lastLeagueId;
  String? _selectedRound;
  bool _isDateMode = false;

  int getRoundSortOrder(String round) {
    if (round.startsWith('Regular Season - ')) {
      final numStr = round.replaceAll('Regular Season - ', '');
      return int.tryParse(numStr) ?? 0;
    }
    if (round == 'Troféu Inconfidência - Semi-finals') return 11;
    if (round == '5th place') return 12;
    if (round == 'Championship - Semi-finals') return 13;
    if (round == 'Final') return 14;
    return 99;
  }

  String _getDefaultRound(List<EventsModel> matches, List<String> sortedRounds) {
    if (sortedRounds.isEmpty) return '';
    for (final round in sortedRounds) {
      final roundMatches = matches.where((m) => m.round == round).toList();
      final hasOngoingOrUpcoming = roundMatches.any((m) {
        final status = m.timeMatch.toUpperCase();
        return status != 'FT' && status != 'PEN';
      });
      if (hasOngoingOrUpcoming) {
        return round;
      }
    }
    return sortedRounds.last;
  }

  Widget _buildRoundsSelector(List<String> rounds) {
    if (rounds.isEmpty || _selectedRound == null) return const SizedBox.shrink();
    final currentIndex = rounds.indexOf(_selectedRound!);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < rounds.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.info),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: hasPrev
                ? () {
                    setState(() {
                      _selectedRound = rounds[currentIndex - 1];
                    });
                  }
                : null,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: hasPrev ? AppColor.primary : Colors.grey,
              size: 20,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'RODADA ATIVA',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                ),
                const Gap(4),
                Text(
                  formatRoundName(_selectedRound!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: hasNext
                ? () {
                    setState(() {
                      _selectedRound = rounds[currentIndex + 1];
                    });
                  }
                : null,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: hasNext ? AppColor.primary : Colors.grey,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (_, ie) {
          return [
            SliverAppBar(
              title: const Text(AppText.appName),
              centerTitle: false,
              pinned: true,
              actions: [
                IconButton(
                  onPressed: () => context.pushNamed(screenSearch),
                  icon: SvgPicture.asset(
                    Assets.searchLine,
                    color: Colors.white,
                    height: 25,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    Assets.bell,
                    color: Colors.white,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CardSlideLeagueHome(),
                    Gap(15),
                    CardCalendarHome(),
                  ],
                ),
              ),
            ),
            BlocBuilder<SettingCubit, SettingState>(
              builder: (context, state) {
                if (!state.showCalendar) {
                  return const SliverToBoxAdapter();
                }
                return SliverPersistentHeader(
                  delegate: MyHeaderDelegate(state.selectedDate),
                );
              },
            ),
          ];
        },
        body: BlocListener<SettingCubit, SettingState>(
          listenWhen: (previous, current) {
            return previous.selectedLeagueId != current.selectedLeagueId ||
                previous.selectedDate != current.selectedDate ||
                previous.showLiveOnly != current.showLiveOnly;
          },
          listener: (context, state) {
            if (_lastLeagueId != state.selectedLeagueId) {
              setState(() {
                _lastLeagueId = state.selectedLeagueId;
                _isDateMode = false;
                if (state.showLiveOnly) {
                  context.read<SettingCubit>().toggleLiveOnly();
                }
                _selectedRound = null;
              });
            } else if (state.showLiveOnly) {
              setState(() {
                _isDateMode = false;
              });
            } else {
              setState(() {
                _isDateMode = true;
              });
            }
          },
          child: BlocBuilder<SettingCubit, SettingState>(
            builder: (context, state) {
              int activeLeagueId = state.selectedLeagueId;
              if (activeLeagueId == -1 && LeaguesApi.lLeaguesList.isNotEmpty) {
                activeLeagueId = LeaguesApi.lLeaguesList.first.id;
              }

              final filteredEvents = EventsApi.eListEvents.where((e) {
                if (activeLeagueId != -1 && e.leagueExternalId != activeLeagueId) {
                  return false;
                }
                return true;
              }).toList();

              if (filteredEvents.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Nenhuma partida encontrada.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              final uniqueRounds = filteredEvents.map((e) => e.round).toSet().toList();
              uniqueRounds.sort((a, b) => getRoundSortOrder(a).compareTo(getRoundSortOrder(b)));

              if (_selectedRound == null || !uniqueRounds.contains(_selectedRound)) {
                _selectedRound = _getDefaultRound(filteredEvents, uniqueRounds);
              }

              // Aplicar filtros correspondentes
              var displayMatches = filteredEvents;
              if (state.showLiveOnly) {
                displayMatches = displayMatches.where((m) {
                  final status = m.timeMatch.toString().toUpperCase();
                  return status != 'FT' && status != 'NS' && status != '';
                }).toList();
              } else if (_isDateMode) {
                displayMatches = displayMatches.where((m) {
                  if (m.dateTime != null) {
                    final matchDate = DateTime(m.dateTime!.year, m.dateTime!.month, m.dateTime!.day);
                    final selDate = DateTime(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day);
                    return matchDate.isAtSameMomentAs(selDate);
                  }
                  return false;
                }).toList();
              } else {
                // Modo Rodadas (Padrão)
                displayMatches = displayMatches.where((m) => m.round == _selectedRound).toList();
              }

              final bool isNormalRoundMode = !state.showLiveOnly && !_isDateMode;

              return Column(
                children: [
                  if (isNormalRoundMode) _buildRoundsSelector(uniqueRounds),
                  Expanded(
                    child: displayMatches.isEmpty
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Text(
                                    state.showLiveOnly
                                        ? 'Nenhuma partida ao vivo no momento.'
                                        : (_isDateMode
                                            ? 'Nenhuma partida encontrada nesta data.'
                                            : 'Nenhuma partida encontrada nesta rodada.'),
                                    style: const TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (isNormalRoundMode) CardScorersPreview(leagueId: activeLeagueId),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            itemCount: displayMatches.length + (isNormalRoundMode ? 1 : 0),
                            separatorBuilder: (_, __) => const Gap(10),
                            itemBuilder: (_, i) {
                              if (i == displayMatches.length) {
                                return CardScorersPreview(leagueId: activeLeagueId);
                              }
                              return CardFixtureItemReal(match: displayMatches[i]);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class CardScorersPreview extends StatelessWidget {
  const CardScorersPreview({super.key, required this.leagueId});
  final int leagueId;

  @override
  Widget build(BuildContext context) {
    // e9z7nlg1797x2k5 -> 629 (Módulo 1)
    // 43hvars4zd2n41g -> 619 (Módulo 2)
    final String targetLeaguePbId = leagueId == 619 
        ? '43hvars4zd2n41g' 
        : 'e9z7nlg1797x2k5';

    final list = ScorersApi.sListScorers
        .where((s) => s.leagueId == targetLeaguePbId)
        .toList();

    list.sort((a, b) {
      final cmp = a.rank.compareTo(b.rank);
      if (cmp != 0) return cmp;
      return b.goals.compareTo(a.goals);
    });

    final topThree = list.take(3).toList();

    if (topThree.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColor.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColor.info),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: AppColor.primary, size: 20),
                  Gap(8),
                  Text(
                    'ARTILHARIA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.pushNamed(screenScorers),
                child: const Row(
                  children: [
                    Text(
                      'Ver todos',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColor.primary,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(15),
          ...topThree.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  // Rank
                  Container(
                    width: 25,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${item.rank}º',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: item.rank <= 3 ? AppColor.primary : Colors.white70,
                      ),
                    ),
                  ),
                  const Gap(8),
                  // Foto
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColor.info,
                    backgroundImage: item.playerPhoto.isNotEmpty
                        ? NetworkImage(item.playerPhoto)
                        : null,
                    child: item.playerPhoto.isEmpty
                        ? const Icon(Icons.person, color: Colors.white70, size: 14)
                        : null,
                  ),
                  const Gap(10),
                  // Nome e Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.playerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          item.teamName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Gols
                  Text(
                    '${item.goals} gol${item.goals > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DateTime selectedDate;
  MyHeaderDelegate(this.selectedDate);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 10, bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SfDateRangePicker(
          onSelectionChanged: (DateRangePickerSelectionChangedArgs value) {
            var date = value.value as DateTime;
            context.read<SettingCubit>().updateCalendarDate(date);
          },
          selectionMode: DateRangePickerSelectionMode.single,
          backgroundColor: AppColor.info,
          allowViewNavigation: true,
          enableMultiView: false,
          headerHeight: 60,
          headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: AppColor.info,
            textStyle: context.textTheme.bodySmall,
          ),
          showNavigationArrow: true,
          initialSelectedDate: selectedDate,
          selectionTextStyle: context.textTheme.bodySmall,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 400.0;

  @override
  double get minExtent => 20.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
