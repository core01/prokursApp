import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;
import 'package:prokurs/models/city.dart';

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
    final url = Uri.parse('${FlutterConfig.get('API_URL')}/cities');
    // @todo add global error handler
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as dynamic;

    List<City> cities = [];
    extractedData.forEach((city) {
      cities.add(City.fromJson(city));
    });
    _cities = cities;

    notifyListeners();

    return cities;
  }
}
