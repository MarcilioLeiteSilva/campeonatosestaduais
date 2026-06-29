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

      // Toggles
      final notifPlacar = prefs.getBool('notif_placar') ?? true;
      final notifGols = prefs.getBool('notif_gols') ?? true;
      final notifSubstituicoes = prefs.getBool('notif_substituicoes') ?? true;
      final notifCartoes = prefs.getBool('notif_cartoes') ?? true;

      final autoRefresh = prefs.getBool('auto_refresh') ?? true;
      final vibration = prefs.getBool('vibration') ?? true;

      final rememberMe = prefs.getBool('remember_me') ?? true;
      final biometricId = prefs.getBool('biometric_id') ?? false;
      final faceId = prefs.getBool('face_id') ?? false;

      String notifPerm = 'notDetermined';
      try {
        final settings = await FirebaseMessaging.instance.getNotificationSettings();
        notifPerm = settings.authorizationStatus.name;
      } catch (_) {}

      emit(state.copyWith(
        userName: name,
        favoriteTeam: favTeam ?? '',
        favoriteTeamLogo: favLogo ?? '',
        notificationPermission: notifPerm,
        notifPlacar: notifPlacar,
        notifGols: notifGols,
        notifSubstituicoes: notifSubstituicoes,
        notifCartoes: notifCartoes,
        autoRefresh: autoRefresh,
        vibration: vibration,
        rememberMe: rememberMe,
        biometricId: biometricId,
        faceId: faceId,
      ));
    } catch (_) {}
  }

  String _sanitizeTopic(String name) {
    return name.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(' ', '_');
  }

  Future<void> _unsubscribeAllTeamTopics(String team) async {
    final topic = _sanitizeTopic(team);
    final messaging = FirebaseMessaging.instance;
    await messaging.unsubscribeFromTopic('time_${topic}_placar');
    await messaging.unsubscribeFromTopic('time_${topic}_gols');
    await messaging.unsubscribeFromTopic('time_${topic}_substituicoes');
    await messaging.unsubscribeFromTopic('time_${topic}_cartoes');
  }

  Future<void> _subscribeActiveTeamTopics(String team) async {
    final topic = _sanitizeTopic(team);
    final messaging = FirebaseMessaging.instance;
    if (state.notifPlacar) await messaging.subscribeToTopic('time_${topic}_placar');
    if (state.notifGols) await messaging.subscribeToTopic('time_${topic}_gols');
    if (state.notifSubstituicoes) await messaging.subscribeToTopic('time_${topic}_substituicoes');
    if (state.notifCartoes) await messaging.subscribeToTopic('time_${topic}_cartoes');
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
      if (oldFav != null && oldFav.isNotEmpty) {
        await _unsubscribeAllTeamTopics(oldFav);
      }
      if (favoriteTeam != null && favoriteTeam.isNotEmpty) {
        await _subscribeActiveTeamTopics(favoriteTeam);
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

      // Desinscrever de todos os tópicos do time antigo
      if (oldFav != null && oldFav.isNotEmpty) {
        await _unsubscribeAllTeamTopics(oldFav);
      }

      emit(state.copyWith(
        userName: 'Visitante',
        favoriteTeam: '',
        favoriteTeamLogo: '',
      ));
    } catch (_) {}
  }

  Future<void> requestNotificationPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final status = settings.authorizationStatus.name;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_permission', status);
      emit(state.copyWith(notificationPermission: status));
    } catch (_) {}
  }

  Future<void> toggleNotification(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);

      // Sincronizar com tópicos correspondentes do Firebase se o usuário tem time favorito
      if (state.favoriteTeam != null && state.favoriteTeam!.isNotEmpty) {
        final messaging = FirebaseMessaging.instance;
        final teamTopic = _sanitizeTopic(state.favoriteTeam!);
        final subTopic = key.replaceFirst('notif_', ''); // ex: notif_placar -> placar
        final topic = 'time_${teamTopic}_$subTopic';

        if (value) {
          await messaging.subscribeToTopic(topic);
        } else {
          await messaging.unsubscribeFromTopic(topic);
        }
      }

      switch (key) {
        case 'notif_placar':
          emit(state.copyWith(notifPlacar: value));
          break;
        case 'notif_gols':
          emit(state.copyWith(notifGols: value));
          break;
        case 'notif_substituicoes':
          emit(state.copyWith(notifSubstituicoes: value));
          break;
        case 'notif_cartoes':
          emit(state.copyWith(notifCartoes: value));
          break;
      }
    } catch (_) {}
  }

  Future<void> toggleGeneralSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      if (key == 'auto_refresh') {
        emit(state.copyWith(autoRefresh: value));
      } else if (key == 'vibration') {
        emit(state.copyWith(vibration: value));
      }
    } catch (_) {}
  }

  Future<void> toggleSecuritySetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      if (key == 'remember_me') {
        emit(state.copyWith(rememberMe: value));
      } else if (key == 'biometric_id') {
        emit(state.copyWith(biometricId: value));
      } else if (key == 'face_id') {
        emit(state.copyWith(faceId: value));
      }
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
