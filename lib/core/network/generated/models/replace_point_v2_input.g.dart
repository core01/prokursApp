// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replace_point_v2_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplacePointV2Input _$ReplacePointV2InputFromJson(Map<String, dynamic> json) =>
    ReplacePointV2Input(
      name: json['name'] as String,
      cityId: (json['city_id'] as num).toInt(),
      info: json['info'] as String,
      gross: (json['gross'] as num).toInt(),
      buyUsd: json['buyUSD'] as num,
      sellUsd: json['sellUSD'] as num,
      buyEur: json['buyEUR'] as num,
      sellEur: json['sellEUR'] as num,
      buyRub: json['buyRUB'] as num,
      sellRub: json['sellRUB'] as num,
      buyCny: json['buyCNY'] as num,
      sellCny: json['sellCNY'] as num,
      buyGbp: json['buyGBP'] as num,
      sellGbp: json['sellGBP'] as num,
      dayAndNight: (json['day_and_night'] as num).toInt(),
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
    );

Map<String, dynamic> _$ReplacePointV2InputToJson(
  ReplacePointV2Input instance,
) => <String, dynamic>{
  'name': instance.name,
  'city_id': instance.cityId,
  'info': instance.info,
  'gross': instance.gross,
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
  'day_and_night': instance.dayAndNight,
  'phone_numbers': instance.phoneNumbers,
  'longitude': instance.longitude,
  'latitude': instance.latitude,
  'wholesale_note': instance.wholesaleNote,
  'work_modes': instance.workModes,
  'description': instance.description,
};
