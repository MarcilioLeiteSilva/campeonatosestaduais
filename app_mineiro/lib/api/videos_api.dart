import 'package:app_mineiro/models/video.dart';
import 'package:app_mineiro/services/pocketbase_client.dart';

class VideosApi {
  static List<VideoModel> vListVideos = [];

  static Future<void> loadFromPocketBase() async {
    try {
      final pb = PocketBaseClient().client;
      final records = await pb.collection('videos').getFullList(
        sort: '-date',
      );
      vListVideos = records.map((record) => VideoModel(
        id: record.id,
        title: record.data['title'] ?? '',
        url: record.data['url'] ?? '',
        thumbnail: record.data['thumbnail'] ?? '',
        date: record.data['date'] ?? '',
        leagueId: record.data['leagueId']?.toString() ?? '',
        fixtureId: record.data['fixtureId']?.toString(),
        channelName: record.data['channelName'] ?? 'YouTube',
      )).toList();
    } catch (e) {
      print("Erro ao carregar vídeos do PocketBase: $e");
      vListVideos = [];
    }
  }
}
