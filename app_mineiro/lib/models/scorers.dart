class ScorersModel {
  final String id;
  final String leagueId;
  final int season;
  final int rank;
  final String playerName;
  final String playerPhoto;
  final String teamName;
  final String teamLogo;
  final int goals;
  final int assists;
  final int? externalPlayerId;

  ScorersModel({
    required this.id,
    required this.leagueId,
    required this.season,
    required this.rank,
    required this.playerName,
    required this.playerPhoto,
    required this.teamName,
    required this.teamLogo,
    required this.goals,
    required this.assists,
    this.externalPlayerId,
  });

  factory ScorersModel.fromRecord(Map<String, dynamic> data, String recordId) {
    return ScorersModel(
      id: recordId,
      leagueId: data['leagueId'] ?? '',
      season: data['season'] != null ? (data['season'] as num).toInt() : 2026,
      rank: data['rank'] != null ? (data['rank'] as num).toInt() : 0,
      playerName: data['playerName'] ?? '',
      playerPhoto: data['playerPhoto'] ?? '',
      teamName: data['teamName'] ?? '',
      teamLogo: data['teamLogo'] ?? '',
      goals: data['goals'] != null ? (data['goals'] as num).toInt() : 0,
      assists: data['assists'] != null ? (data['assists'] as num).toInt() : 0,
      externalPlayerId: data['externalPlayerId'] != null ? (data['externalPlayerId'] as num).toInt() : null,
    );
  }
}
