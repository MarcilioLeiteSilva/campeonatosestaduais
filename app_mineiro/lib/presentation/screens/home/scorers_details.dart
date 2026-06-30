part of '../screens.dart';

class ScorersDetailsScreen extends StatelessWidget {
  const ScorersDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artilharia'),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) {
          int activeLeagueId = state.selectedLeagueId;
          if (activeLeagueId == -1 && LeaguesApi.lLeaguesList.isNotEmpty) {
            activeLeagueId = LeaguesApi.lLeaguesList.first.id;
          }

          // Filtra os artilheiros pela liga selecionada (Módulo 1 = 629, Módulo 2 = 619)
          // Mas como leagueId nos scorers do pocketbase armazena a relação (e.g. e9z7nlg1797x2k5),
          // precisamos mapear a relation. Como já sabemos os IDs estáticos do PocketBase:
          // e9z7nlg1797x2k5 -> 629
          // 43hvars4zd2n41g -> 619
          final String targetLeaguePbId = activeLeagueId == 619 
              ? '43hvars4zd2n41g' 
              : 'e9z7nlg1797x2k5';

          final list = ScorersApi.sListScorers
              .where((s) => s.leagueId == targetLeaguePbId)
              .toList();

          // Ordena pelo ranking e gols
          list.sort((a, b) {
            final cmp = a.rank.compareTo(b.rank);
            if (cmp != 0) return cmp;
            return b.goals.compareTo(a.goals);
          });

          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum artilheiro cadastrado para esta liga.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.grey, height: 1),
            itemBuilder: (context, index) {
              final item = list[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    // Posição (Rank)
                    Container(
                      width: 30,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.rank}º',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: item.rank <= 3 ? AppColor.primary : Colors.white70,
                        ),
                      ),
                    ),
                    const Gap(10),
                    // Foto do Jogador
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColor.info,
                      backgroundImage: item.playerPhoto.isNotEmpty
                          ? NetworkImage(item.playerPhoto)
                          : null,
                      child: item.playerPhoto.isEmpty
                          ? const Icon(Icons.person, color: Colors.white70)
                          : null,
                    ),
                    const Gap(12),
                    // Nome e time do jogador
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.playerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            item.teamName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Gols
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColor.info,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item.goals}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                          ),
                          const Text(
                            'GOLS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
