part of '../screens.dart';

class WatchPage extends StatelessWidget {
  const WatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final news = NewsApi.aListNews;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Watch"),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(screenSearch),
            icon: SvgPicture.asset(
              Assets.searchLine,
              color: Colors.white,
              height: 25,
            ),
          ),
        ],
      ),
      body: news.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  Gap(15),
                  Text(
                    'Transmissões e vídeos em breve!',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                const Gap(10),
                SizedBox(
                  width: context.width,
                  height: context.height * .3,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (_, i) {
                      return CardNewsCarouselItemReal(news: news[i]);
                    },
                    separatorBuilder: (_, i) => const Gap(10),
                    itemCount: news.length,
                  ),
                ),
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Highlights',
                    style: context.textTheme.bodyMedium,
                  ),
                ),
                const Gap(20),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (_, i) {
                    return CardNewsItemReal(news: news[i]);
                  },
                  separatorBuilder: (_, i) => const Gap(15),
                  itemCount: news.length,
                ),
                const Gap(90),
              ],
            ),
    );
  }
}
