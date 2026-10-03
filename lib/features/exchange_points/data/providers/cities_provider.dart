import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/network/api_client.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';

class CitiesProvider with ChangeNotifier {
  List<City> _cities = [];

  List<City> get cities => _cities..sort((a, b) => a.title.compareTo(b.title));

  List<num> popularCityIds = [
    City.ASTANA_ID,
    City.ALMATY_ID,
    City.OSKEMEN_ID,
    City.PAVLODAR_ID
  ];

  List<City> get popularCities =>
      _cities.where((city) => popularCityIds.contains(city.id)).toList()
        ..sort((a, b) => a.title.compareTo(b.title));

  List<City> get unpopularCities =>
      _cities.where((city) => !popularCityIds.contains(city.id)).toList()
        ..sort((a, b) => a.title.compareTo(b.title));

  City findById(int cityId) => cities.firstWhere((city) => city.id == cityId);

  Future<List<City>> fetchCities() async {
    try {
      final response =
          await ApiClient.instance.api.cities.citiesControllerFindAllV2();
      _cities = response.map(City.fromDto).toList();

      notifyListeners();
      return _cities;
    } catch (e) {
      debugPrint('CitiesProvider -> fetchCities: error: $e');
      return [];
    }
  }
}
