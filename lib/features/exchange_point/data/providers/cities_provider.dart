import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:prokurs/features/exchange_point/domain/models/city.dart';

class CitiesProvider with ChangeNotifier {
  List<City> _cities = [];

  List<City> get cities => _cities..sort((a, b) => a.title.compareTo(b.title));

  String get baseUrl => Platform.isAndroid ? dotenv.get('API_URL_ANDROID') : dotenv.get('API_URL_IOS');
  
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
      final url = Uri.parse('$baseUrl/cities');
      debugPrint('CitiesProvider -> fetchCities: url: $url');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return [];
      }

      final extractedData = json.decode(response.body) as dynamic;

      List<City> cities = [];
      extractedData.forEach((city) {
        cities.add(City.fromJson(city));
      });
      _cities = cities;

      notifyListeners();
      return cities;
    } catch (e) {
      debugPrint('CitiesProvider -> fetchCities: error: $e');
      return [];
    }
  }
}
