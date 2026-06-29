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

  SettingState({
    required this.homeIndex,
    this.showCalendar = false,
    required this.selectedDate,
    this.selectedLeagueId = -1,
    this.showLiveOnly = false,
    this.userName = 'Visitante',
    this.favoriteTeam,
    this.favoriteTeamLogo,
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
    );
  }
}
