part of '../screens.dart';

class FixturePage extends StatelessWidget {
  const FixturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
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
        body: BlocBuilder<SettingCubit, SettingState>(
          builder: (context, state) {
            final filteredEvents = EventsApi.eListEvents.where((e) {
              if (state.selectedLeagueId != -1 && e.leagueExternalId != state.selectedLeagueId) {
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

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemBuilder: (_, i) {
                return CardFixtureItemReal(match: filteredEvents[i]);
              },
              separatorBuilder: (_, i) => const Gap(15),
              itemCount: filteredEvents.length,
            );
          },
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
