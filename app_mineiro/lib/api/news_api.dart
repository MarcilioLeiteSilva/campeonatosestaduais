import 'package:app_mineiro/models/news.dart';
import 'package:app_mineiro/services/pocketbase_client.dart';

class NewsApi {
  static List<NewsModel> aListNews = [];

  static Future<void> loadFromPocketBase() async {
    try {
      final pb = PocketBaseClient().client;
      final records = await pb.collection('news').getFullList(
        sort: '-created',
      );
      if (records.isNotEmpty) {
        aListNews = records.map((record) => NewsModel(
          id: record.id,
          title: record.data['title'] ?? '',
          category: record.data['category'] ?? 'GERAL',
          image: record.data['image'] ?? 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=576',
          date: record.data['date'] ?? 'HOJE',
          body: record.data['body'] ?? '',
        )).toList();
      }
    } catch (e) {
      print("Erro ao carregar notícias do PocketBase: $e");
    }
  }
}

