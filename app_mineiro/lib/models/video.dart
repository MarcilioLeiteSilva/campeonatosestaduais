class VideoModel {
  final String id;
  final String title;
  final String url;
  final String thumbnail;
  final String date;
  final String leagueId;
  final String? fixtureId;
  final String channelName;

  VideoModel({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnail,
    required this.date,
    required this.leagueId,
    this.fixtureId,
    required this.channelName,
  });
}
