part of 'screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final startTime = DateTime.now();
    try {
      await DataLoader.loadAllData();
    } catch (e) {
      print("Erro ao carregar dados do PocketBase: $e");
    }
    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(seconds: 3) - elapsed;
    if (remaining.isNegative) {
      if (mounted) context.pushReplacementNamed(screenHome);
    } else {
      Future.delayed(remaining).then((_) {
        if (mounted) context.pushReplacementNamed(screenHome);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.mineiroLogo,
                    width: 130,
                    height: 130,
                  ),
                  const Gap(15),
                  Text(AppText.appName,
                      style: context.textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            LoadingAnimationWidget.hexagonDots(
              color: AppColor.primary,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
