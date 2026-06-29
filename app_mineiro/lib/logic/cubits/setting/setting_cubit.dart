import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit()
      : super(SettingState(
          homeIndex: 0,
          selectedDate: DateTime.now(),
          selectedLeagueId: -1,
        )) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? 'Visitante';
      final favTeam = prefs.getString('favorite_team');
      final favLogo = prefs.getString('favorite_team_logo');
      emit(state.copyWith(
        userName: name,
        favoriteTeam: favTeam ?? '',
        favoriteTeamLogo: favLogo ?? '',
      ));
    } catch (_) {}
  }

  String _sanitizeTopic(String name) {
    // Mantém apenas caracteres alfanuméricos e sublinhados, adequado para tópicos do Firebase
    return name.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(' ', '_');
  }

  Future<void> loginLocal({
    required String name,
    String? favoriteTeam,
    String? favoriteTeamLogo,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldFav = prefs.getString('favorite_team');

      await prefs.setString('user_name', name);
      if (favoriteTeam != null) {
        await prefs.setString('favorite_team', favoriteTeam);
      } else {
        await prefs.remove('favorite_team');
      }
      if (favoriteTeamLogo != null) {
        await prefs.setString('favorite_team_logo', favoriteTeamLogo);
      } else {
        await prefs.remove('favorite_team_logo');
      }

      // Sincronizar tópicos do Firebase Messaging
      final messaging = FirebaseMessaging.instance;
      if (oldFav != null && oldFav.isNotEmpty) {
        final oldTopic = _sanitizeTopic(oldFav);
        await messaging.unsubscribeFromTopic('time_$oldTopic');
      }
      if (favoriteTeam != null && favoriteTeam.isNotEmpty) {
        final newTopic = _sanitizeTopic(favoriteTeam);
        await messaging.subscribeToTopic('time_$newTopic');
      }

      emit(state.copyWith(
        userName: name,
        favoriteTeam: favoriteTeam ?? '',
        favoriteTeamLogo: favoriteTeamLogo ?? '',
      ));
    } catch (_) {}
  }

  Future<void> logoutLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldFav = prefs.getString('favorite_team');

      await prefs.remove('user_name');
      await prefs.remove('favorite_team');
      await prefs.remove('favorite_team_logo');

      // Desinscrever do tópico do time antigo
      if (oldFav != null && oldFav.isNotEmpty) {
        final oldTopic = _sanitizeTopic(oldFav);
        await FirebaseMessaging.instance.unsubscribeFromTopic('time_$oldTopic');
      }

      emit(state.copyWith(
        userName: 'Visitante',
        favoriteTeam: '',
        favoriteTeamLogo: '',
      ));
    } catch (_) {}
  }

  void updateHomeIndex(int page) => emit(state.copyWith(
        homeIndex: page,
        showCalendar: false,
      ));

  void visibleCalendar() =>
      emit(state.copyWith(showCalendar: !state.showCalendar));

  void updateCalendarDate(DateTime date) =>
      emit(state.copyWith(showCalendar: false, selectedDate: date, showLiveOnly: false));

  void updateSelectedLeague(int leagueId) =>
      emit(state.copyWith(selectedLeagueId: leagueId, showLiveOnly: false));

  void toggleLiveOnly() =>
      emit(state.copyWith(showLiveOnly: !state.showLiveOnly));
}
