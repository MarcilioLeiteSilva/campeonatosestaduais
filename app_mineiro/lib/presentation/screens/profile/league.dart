part of '../screens.dart';

class LeagueProfileScreen extends StatefulWidget {
  const LeagueProfileScreen({super.key});

  @override
  State<LeagueProfileScreen> createState() => _LeagueProfileScreenState();
}

class _LeagueProfileScreenState extends State<LeagueProfileScreen> {
  int indexTab = 0;
  List<String> listLeague = [
    "Overview",
    "Matches",
    "Table",
    "News",
    "Player Stats"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premier League'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(Assets.star),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: context.width,
            height: 60,
            color: AppColor.background,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Material(
              color: Colors.transparent,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (_, i) {
                  return CardCheepTabSearch(
                    select: indexTab == i,
                    label: listLeague[i],
                    onTap: () {
                      setState(() {
                        indexTab = i;
                      });
                    },
                  );
                },
                separatorBuilder: (_, i) => const Gap(10),
                itemCount: listLeague.length,
              ),
            ),
          ),
          Expanded(
            child: const [
              OverviewPage(),
              MatchLeaguePage(),
              TableLeaguePage(),
              NewsLeaguePage(),
              TopScoreLeaguePage(),
            ][indexTab],
          ),
        ],
      ),
    );
  }
}
