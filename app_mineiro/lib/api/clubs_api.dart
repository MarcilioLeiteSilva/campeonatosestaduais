import 'package:azul_football/models/teams.dart';
import 'package:azul_football/services/pocketbase_client.dart';

class ClubsApi {
  static List<TeamsModel> cListClubs = [
    TeamsModel(
      id: 1062,
      logo: 'https://ssl.gstatic.com/onebox/media/sports/logos/1_8wDdf6L1PqH79u9ZfS0g_48x48.png',
      name: 'Atlético Mineiro',
      picked: true,
    ),
    TeamsModel(
      id: 135,
      logo: 'https://ssl.gstatic.com/onebox/media/sports/logos/pA81qH9E493b8uHhF0_N5w_48x48.png',
      name: 'Cruzeiro',
      picked: true,
    ),
    TeamsModel(
      id: 125,
      logo: 'https://ssl.gstatic.com/onebox/media/sports/logos/3vS8K-T6y5yKz4V_P7f5w_48x48.png',
      name: 'América Mineiro',
      picked: true,
    ),
    TeamsModel(
      id: 13975,
      logo: 'https://ssl.gstatic.com/onebox/media/sports/logos/r-5D7jO3QzU5L8S3_P7f5w_48x48.png',
      name: 'Athletic Club',
      picked: true,
    ),
    TeamsModel(
      id: 2227,
      logo: 'https://ssl.gstatic.com/onebox/media/sports/logos/7L_j5d7O3QzU5L8S3_P7f5w_48x48.png',
      name: 'Tombense',
      picked: true,
    ),
  ];

  static Future<void> loadFromPocketBase() async {
    try {
      final pb = PocketBaseClient().client;
      final records = await pb.collection('teams').getFullList(
        sort: 'name',
      );
      if (records.isNotEmpty) {
        cListClubs = records.map((record) => TeamsModel(
          id: record.data['externalId'],
          name: record.data['name'] ?? '',
          logo: record.data['logo'] ?? '',
          picked: record.data['picked'] ?? false,
        )).toList();
      }
    } catch (e) {
      print("Erro ao carregar times do PocketBase: $e");
    }
  }
}

