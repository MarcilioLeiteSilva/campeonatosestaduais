import 'package:app_mineiro/models/events.dart';
import 'package:app_mineiro/services/pocketbase_client.dart';
import 'package:intl/intl.dart';

class EventsApi {
  static List<EventsModel> eListEvents = [];

  static Future<void> loadFromPocketBase() async {
    try {
      final pb = PocketBaseClient().client;
      final records = await pb.collection('fixtures').getFullList(
        sort: '-date',
        expand: 'homeTeamId,awayTeamId,leagueId',
      );
      if (records.isNotEmpty) {
        eListEvents = records.map((record) {
          final dateStr = record.data['date'] ?? '';
          String formattedDate = dateStr;
          try {
            final dateTime = DateTime.parse(dateStr).toLocal();
            formattedDate = DateFormat("dd/MM, HH:mm").format(dateTime);
          } catch (_) {}

          final homeList = record.expand['homeTeamId'];
          final homeTeamRecord = (homeList != null && homeList.isNotEmpty) ? homeList.first : null;
          final nameHome = homeTeamRecord?.data['name'] ?? '';
          final logoHome = homeTeamRecord?.data['logo'] ?? '';

          final awayList = record.expand['awayTeamId'];
          final awayTeamRecord = (awayList != null && awayList.isNotEmpty) ? awayList.first : null;
          final nameAway = awayTeamRecord?.data['name'] ?? '';
          final logoAway = awayTeamRecord?.data['logo'] ?? '';

          final leagueList = record.expand['leagueId'];
          final leagueRecord = (leagueList != null && leagueList.isNotEmpty) ? leagueList.first : null;
          final leagueExternalId = leagueRecord?.data['externalId'] != null
              ? (leagueRecord!.data['externalId'] as num).toInt()
              : -1;

          return EventsModel(
            id: record.id,
            nameHome: nameHome,
            nameAway: nameAway,
            logoHome: logoHome,
            logoAway: logoAway,
            scoreHome: record.data['homeGoals'] != null ? (record.data['homeGoals'] as num).toInt() : null,
            scoreAway: record.data['awayGoals'] != null ? (record.data['awayGoals'] as num).toInt() : null,
            dateMatch: formattedDate,
            timeMatch: record.data['statusShort'] ?? record.data['statusLong'] ?? '',
            leagueExternalId: leagueExternalId,
          );
        }).toList();
      }
    } catch (e) {
      print("Erro ao carregar partidas do PocketBase: $e");
    }
  }

}

