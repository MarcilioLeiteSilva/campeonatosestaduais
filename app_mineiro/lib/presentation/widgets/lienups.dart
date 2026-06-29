part of 'widgets.dart';

class CardSubstitutionPlayers extends StatelessWidget {
  const CardSubstitutionPlayers({
    super.key,
    required this.homeSquad,
    required this.awaySquad,
  });

  final List<Map<String, String>> homeSquad;
  final List<Map<String, String>> awaySquad;

  @override
  Widget build(BuildContext context) {
    // Substitutos são os jogadores além dos 11 iniciais
    final homeSubs = homeSquad.length > 11 ? homeSquad.sublist(11) : homeSquad;
    final awaySubs = awaySquad.length > 11 ? awaySquad.sublist(11) : awaySquad;

    return Container(
      width: context.width,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColor.card,
        border: Border.all(color: AppColor.info, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JOGADORES RESERVAS',
            style: context.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reservas Mandante
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MANDANTE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColor.primary),
                    ),
                    const Gap(8),
                    ...homeSubs.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: PlayerSubstitutionPlayerItem(
                            number: '${12 + e.key}',
                            name: e.value['name']!,
                            isWhite: false,
                          ),
                        )),
                  ],
                ),
              ),
              const Gap(15),
              // Reservas Visitante
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VISITANTE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const Gap(8),
                    ...awaySubs.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: PlayerSubstitutionPlayerItem(
                            number: '${12 + e.key}',
                            name: e.value['name']!,
                            isWhite: true,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PlayerSubstitutionPlayerItem extends StatelessWidget {
  const PlayerSubstitutionPlayerItem({
    super.key,
    required this.number,
    required this.name,
    required this.isWhite,
  });

  final String number;
  final String name;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isWhite ? Colors.white : AppColor.background,
            border: Border.all(
              color: AppColor.info,
            ),
          ),
          width: 26,
          height: 26,
          alignment: Alignment.center,
          child: Text(
            number,
            style: context.textTheme.bodySmall!.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isWhite ? AppColor.background : Colors.white,
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall!.copyWith(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

class CardLineup extends StatelessWidget {
  const CardLineup({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeSquad,
    required this.awaySquad,
  });

  final String homeTeam;
  final String awayTeam;
  final List<Map<String, String>> homeSquad;
  final List<Map<String, String>> awaySquad;

  @override
  Widget build(BuildContext context) {
    // 11 iniciais de cada lado
    final hGK = homeSquad.isNotEmpty ? homeSquad[0]['name']! : 'Goleiro H';
    final hDef = homeSquad.length > 4 ? homeSquad.sublist(1, 5) : [];
    final hMid = homeSquad.length > 8 ? homeSquad.sublist(5, 8) : [];
    final hAtt = homeSquad.length > 11 ? homeSquad.sublist(8, 11) : [];

    final aGK = awaySquad.isNotEmpty ? awaySquad[0]['name']! : 'Goleiro A';
    final aDef = awaySquad.length > 4 ? awaySquad.sublist(1, 5) : [];
    final aMid = awaySquad.length > 8 ? awaySquad.sublist(5, 8) : [];
    final aAtt = awaySquad.length > 11 ? awaySquad.sublist(8, 11) : [];

    return SizedBox(
      width: context.width,
      height: context.height * .75,
      child: Stack(
        children: [
          // Campo tático de futebol de fundo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SvgPicture.asset(
                Assets.terrain,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                // Nome Mandante
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '$homeTeam (4-3-3)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                // Lado Mandante (Superior)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Goleiro Mandante
                      PlayerLineupItem(name: hGK, number: '1', isWhite: false),
                      // Defensores Mandante
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: hDef.asMap().entries.map((e) => PlayerLineupItem(
                              name: e.value['name']!,
                              number: '${2 + e.key}',
                              isWhite: false,
                            )).toList(),
                      ),
                      // Meio-campistas Mandante
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: hMid.asMap().entries.map((e) => PlayerLineupItem(
                              name: e.value['name']!,
                              number: '${6 + e.key}',
                              isWhite: false,
                            )).toList(),
                      ),
                      // Atacantes Mandante
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: hAtt.asMap().entries.map((e) => PlayerLineupItem(
                              name: e.value['name']!,
                              number: '${9 + e.key}',
                              isWhite: false,
                            )).toList(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 10, color: Colors.white30),
                // Lado Visitante (Inferior)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Atacantes Visitante
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: aAtt.asMap().entries.map((e) => PlayerLineupItem(
                              name: e.value['name']!,
                              number: '${9 + e.key}',
                              isWhite: true,
                            )).toList(),
                      ),
                      // Meio-campistas Visitante
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: aMid.asMap().entries.map((e) => PlayerLineupItem(
                              name: e.value['name']!,
                              number: '${6 + e.key}',
                              isWhite: true,
                            )).toList(),
                      ),
                      // Defensores Visitante
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: aDef.asMap().entries.map((e) => PlayerLineupItem(
                              name: e.value['name']!,
                              number: '${2 + e.key}',
                              isWhite: true,
                            )).toList(),
                      ),
                      // Goleiro Visitante
                      PlayerLineupItem(name: aGK, number: '1', isWhite: true),
                    ],
                  ),
                ),
                // Nome Visitante
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '$awayTeam (4-3-3)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerLineupItem extends StatelessWidget {
  const PlayerLineupItem({
    super.key,
    required this.name,
    required this.number,
    this.isWhite = false,
    this.hasYellow = false,
    this.hasRed = false,
    this.hasGoal = false,
  });

  final String name;
  final String number;
  final bool isWhite;
  final bool hasYellow, hasRed;
  final bool hasGoal;

  String _getFirstName(String fullName) {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundColor: !isWhite ? AppColor.primary : Colors.white,
              radius: 12,
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isWhite ? AppColor.background : Colors.white,
                ),
              ),
            ),
            if (hasYellow || hasRed)
              Positioned(
                right: -4,
                top: 0,
                child: Container(
                  width: 8,
                  height: 11,
                  decoration: BoxDecoration(
                    color: hasRed ? Colors.red : Colors.yellow,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            if (hasGoal)
              Positioned(
                left: -4,
                bottom: 0,
                child: const Icon(
                  Icons.sports_soccer,
                  size: 10,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        const Gap(4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _getFirstName(name),
            style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
