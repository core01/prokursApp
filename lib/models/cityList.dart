import './city.dart';

class CityList {
  static const ALMATY = City(id: 2, title: 'Алматы');
  static const NUR_SULTAN = City(id: 3, title: 'Нур-Султан');
  static const UST_KAMENOGORSK = City(id: 4, title: 'Усть-Каменогорск');
  static const RIDDER = City(id: 6, title: 'Риддер');

  List<City> get items => [ALMATY, NUR_SULTAN, UST_KAMENOGORSK, RIDDER];

  City findById(int cityId) => items.firstWhere((city) => city.id == cityId);
}
