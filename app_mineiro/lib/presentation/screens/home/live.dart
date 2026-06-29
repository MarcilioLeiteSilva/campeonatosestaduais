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
      body: EventsApi.eListEvents.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma partida cadastrada.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Builder(
              builder: (context) {
                final liveEvents = EventsApi.eListEvents.where((e) {
                  final status = e.timeMatch.toString().toUpperCase();
                  return status != 'FT' && status != 'NS' && status != '';
                }).toList();

                final displayEvents = liveEvents.isNotEmpty ? liveEvents : EventsApi.eListEvents;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  itemBuilder: (_, i) {
                    return CardFixtureItemReal(match: displayEvents[i]);
                  },
                  separatorBuilder: (_, i) => const Gap(15),
                  itemCount: displayEvents.length,
                );
              },
            ),
    );
  }
}
