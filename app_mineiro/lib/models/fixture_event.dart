class FixtureEventModel {
  final String id;
  final String fixtureId;
  final int time;
  final String teamId;
  final String player;
  final String assist;
  final String type;
  final String detail;

  FixtureEventModel({
    required this.id,
    required this.fixtureId,
    required this.time,
    required this.teamId,
    required this.player,
    required this.assist,
    required this.type,
    required this.detail,
  });
}
