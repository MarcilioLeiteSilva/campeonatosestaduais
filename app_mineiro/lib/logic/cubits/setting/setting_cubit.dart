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
      final notifMatchAlert = prefs.getBool('notif_match_alert') ?? true;
      final notifFeaturedNews = prefs.getBool('notif_featured_news') ?? false;
      final notifFeaturedVideo = prefs.getBool('notif_featured_video') ?? true;
      final notifStreaming = prefs.getBool('notif_streaming') ?? false;
      final notifPromotions = prefs.getBool('notif_promotions') ?? true;
      final notifAppUpdates = prefs.getBool('notif_app_updates') ?? true;

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
        notifMatchAlert: notifMatchAlert,
        notifFeaturedNews: notifFeaturedNews,
        notifFeaturedVideo: notifFeaturedVideo,
        notifStreaming: notifStreaming,
        notifPromotions: notifPromotions,
        notifAppUpdates: notifAppUpdates,
        autoRefresh: autoRefresh,
        vibration: vibration,
        rememberMe: rememberMe,
        biometricId: biometricId,
        faceId: faceId,
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

      // Sincronizar com tópicos correspondentes do Firebase
      final messaging = FirebaseMessaging.instance;
      final topic = key.replaceFirst('notif_', ''); // ex: notif_match_alert -> match_alert
      if (value) {
        await messaging.subscribeToTopic(topic);
      } else {
        await messaging.unsubscribeFromTopic(topic);
      }

      switch (key) {
        case 'notif_match_alert':
          emit(state.copyWith(notifMatchAlert: value));
          break;
        case 'notif_featured_news':
          emit(state.copyWith(notifFeaturedNews: value));
          break;
        case 'notif_featured_video':
          emit(state.copyWith(notifFeaturedVideo: value));
          break;
        case 'notif_streaming':
          emit(state.copyWith(notifStreaming: value));
          break;
        case 'notif_promotions':
          emit(state.copyWith(notifPromotions: value));
          break;
        case 'notif_app_updates':
          emit(state.copyWith(notifAppUpdates: value));
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
