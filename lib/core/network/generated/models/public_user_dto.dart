// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'public_user_attributes_dto.dart';

part 'public_user_dto.g.dart';

@JsonSerializable()
class PublicUserDto {
  const PublicUserDto({
    required this.username,
    this.attributes,
  });
  
  factory PublicUserDto.fromJson(Map<String, Object?> json) => _$PublicUserDtoFromJson(json);
  
  /// Username
  final String username;

  /// User attributes
  @JsonKey(includeIfNull: false)
  final PublicUserAttributesDto? attributes;

  Map<String, Object?> toJson() => _$PublicUserDtoToJson(this);
}
