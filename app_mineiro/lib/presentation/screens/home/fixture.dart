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
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                state.showLiveOnly
                                    ? 'Nenhuma partida ao vivo no momento.'
                                    : (_isDateMode
                                        ? 'Nenhuma partida encontrada nesta data.'
                                        : 'Nenhuma partida encontrada nesta rodada.'),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            itemBuilder: (_, i) => CardFixtureItemReal(match: displayMatches[i]),
                            separatorBuilder: (_, __) => const Gap(10),
                            itemCount: displayMatches.length,
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
