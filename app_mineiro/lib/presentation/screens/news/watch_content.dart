part of '../screens.dart';

class WatchContentScreen extends StatefulWidget {
  const WatchContentScreen({super.key});

  @override
  State<WatchContentScreen> createState() => _WatchContentScreenState();
}

class _WatchContentScreenState extends State<WatchContentScreen> {
  late BetterPlayerController _betterPlayerController;
  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4");
    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(),
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(Assets.share),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(Assets.more),
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(
              controller: _betterPlayerController,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                const Gap(10),
                Text(
                  'Ronaldo denies mega-money AL Nassr deal is signed and sealed',
                  style: context.textTheme.bodyLarge,
                ),
                const Gap(10),
                Row(
                  children: [
                    Text(
                      '125k views - 10 hours ago',
                      style:
                          context.textTheme.labelSmall!.copyWith(fontSize: 13),
                    ),
                    const Gap(10),
                  ],
                ),
                const Gap(5),
                const Row(
                  children: [
                    Text(
                      '#football',
                      style: TextStyle(fontSize: 13, color: AppColor.primary),
                    ),
                    Gap(5),
                    Text(
                      '#worldcup',
                      style: TextStyle(fontSize: 13, color: AppColor.primary),
                    ),
                    Gap(5),
                    Text(
                      '#cristianoronaldo',
                      style: TextStyle(fontSize: 13, color: AppColor.primary),
                    ),
                  ],
                ),
                const Divider(height: 35),
                Text(
                  'Related News',
                  style: context.textTheme.bodyMedium,
                ),
                const Gap(10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (_, i) {
                    return const CardNewsItem();
                  },
                  separatorBuilder: (_, i) => const Gap(15),
                  itemCount: 5,
                ),
                const Gap(90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
