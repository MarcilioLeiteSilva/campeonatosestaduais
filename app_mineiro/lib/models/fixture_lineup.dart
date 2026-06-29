class FixtureLineupModel {
  final String id;
  final String fixtureId;
  final int fixtureExternalId;
  final String teamId; // 'home' ou 'away'
  final String formation;
  final String playerName;
  final int? playerNumber;
  final String playerPos;
  final bool isSubstitute;

  FixtureLineupModel({
    required this.id,
    required this.fixtureId,
    required this.fixtureExternalId,
    required this.teamId,
    required this.formation,
    required this.playerName,
    this.playerNumber,
    required this.playerPos,
    required this.isSubstitute,
  });
}
