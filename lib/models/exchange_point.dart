import 'package:flutter/rendering.dart';

class ExchangePoint {
  final num id;
  final String name;
  final num buyUSD;
  final num sellUSD;
  final num buyEUR;
  final num sellEUR;
  final num buyRUB;
  final num sellRUB;
  final num buyCNY;
  final num sellCNY;
  final num buyGBP;
  final num sellGBP;
  final String? info;
  final dynamic phones;
  final num date_update;
  final num day_and_night;
  final num published;
  final num? longitude;
  final num? latitude;
  final num? company_id;
  final num gross;
  final num? atms;
  final String? logo;

  bool get hasLogo => logo != null && logo!.isNotEmpty;

  ExchangePoint({
    required this.atms,
    required this.buyCNY,
    required this.buyEUR,
    required this.buyGBP,
    required this.buyRUB,
    required this.buyUSD,
    required this.company_id,
    required this.date_update,
    required this.day_and_night,
    required this.gross,
    required this.id,
    required this.info,
    this.latitude,
    this.longitude,
    required this.name,
    required this.phones,
    required this.published,
    required this.sellCNY,
    required this.sellEUR,
    required this.sellGBP,
    required this.sellRUB,
    required this.sellUSD,
    this.logo,
  });

  Map<String, dynamic> _toMap() {
    return {
      'id': id,
      'name': name,
      'buyCNY': buyCNY,
      'buyEUR': buyEUR,
      'buyGBP': buyGBP,
      'buyRUB': buyRUB,
      'buyUSD': buyUSD,
      'sellCNY': sellCNY,
      'sellEUR': sellEUR,
      'sellGBP': sellGBP,
      'sellRUB': sellRUB,
      'sellUSD': sellUSD,
      'gross': gross,
    };
  }

  dynamic get(String propertyName) {
    var mapRep = _toMap();
    if (mapRep.containsKey(propertyName)) {
      return mapRep[propertyName];
    }

    debugPrint('Throwing error $propertyName');
    throw ArgumentError('property not found');
  }

  factory ExchangePoint.fromJson(Map<String, dynamic> exchangeRateFromJson) {
    return ExchangePoint(
      atms: exchangeRateFromJson['atms'],
      buyCNY: exchangeRateFromJson['buyCNY'],
      buyEUR: exchangeRateFromJson['buyEUR'],
      buyGBP: exchangeRateFromJson['buyGBP'],
      buyRUB: exchangeRateFromJson['buyRUB'],
      buyUSD: exchangeRateFromJson['buyUSD'],
      company_id: exchangeRateFromJson['company_id'],
      date_update: exchangeRateFromJson['date_update'],
      day_and_night: exchangeRateFromJson['day_and_night'],
      gross: exchangeRateFromJson['gross'],
      id: exchangeRateFromJson['id'],
      info: exchangeRateFromJson['info'],
      latitude: exchangeRateFromJson['latitude'],
      longitude: exchangeRateFromJson['longitude'],
      name: exchangeRateFromJson['name'],
      phones: exchangeRateFromJson['phones'],
      published: exchangeRateFromJson['published'],
      sellCNY: exchangeRateFromJson['sellCNY'],
      sellEUR: exchangeRateFromJson['sellEUR'],
      sellGBP: exchangeRateFromJson['sellGBP'],
      sellRUB: exchangeRateFromJson['sellRUB'],
      sellUSD: exchangeRateFromJson['sellUSD'],
      logo: exchangeRateFromJson['logo'],
    );
  }
}
