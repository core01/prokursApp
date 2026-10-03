// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_point_v2_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalPointV2Dto _$PersonalPointV2DtoFromJson(Map<String, dynamic> json) =>
    PersonalPointV2Dto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
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
      cityId: (json['city_id'] as num).toInt(),
      dayAndNight: (json['day_and_night'] as num).toInt(),
      companyId: (json['company_id'] as num).toInt(),
      published: (json['published'] as num).toInt(),
      sorting: (json['sorting'] as num).toInt(),
      gross: (json['gross'] as num).toInt(),
      dateUpdate: (json['date_update'] as num).toInt(),
      phoneNumbers: (json['phone_numbers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      info: json['info'] as String?,
      longitude: json['longitude'] as num?,
      latitude: json['latitude'] as num?,
      atms: json['atms'] as String?,
      logo: json['logo'] as String?,
      wholesaleNote: json['wholesale_note'] as String?,
      workModes: json['work_modes'] == null
          ? null
          : WorkModesDto.fromJson(json['work_modes'] as Map<String, dynamic>),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PersonalPointV2DtoToJson(PersonalPointV2Dto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
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
      'city_id': instance.cityId,
      'day_and_night': instance.dayAndNight,
      'company_id': instance.companyId,
      'published': instance.published,
      'info': ?instance.info,
      'sorting': instance.sorting,
      'longitude': ?instance.longitude,
      'latitude': ?instance.latitude,
      'gross': instance.gross,
      'atms': ?instance.atms,
      'logo': ?instance.logo,
      'wholesale_note': ?instance.wholesaleNote,
      'work_modes': ?instance.workModes,
      'description': ?instance.description,
      'date_update': instance.dateUpdate,
      'phone_numbers': instance.phoneNumbers,
    };
