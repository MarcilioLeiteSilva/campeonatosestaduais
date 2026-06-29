part of 'setting_cubit.dart';

class SettingState {
  final int homeIndex;
  final bool showCalendar;
  final DateTime selectedDate;
  final int selectedLeagueId;
  final bool showLiveOnly;
  final String userName;
  final String? favoriteTeam;
  final String? favoriteTeamLogo;

  // Notificações
  final String notificationPermission;
  final bool notifMatchAlert;
  final bool notifFeaturedNews;
  final bool notifFeaturedVideo;
  final bool notifStreaming;
  final bool notifPromotions;
  final bool notifAppUpdates;

  // General
  final bool autoRefresh;
  final bool vibration;

  // Security
  final bool rememberMe;
  final bool biometricId;
  final bool faceId;

  SettingState({
    required this.homeIndex,
    this.showCalendar = false,
    required this.selectedDate,
    this.selectedLeagueId = -1,
    this.showLiveOnly = false,
    this.userName = 'Visitante',
    this.favoriteTeam,
    this.favoriteTeamLogo,
    this.notificationPermission = 'notDetermined',
    this.notifMatchAlert = true,
    this.notifFeaturedNews = false,
    this.notifFeaturedVideo = true,
    this.notifStreaming = false,
    this.notifPromotions = true,
    this.notifAppUpdates = true,
    this.autoRefresh = true,
    this.vibration = true,
    this.rememberMe = true,
    this.biometricId = false,
    this.faceId = false,
  });

  SettingState copyWith({
    final int? homeIndex,
    final bool? showCalendar,
    final DateTime? selectedDate,
    final int? selectedLeagueId,
    final bool? showLiveOnly,
    final String? userName,
    final String? favoriteTeam,
    final String? favoriteTeamLogo,
    final String? notificationPermission,
    final bool? notifMatchAlert,
    final bool? notifFeaturedNews,
    final bool? notifFeaturedVideo,
    final bool? notifStreaming,
    final bool? notifPromotions,
    final bool? notifAppUpdates,
    final bool? autoRefresh,
    final bool? vibration,
    final bool? rememberMe,
    final bool? biometricId,
    final bool? faceId,
  }) {
    return SettingState(
      homeIndex: homeIndex ?? this.homeIndex,
      showCalendar: showCalendar ?? this.showCalendar,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedLeagueId: selectedLeagueId ?? this.selectedLeagueId,
      showLiveOnly: showLiveOnly ?? this.showLiveOnly,
      userName: userName ?? this.userName,
      favoriteTeam: favoriteTeam != null ? (favoriteTeam.isEmpty ? null : favoriteTeam) : this.favoriteTeam,
      favoriteTeamLogo: favoriteTeamLogo != null ? (favoriteTeamLogo.isEmpty ? null : favoriteTeamLogo) : this.favoriteTeamLogo,
      notificationPermission: notificationPermission ?? this.notificationPermission,
      notifMatchAlert: notifMatchAlert ?? this.notifMatchAlert,
      notifFeaturedNews: notifFeaturedNews ?? this.notifFeaturedNews,
      notifFeaturedVideo: notifFeaturedVideo ?? this.notifFeaturedVideo,
      notifStreaming: notifStreaming ?? this.notifStreaming,
      notifPromotions: notifPromotions ?? this.notifPromotions,
      notifAppUpdates: notifAppUpdates ?? this.notifAppUpdates,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      vibration: vibration ?? this.vibration,
      rememberMe: rememberMe ?? this.rememberMe,
      biometricId: biometricId ?? this.biometricId,
      faceId: faceId ?? this.faceId,
    );
  }
}
