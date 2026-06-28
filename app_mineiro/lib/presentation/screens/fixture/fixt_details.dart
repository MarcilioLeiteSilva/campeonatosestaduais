part of '../screens.dart';

class FixtureDetails extends StatefulWidget {
  const FixtureDetails({super.key});

  @override
  State<FixtureDetails> createState() => _FixtureDetailsState();
}

class _FixtureDetailsState extends State<FixtureDetails> {
  final _controller = ScrollController();

  int indexTab = 0;
  List<String> tabs = [
    "Info",
    "Summary",
    "Report",
    "Stats",
    "Lineups",
    "Table",
    "H2H"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _controller,
        headerSliverBuilder: (context, bol) {
          return [
            SliverAppBar(
              title: const Text('Match Details'),
              centerTitle: true,
              pinned: true,
              expandedHeight: context.height * .43,
              flexibleSpace: const FlexibleSpaceBar(
                background: Column(
                  children: [
                    Gap(115),
                    CardFixtureDetail(),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size(context.width, 43),
                child: Container(
                  width: context.width,
                  height: 45,
                  color: AppColor.background,
                  child: Material(
                    color: Colors.transparent,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
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
                ),
              ),
            ),
          ];
        },
        body: const [
          InfoFixPage(),
          SummaryFixPage(),
          ReportFixPage(),
          StatsFixPage(),
          LineupsFixPage(),
          TableFixPage(),
          H2hFixPage(),
        ][indexTab],
      ),
    );
  }
}
