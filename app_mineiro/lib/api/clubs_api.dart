import 'package:app_mineiro/models/teams.dart';
import 'package:app_mineiro/services/pocketbase_client.dart';

class ClubsApi {
  static List<TeamsModel> cListClubs = [];

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
          externalId: record.data['externalId'] != null ? (record.data['externalId'] as num).toInt() : null,
        )).toList();
      }
    } catch (e) {
      print("Erro ao carregar times do PocketBase: $e");
    }
  }
}

