part of '../screens.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIVE Match'),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        itemBuilder: (_, i) {
          return const CardGroupFixtureItem();
        },
        separatorBuilder: (_, i) => const Gap(20),
        itemCount: 5,
      ),
    );
  }
}
