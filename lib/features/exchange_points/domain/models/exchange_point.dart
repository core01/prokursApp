import 'package:flutter/rendering.dart';
import 'package:prokurs/core/network/generated/export.dart';

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
  final List<String> phones;
  final num date_update;
  final num day_and_night;
  final num? longitude;
  final num? latitude;
  final num gross;
  final String? logo;
  final num city_id;
  final String? wholesaleNote;
  final WorkModesDto? workModes;
  final String? description;

  bool get hasLogo => logo != null && logo!.isNotEmpty;

  ExchangePoint({
    required this.buyCNY,
    required this.buyEUR,
    required this.buyGBP,
    required this.buyRUB,
    required this.buyUSD,
    required this.date_update,
    required this.day_and_night,
    required this.gross,
    required this.id,
    required this.info,
    this.latitude,
    this.longitude,
    required this.name,
    required this.phones,
    required this.sellCNY,
    required this.sellEUR,
    required this.sellGBP,
    required this.sellRUB,
    required this.sellUSD,
    this.logo,
    required this.city_id,
    this.wholesaleNote,
    this.workModes,
    this.description,
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
      'city_id': city_id,
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

  /// A point from the public rates list of a city.
  factory ExchangePoint.fromRate(PointWithParsedPhonesDto dto) {
    return ExchangePoint(
      buyCNY: dto.buyCny,
      buyEUR: dto.buyEur,
      buyGBP: dto.buyGbp,
      buyRUB: dto.buyRub,
      buyUSD: dto.buyUsd,
      date_update: dto.dateUpdate,
      day_and_night: dto.dayAndNight,
      gross: dto.gross,
      id: dto.id,
      info: dto.info,
      latitude: dto.latitude,
      longitude: dto.longitude,
      name: dto.name,
      phones: dto.phones,
      sellCNY: dto.sellCny,
      sellEUR: dto.sellEur,
      sellGBP: dto.sellGbp,
      sellRUB: dto.sellRub,
      sellUSD: dto.sellUsd,
      logo: dto.logo,
      city_id: dto.cityId,
    );
  }

  /// A point owned by the signed-in user.
  factory ExchangePoint.fromPersonal(PersonalPointV2Dto dto) {
    return ExchangePoint(
      buyCNY: dto.buyCny,
      buyEUR: dto.buyEur,
      buyGBP: dto.buyGbp,
      buyRUB: dto.buyRub,
      buyUSD: dto.buyUsd,
      date_update: dto.dateUpdate,
      day_and_night: dto.dayAndNight,
      gross: dto.gross,
      id: dto.id,
      info: dto.info,
      latitude: dto.latitude,
      longitude: dto.longitude,
      name: dto.name,
      phones: dto.phoneNumbers,
      sellCNY: dto.sellCny,
      sellEUR: dto.sellEur,
      sellGBP: dto.sellGbp,
      sellRUB: dto.sellRub,
      sellUSD: dto.sellUsd,
      logo: dto.logo,
      city_id: dto.cityId,
      wholesaleNote: dto.wholesaleNote,
      workModes: dto.workModes,
      description: dto.description,
    );
  }
}
