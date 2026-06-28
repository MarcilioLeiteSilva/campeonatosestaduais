import 'package:app_mineiro/models/events.dart';
import 'package:app_mineiro/services/pocketbase_client.dart';
import 'package:intl/intl.dart';

class EventsApi {
  static List<EventsModel> eListEvents = [
    EventsModel(
      id: '0',
      logoAway: 'https://ssl.gstatic.com/onebox/media/sports/logos/pA81qH9E493b8uHhF0_N5w_48x48.png', // Cruzeiro
      logoHome: 'https://ssl.gstatic.com/onebox/media/sports/logos/1_8wDdf6L1PqH79u9ZfS0g_48x48.png', // Atlético Mineiro
      nameAway: 'Cruzeiro',
      nameHome: 'Atlético Mineiro',
      scoreAway: 2,
      scoreHome: 2,
      dateMatch: 'Hoje, 16:00',
      timeMatch: '90+5',
    ),
  ];

  static Future<void> loadFromPocketBase() async {
    try {
      final pb = PocketBaseClient().client;
      final records = await pb.collection('fixtures').getFullList(
        sort: '-date',
        expand: 'homeTeamId,awayTeamId',
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
          );
        }).toList();
      }
    } catch (e) {
      print("Erro ao carregar partidas do PocketBase: $e");
    }
  }

}

