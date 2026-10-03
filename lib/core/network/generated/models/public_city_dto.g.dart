// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_city_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicCityDto _$PublicCityDtoFromJson(Map<String, dynamic> json) =>
    PublicCityDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      longitude: json['longitude'] as num?,
      latitude: json['latitude'] as num?,
      slug: json['slug'] as String?,
    );

Map<String, dynamic> _$PublicCityDtoToJson(PublicCityDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'slug': instance.slug,
    };
