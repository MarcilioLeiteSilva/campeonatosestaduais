class TeamsModel {
  final id;
  final logo;
  final String name;
  bool picked;

  TeamsModel({
    this.id,
    this.logo,
    required this.name,
    this.picked = false,
  });
}
