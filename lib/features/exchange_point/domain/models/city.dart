class City {
  final int id;
  final String title;

  static const ALMATY_ID = 2;
  static const ASTANA_ID = 3;
  static const OSKEMEN_ID = 4;
  static const PAVLODAR_ID = 1;

  const City({required this.id, required this.title});

  factory City.fromJson(Map<String, dynamic> cityFromJSON) {
    return City(
      id: cityFromJSON['id'],
      title: cityFromJSON['name'],
    );
  }
}
