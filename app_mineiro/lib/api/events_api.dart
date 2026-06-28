import 'package:azul_football/models/events.dart';
import 'package:azul_football/services/pocketbase_client.dart';
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
      );
      if (records.isNotEmpty) {
        eListEvents = records.map((record) {
          final dateStr = record.data['date'] ?? '';
          String formattedDate = dateStr;
          try {
            final dateTime = DateTime.parse(dateStr).toLocal();
            formattedDate = DateFormat("dd/MM, HH:mm").format(dateTime);
          } catch (_) {}

          return EventsModel(
            id: record.id,
            nameHome: record.data['homeTeamName'] ?? '',
            nameAway: record.data['awayTeamName'] ?? '',
            logoHome: record.data['homeTeamLogo'] ?? '',
            logoAway: record.data['awayTeamLogo'] ?? '',
            scoreHome: record.data['homeScore'] != null ? record.data['homeScore'] as int : null,
            scoreAway: record.data['awayScore'] != null ? record.data['awayScore'] as int : null,
            dateMatch: formattedDate,
            timeMatch: record.data['status'] ?? '',
          );
        }).toList();
      }
    } catch (e) {
      print("Erro ao carregar partidas do PocketBase: $e");
    }
  }
}

