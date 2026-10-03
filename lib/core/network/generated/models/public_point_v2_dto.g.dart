// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_point_v2_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicPointV2Dto _$PublicPointV2DtoFromJson(Map<String, dynamic> json) =>
    PublicPointV2Dto(
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
      sorting: (json['sorting'] as num).toInt(),
      gross: (json['gross'] as num).toInt(),
      dateUpdate: (json['date_update'] as num).toInt(),
      phones: (json['phones'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      info: json['info'] as String?,
      phoneNumbers: (json['phone_numbers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
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

Map<String, dynamic> _$PublicPointV2DtoToJson(PublicPointV2Dto instance) =>
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
      'info': ?instance.info,
      'phone_numbers': ?instance.phoneNumbers,
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
      'phones': instance.phones,
    };
