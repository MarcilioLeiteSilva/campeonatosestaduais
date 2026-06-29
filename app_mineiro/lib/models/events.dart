class EventsModel {
  final id;
  final nameHome;
  final nameAway;
  final logoHome;
  final logoAway;
  final scoreHome;
  final scoreAway;
  final dateMatch;
  final timeMatch;
  final int leagueExternalId;
  final String round;
  final int? elapsed;
  final String venueName;
  final String venueCity;
  final double? oddsHome;
  final double? oddsDraw;
  final double? oddsAway;

  EventsModel({
    this.id,
    this.nameHome,
    this.nameAway,
    this.logoHome,
    this.logoAway,
    this.scoreHome,
    this.scoreAway,
    this.dateMatch,
    this.timeMatch,
    this.leagueExternalId = -1,
    this.round = '',
    this.elapsed,
    this.venueName = '',
    this.venueCity = '',
    this.oddsHome,
    this.oddsDraw,
    this.oddsAway,
  });
}
