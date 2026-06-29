part of '../screens.dart';

class FixtureDetails extends StatefulWidget {
  const FixtureDetails({super.key, required this.match});
  final EventsModel match;

  @override
  State<FixtureDetails> createState() => _FixtureDetailsState();
}

class _FixtureDetailsState extends State<FixtureDetails> {
  int indexTab = 0;
  bool isLoadingEvents = true;
  List<String> tabs = ["Resumo", "Estatísticas", "Escalações", "Confrontos"];

  @override
  void initState() {
    super.initState();
    _loadMatchEvents();
  }

  Future<void> _loadMatchEvents() async {
    setState(() {
      isLoadingEvents = true;
    });
    if (widget.match.id != null) {
      await EventsApi.loadEventsForFixture(widget.match.id);
    }
    if (mounted) {
      setState(() {
        isLoadingEvents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Partida'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Gap(10),
          CardFixtureDetail(match: widget.match),
          const Gap(15),
          Container(
            width: context.width,
            height: 48,
            color: AppColor.background,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
          const Gap(10),
          Expanded(
            child: [
              _buildSummaryTab(),
              _buildStatsTab(),
              _buildEmptyTab("Nenhuma escalação disponível para esta partida."),
              _buildEmptyTab("Nenhum confronto direto registrado para esta partida."),
            ][indexTab],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    if (isLoadingEvents) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      );
    }

    if (EventsApi.matchEvents.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum evento registrado nesta partida.',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: EventsApi.matchEvents.length,
      separatorBuilder: (_, __) => const Divider(color: AppColor.info, height: 20),
      itemBuilder: (context, index) {
        final event = EventsApi.matchEvents[index];

        IconData icon = Icons.sports_soccer;
        Color iconColor = Colors.white;

        if (event.type.toLowerCase() == 'goal') {
          icon = Icons.sports_soccer;
          iconColor = Colors.green;
        } else if (event.type.toLowerCase() == 'card') {
          icon = Icons.style;
          iconColor = event.detail.toLowerCase().contains('red') ? Colors.red : Colors.yellow;
        } else if (event.type.toLowerCase() == 'subst') {
          icon = Icons.swap_horiz;
          iconColor = Colors.blue;
        }

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColor.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColor.info),
              ),
              child: Text(
                "${event.time}'",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ),
            const Gap(15),
            Icon(icon, color: iconColor, size: 20),
            const Gap(15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.player,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  if (event.assist.isNotEmpty)
                    Text(
                      "Assistência: ${event.assist}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  if (event.detail.isNotEmpty && event.type.toLowerCase() != 'goal')
                    Text(
                      event.detail,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const Gap(15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    if (widget.match.oddsHome == null) {
      return _buildEmptyTab("Nenhum dado de estatística disponível para esta partida.");
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      children: [
        const Text(
          'Probabilidades do Confronto (Odds)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: AppColor.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.info),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOddCard("Vitória ${widget.match.nameHome}", widget.match.oddsHome!),
              _buildOddCard("Empate", widget.match.oddsDraw ?? 0.0),
              _buildOddCard("Vitória ${widget.match.nameAway}", widget.match.oddsAway!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOddCard(String label, double odd) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.primary.withOpacity(0.5)),
            ),
            child: Text(
              odd.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
