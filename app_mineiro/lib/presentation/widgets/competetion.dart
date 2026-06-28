part of 'widgets.dart';

class MatchLeaguePage extends StatelessWidget {
  const MatchLeaguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemBuilder: (_, i) {
        return const CardMatchLeague();
      },
      separatorBuilder: (_, i) => const Gap(10),
      itemCount: 3,
    );
  }
}

class CardMatchLeague extends StatelessWidget {
  const CardMatchLeague({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today, 26 December',
          style: context.textTheme.bodySmall,
        ),
        const Gap(15),
        ListView.separated(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 10,
          ),
          itemBuilder: (_, i) {
            return Ink(
              decoration: BoxDecoration(
                color: AppColor.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.info, width: 1),
              ),
              child: const CardFollowItem(),
            );
          },
          separatorBuilder: (_, i) => const Gap(15),
          itemCount: 3,
        ),
      ],
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today. 30 December',
              style: context.textTheme.bodySmall,
            ),
            TextButton.icon(
              onPressed: () {},
              label: const Icon(Icons.arrow_forward),
              icon: Text(
                'See all',
                style: context.textTheme.bodySmall!.copyWith(
                  color: AppColor.primary,
                ),
              ),
            ),
          ],
        ),
        const Gap(5),
        ListView.separated(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (_, i) {
            return Ink(
              width: context.width,
              decoration: BoxDecoration(
                color: AppColor.card,
                border: Border.all(
                  color: AppColor.info,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.only(
                left: 15,
                top: 15,
                bottom: 10,
              ),
              child: const CardFixtureItem(showDivider: false),
            );
          },
          separatorBuilder: (_, i) => const Gap(10),
          itemCount: 3,
        ),
        const Gap(20),
        Text(
          'Top Scores',
          style: context.textTheme.bodySmall,
        ),
        const Gap(20),
        Container(
          width: context.width,
          decoration: BoxDecoration(
            color: AppColor.card,
            border: Border.all(
              color: AppColor.info,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (_, i) {
              return const CardTopScores();
            },
            separatorBuilder: (_, i) => const Divider(height: 30),
            itemCount: 5,
          ),
        ),
        const Gap(50),
      ],
    );
  }
}

class CardTopScores extends StatelessWidget {
  const CardTopScores({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '1',
          style: context.textTheme.bodySmall,
        ),
        const Gap(10),
        const SizedBox(
          width: 35,
          height: 35,
          child: CardNoImage(radius: 5),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mouad Zizi',
                style: context.textTheme.bodySmall!.copyWith(
                  fontSize: 16,
                ),
              ),
              Text(
                'Morocco',
                style: context.textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Text(
          '18',
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class TableLeaguePage extends StatelessWidget {
  const TableLeaguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      children: [
        Container(
          width: context.width,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColor.card,
            border: Border.all(color: AppColor.info, width: 1),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(4),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            children: [
              const TableRow(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    color: AppColor.info,
                    width: 1,
                  )),
                ),
                children: [
                  TableTileItem(
                    '#',
                    padding: EdgeInsets.only(bottom: 15),
                    isCrossCenter: true,
                  ),
                  TableTileItem(
                    'TEAM',
                    padding: EdgeInsets.only(bottom: 15),
                  ),
                  TableTileItem(
                    'P',
                    padding: EdgeInsets.only(bottom: 15),
                  ),
                  TableTileItem(
                    'GD',
                    padding: EdgeInsets.only(bottom: 15),
                  ),
                  TableTileItem(
                    'PTS',
                    padding: EdgeInsets.only(bottom: 15),
                  ),
                ],
              ),
              for (int i = 0; i < 15; i++)
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                      color: AppColor.info,
                      width: 1,
                    )),
                  ),
                  children: [
                    TableTileItem(
                      '${i + 1}',
                      isTop: [0, 1, 2].contains(i),
                      isCrossCenter: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: CardNoImage(radius: 5),
                          ),
                          Gap(10),
                          Expanded(
                            child: Text('TEAM', style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                    const TableTileItem('14'),
                    const TableTileItem('22'),
                    const TableTileItem('27'),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class TableTileItem extends StatelessWidget {
  const TableTileItem(
    this.text, {
    super.key,
    this.padding,
    this.isTop = false,
    this.isCrossCenter = false,
  });
  final String text;
  final EdgeInsetsGeometry? padding;
  final bool isTop;
  final bool isCrossCenter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: isTop ? 10 : 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isCrossCenter
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 15)),
          if (isTop) ...[
            const Gap(3),
            Container(
              width: 28,
              height: 5,
              decoration: const BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  )),
            ),
          ]
        ],
      ),
    );
  }
}

class NewsLeaguePage extends StatelessWidget {
  const NewsLeaguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemBuilder: (_, i) {
        return const CardNewsItem();
      },
      separatorBuilder: (_, i) => const Gap(15),
      itemCount: 10,
    );
  }
}

///TOP SCORES

class TopScoreLeaguePage extends StatefulWidget {
  const TopScoreLeaguePage({super.key});

  @override
  State<TopScoreLeaguePage> createState() => _TopScoreLeaguePageState();
}

class _TopScoreLeaguePageState extends State<TopScoreLeaguePage>
    with TickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            color: AppColor.background,
            child: TabBar(
              controller: controller,
              isScrollable: true,
              tabs: const [
                Tab(child: Text('All')),
                Tab(child: Text('Goals')),
                Tab(child: Text('Assists')),
                Tab(child: Text('Yellow Cards')),
                Tab(child: Text('Red Cards')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: [
                TopScoreAllPage(
                  onTap: (int value) {
                    controller.animateTo(value + 1);
                  },
                ),
                const TopScoresList(),
                const TopScoresList(),
                const TopScoresList(),
                const TopScoresList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopScoresList extends StatelessWidget {
  const TopScoresList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      itemBuilder: (_, i) {
        return Ink(
          width: context.width,
          decoration: BoxDecoration(
            color: AppColor.card,
            border: Border.all(
              color: AppColor.info,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: const CardTopScores(),
        );
      },
      separatorBuilder: (_, i) => const Gap(15),
      itemCount: 15,
    );
  }
}

class TopScoreAllPage extends StatelessWidget {
  const TopScoreAllPage({super.key, required this.onTap});
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      children: [
        CardTopScoreItem(
          label: 'GOALS',
          onAll: () {
            onTap(0);
          },
        ),
        const Gap(20),
        CardTopScoreItem(
          label: 'ASSITS',
          onAll: () {
            onTap(1);
          },
        ),
        const Gap(20),
        CardTopScoreItem(
          label: 'YELLOW CARDS',
          onAll: () {
            onTap(2);
          },
        ),
        const Gap(20),
        CardTopScoreItem(
          label: 'RED CARDS',
          onAll: () {
            onTap(3);
          },
        ),
      ],
    );
  }
}

class CardTopScoreItem extends StatelessWidget {
  const CardTopScoreItem({super.key, required this.label, required this.onAll});
  final String label;
  final Function() onAll;

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: context.width,
      decoration: BoxDecoration(
        color: AppColor.card,
        border: Border.all(
          color: AppColor.info,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall,
          ),
          const Divider(height: 30),
          ListView.separated(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (_, i) {
              return const CardTopScores();
            },
            separatorBuilder: (_, i) => const Divider(height: 30),
            itemCount: 5,
          ),
          const Divider(height: 30),
          Center(
            child: InkWell(
              onTap: onAll,
              child: Text(
                'See All',
                style: context.textTheme.bodySmall!.copyWith(
                  color: AppColor.primary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
