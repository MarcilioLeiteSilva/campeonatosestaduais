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
  final bool notifPlacar;
  final bool notifGols;
  final bool notifSubstituicoes;
  final bool notifCartoes;

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
    this.notifPlacar = true,
    this.notifGols = true,
    this.notifSubstituicoes = true,
    this.notifCartoes = true,
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
    final bool? notifPlacar,
    final bool? notifGols,
    final bool? notifSubstituicoes,
    final bool? notifCartoes,
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
      notifPlacar: notifPlacar ?? this.notifPlacar,
      notifGols: notifGols ?? this.notifGols,
      notifSubstituicoes: notifSubstituicoes ?? this.notifSubstituicoes,
      notifCartoes: notifCartoes ?? this.notifCartoes,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      vibration: vibration ?? this.vibration,
      rememberMe: rememberMe ?? this.rememberMe,
      biometricId: biometricId ?? this.biometricId,
      faceId: faceId ?? this.faceId,
    );
  }
}
