import 'package:app_mineiro/models/scorers.dart';
import 'package:app_mineiro/services/pocketbase_client.dart';

class ScorersApi {
  static List<ScorersModel> sListScorers = [];

  static Future<void> loadFromPocketBase() async {
    try {
      final pb = PocketBaseClient().client;
      final records = await pb.collection('scorers').getFullList(
        sort: 'rank,goals', // Ordena pelo ranking e gols
        expand: 'leagueId',
      );
      if (records.isNotEmpty) {
        sListScorers = records.map((record) {
          return ScorersModel.fromRecord(record.data, record.id);
        }).toList();
      } else {
        sListScorers = [];
      }
    } catch (e) {
      print("Erro ao carregar artilharia do PocketBase: $e");
    }
  }
}
