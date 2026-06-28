import 'package:azul_football/api/leagues_api.dart';
import 'package:azul_football/api/clubs_api.dart';
import 'package:azul_football/api/events_api.dart';
import 'package:azul_football/api/news_api.dart';

class DataLoader {
  static Future<void> loadAllData() async {
    print("Iniciando carregamento de dados do PocketBase...");
    try {
      // Carrega em paralelo para melhor performance
      await Future.wait([
        LeaguesApi.loadFromPocketBase(),
        ClubsApi.loadFromPocketBase(),
        EventsApi.loadFromPocketBase(),
        NewsApi.loadFromPocketBase(),
      ]);
      print("Todos os dados do PocketBase foram carregados com sucesso!");
    } catch (e) {
      print("Erro ao carregar dados do PocketBase: $e");
    }
  }
}
