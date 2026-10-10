// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_point_v2_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePointV2Input _$CreatePointV2InputFromJson(Map<String, dynamic> json) =>
    CreatePointV2Input(
      name: json['name'] as String,
      cityId: (json['city_id'] as num).toInt(),
      info: json['info'] as String,
      gross: (json['gross'] as num).toInt(),
      buyUsd: json['buyUSD'] as num? ?? 0,
      sellUsd: json['sellUSD'] as num? ?? 0,
      buyEur: json['buyEUR'] as num? ?? 0,
      sellEur: json['sellEUR'] as num? ?? 0,
      buyRub: json['buyRUB'] as num? ?? 0,
      sellRub: json['sellRUB'] as num? ?? 0,
      buyCny: json['buyCNY'] as num? ?? 0,
      sellCny: json['sellCNY'] as num? ?? 0,
      buyGbp: json['buyGBP'] as num? ?? 0,
      sellGbp: json['sellGBP'] as num? ?? 0,
      dayAndNight: (json['day_and_night'] as num?)?.toInt(),
      phoneNumbers: (json['phone_numbers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      longitude: json['longitude'] as num?,
      latitude: json['latitude'] as num?,
      wholesaleNote: json['wholesale_note'] as String?,
      workModes: json['work_modes'] == null
          ? null
          : WorkModesDto.fromJson(json['work_modes'] as Map<String, dynamic>),
      description: json['description'] as String?,
      licenseAppendixNumber: json['license_appendix_number'] as String?,
      licenseAppendixDate: json['license_appendix_date'] == null
          ? null
          : DateTime.parse(json['license_appendix_date'] as String),
    );

Map<String, dynamic> _$CreatePointV2InputToJson(CreatePointV2Input instance) =>
    <String, dynamic>{
      'name': instance.name,
      'city_id': instance.cityId,
      'info': instance.info,
      'gross': instance.gross,
      'day_and_night': ?instance.dayAndNight,
      'phone_numbers': ?instance.phoneNumbers,
      'longitude': ?instance.longitude,
      'latitude': ?instance.latitude,
      'wholesale_note': ?instance.wholesaleNote,
      'work_modes': ?instance.workModes,
      'description': ?instance.description,
      'license_appendix_number': ?instance.licenseAppendixNumber,
      'license_appendix_date': ?instance.licenseAppendixDate?.toIso8601String(),
      'buyUSD': instance.buyUsd,
      'sellUSD': instance.sellUsd,
      'buyEUR': instance.buyEur,
      'sellEUR': instance.sellEur,
      'buyRUB': instance.buyRub,
      'sellRUB': instance.sellRub,
      'buyCNY': instance.buyCny,
      'sellCNY': instance.sellCny,
      'buyGBP': instance.buyGbp,
      'sellGBP': instance.sellGbp,
    };
