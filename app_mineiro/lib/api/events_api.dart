import 'package:app_mineiro/models/events.dart';
import 'package:app_mineiro/models/fixture_event.dart';
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
            round: record.data['round'] ?? '',
            elapsed: record.data['elapsed'] != null ? (record.data['elapsed'] as num).toInt() : null,
            venueName: record.data['venueName'] ?? '',
            venueCity: record.data['venueCity'] ?? '',
            oddsHome: record.data['oddsHome'] != null ? (record.data['oddsHome'] as num).toDouble() : null,
            oddsDraw: record.data['oddsDraw'] != null ? (record.data['oddsDraw'] as num).toDouble() : null,
            oddsAway: record.data['oddsAway'] != null ? (record.data['oddsAway'] as num).toDouble() : null,
          );
        }).toList();
      }
    } catch (e) {
      print("Erro ao carregar partidas do PocketBase: $e");
    }
  }

  static List<FixtureEventModel> matchEvents = [];

  static Future<void> loadEventsForFixture(String fixtureId) async {
    try {
      final pb = PocketBaseClient().client;
      final records = await pb.collection('fixture_events').getFullList(
        filter: "fixtureId = '$fixtureId'",
        sort: 'time',
      );
      matchEvents = records.map((record) {
        return FixtureEventModel(
          id: record.id,
          fixtureId: record.data['fixtureId'] ?? '',
          time: record.data['time'] != null ? (record.data['time'] as num).toInt() : 0,
          teamId: record.data['teamId'] ?? '',
          player: record.data['player'] ?? '',
          assist: record.data['assist'] ?? '',
          type: record.data['type'] ?? '',
          detail: record.data['detail'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Erro ao carregar eventos da partida: $e");
      matchEvents = [];
    }
  }
}

