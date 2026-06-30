import 'package:app_mineiro/api/leagues_api.dart';
import 'package:app_mineiro/api/clubs_api.dart';
import 'package:app_mineiro/api/events_api.dart';
import 'package:app_mineiro/api/news_api.dart';
import 'package:app_mineiro/api/scorers_api.dart';

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
        ScorersApi.loadFromPocketBase(),
      ]);
      print("Todos os dados do PocketBase foram carregados com sucesso!");
    } catch (e) {
      print("Erro ao carregar dados do PocketBase: $e");
    }
  }
}

