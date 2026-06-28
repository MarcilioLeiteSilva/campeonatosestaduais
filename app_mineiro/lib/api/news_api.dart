import 'package:app_mineiro/models/news.dart';
import 'package:app_mineiro/services/pocketbase_client.dart';

class NewsApi {
  static List<NewsModel> aListNews = [
    NewsModel(
      id: '1',
      date: '2 HORAS ATRÁS',
      title: 'Clássico Eletrizante: Atlético e Cruzeiro empatam em 2 a 2 na Arena MRV',
      category: 'MÓDULO I',
      image: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=576',
      body: 'Em um clássico repleto de emoções e rivalidade na Arena MRV, Atlético Mineiro e Cruzeiro empataram em 2 a 2 pelo Campeonato Mineiro Módulo I. O jogo foi disputado em altíssimo ritmo do primeiro ao último minuto.',
    ),
  ];

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

