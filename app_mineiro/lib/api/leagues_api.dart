import 'package:app_mineiro/models/leagues.dart';
import 'package:app_mineiro/services/pocketbase_client.dart';

class LeaguesApi {
  static List<LeaguesModels> lLeaguesList = [];

  static Future<void> loadFromPocketBase() async {
    try {
      final pb = PocketBaseClient().client;
      final records = await pb.collection('competitions').getFullList(
        sort: 'externalId',
      );
      if (records.isNotEmpty) {
        lLeaguesList = records.map((record) => LeaguesModels(
          id: record.data['externalId'],
          name: record.data['name'],
          logo: (record.data['logo'] != null && record.data['logo'].toString().startsWith('http'))
              ? record.data['logo']
              : 'assets/images/leagues/premier.png',
        )).toList();
      }
    } catch (e) {
      print("Erro ao carregar competições do PocketBase: $e");
    }
  }
}

