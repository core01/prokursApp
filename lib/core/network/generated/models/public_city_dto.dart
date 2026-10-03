// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'public_city_dto.g.dart';

@JsonSerializable()
class PublicCityDto {
  const PublicCityDto({
    required this.id,
    required this.name,
    required this.longitude,
    required this.latitude,
    required this.slug,
  });
  
  factory PublicCityDto.fromJson(Map<String, Object?> json) => _$PublicCityDtoFromJson(json);
  
  /// Unique identifier of the city
  final int id;

  /// Display name of the city
  final String name;

  /// Longitude of the city center, used to center the map when no exchange points have coordinates
  @JsonKey(includeIfNull: true)
  final num? longitude;

  /// Latitude of the city center, used to center the map when no exchange points have coordinates
  @JsonKey(includeIfNull: true)
  final num? latitude;

  /// URL-friendly identifier set by an administrator, used as the `city` query param instead of the numeric id
  @JsonKey(includeIfNull: true)
  final String? slug;

  Map<String, Object?> toJson() => _$PublicCityDtoToJson(this);
}
