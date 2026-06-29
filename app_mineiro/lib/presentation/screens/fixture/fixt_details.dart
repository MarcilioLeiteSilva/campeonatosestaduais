part of '../screens.dart';

class FixtureDetails extends StatefulWidget {
  const FixtureDetails({super.key, required this.match});
  final EventsModel match;

  @override
  State<FixtureDetails> createState() => _FixtureDetailsState();
}

class _FixtureDetailsState extends State<FixtureDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Partida'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        children: [
          CardFixtureDetail(match: widget.match),
          const Gap(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Informações Gerais',
              style: context.textTheme.headlineSmall!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Gap(12),
          CardBasicInfo(match: widget.match),
        ],
      ),
    );
  }
}
