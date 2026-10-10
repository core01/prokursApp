import 'package:prokurs/core/network/generated/export.dart';

class City {
  final int id;
  final String title;

  static const almatyId = 2;
  static const astanaId = 3;
  static const oskemenId = 4;
  static const pavlodarId = 1;

  const City({required this.id, required this.title});

  City.fromDto(PublicCityDto dto)
      : id = dto.id,
        title = dto.name;
}
