import 'package:prokurs/core/network/generated/export.dart';

class City {
  final int id;
  final String title;

  static const ALMATY_ID = 2;
  static const ASTANA_ID = 3;
  static const OSKEMEN_ID = 4;
  static const PAVLODAR_ID = 1;

  const City({required this.id, required this.title});

  City.fromDto(PublicCityDto dto)
      : id = dto.id,
        title = dto.name;
}
