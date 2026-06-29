part of '../screens.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  int indexTab = 0;
  List<String> listTab = ["Matches", "Competitions", "Teams"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (_, i) {
          return [
            SliverAppBar(
              title: const Text('Favorites'),
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
              bottom: PreferredSize(
                preferredSize: Size(context.width, 48),
                child: Container(
                  width: context.width,
                  height: 48,
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
                          label: listTab[i],
                          onTap: () {
                            setState(() {
                              indexTab = i;
                            });
                          },
                        );
                      },
                      separatorBuilder: (_, i) => const Gap(10),
                      itemCount: 3,
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            const Gap(10),
            Expanded(
              child: [
                EventsApi.eListEvents.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma partida favoritada.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        itemBuilder: (_, i) {
                          return CardFixtureItemReal(match: EventsApi.eListEvents[i]);
                        },
                        separatorBuilder: (_, i) => const Gap(15),
                        itemCount: EventsApi.eListEvents.length,
                      ),
                LeaguesApi.lLeaguesList.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma competição favoritada.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        itemBuilder: (_, i) {
                          final league = LeaguesApi.lLeaguesList[i];
                          return Ink(
                            decoration: BoxDecoration(
                              color: AppColor.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColor.info, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 55,
                                    height: 55,
                                    child: league.logo.startsWith('http')
                                        ? Image.network(league.logo, fit: BoxFit.contain)
                                        : const CardNoImage(radius: 5),
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: Text(
                                      league.name,
                                      style: context.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, i) => const Gap(15),
                        itemCount: LeaguesApi.lLeaguesList.length,
                      ),
                ClubsApi.cListClubs.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum time favoritado.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        itemBuilder: (_, i) {
                          final team = ClubsApi.cListClubs[i];
                          return Ink(
                            decoration: BoxDecoration(
                              color: AppColor.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColor.info, width: 1),
                            ),
                            child: CardFollowItemReal(
                              team: team,
                              onTap: () {
                                // Opcional: ir para tela de perfil do time
                              },
                            ),
                          );
                        },
                        separatorBuilder: (_, i) => const Gap(15),
                        itemCount: ClubsApi.cListClubs.length,
                      ),
              ][indexTab],
            ),
          ],
        ),
      ),
    );
  }
}
