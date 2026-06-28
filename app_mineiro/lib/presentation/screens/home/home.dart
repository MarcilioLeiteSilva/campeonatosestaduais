part of '../screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                width: context.width,
                height: context.height,
                child: [
                  const FixturePage(),
                  const FavoritePage(),
                  const NewsPage(),
                  const WatchPage(),
                  const AccountPage(),
                ][state.homeIndex],
              ),
              HomeNavBottom(index: state.homeIndex),
            ],
          );
        },
      ),
    );
  }
}
