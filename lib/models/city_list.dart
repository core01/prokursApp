import './city.dart';

class CityList {
  static const ALMATY = City(id: 2, title: 'Алматы');
  static const ASTANA = City(id: 3, title: 'Астана');
  static const OSKEMEN = City(id: 4, title: 'Усть-Каменогорск');
  static const RIDDER = City(id: 6, title: 'Риддер');

  List<City> get items => [ASTANA, ALMATY, OSKEMEN, RIDDER];

  City findById(int cityId) => items.firstWhere((city) => city.id == cityId);
}
