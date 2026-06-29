class TeamsModel {
  final id;
  final logo;
  final String name;
  bool picked;
  final int? externalId;

  TeamsModel({
    this.id,
    this.logo,
    required this.name,
    this.picked = false,
    this.externalId,
  });
}
