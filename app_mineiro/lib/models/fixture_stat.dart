class FixtureStatModel {
  final String id;
  final String fixtureId;
  final int fixtureExternalId;
  final String teamId; // 'home' ou 'away'
  final String statType;
  final String statValue;

  FixtureStatModel({
    required this.id,
    required this.fixtureId,
    required this.fixtureExternalId,
    required this.teamId,
    required this.statType,
    required this.statValue,
  });
}
