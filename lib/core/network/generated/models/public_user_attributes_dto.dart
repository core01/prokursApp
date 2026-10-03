// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'public_user_attributes_dto.g.dart';

@JsonSerializable()
class PublicUserAttributesDto {
  const PublicUserAttributesDto({
    this.fullName,
  });
  
  factory PublicUserAttributesDto.fromJson(Map<String, Object?> json) => _$PublicUserAttributesDtoFromJson(json);
  
  /// Full name of the user
  @JsonKey(includeIfNull: false)
  final String? fullName;

  Map<String, Object?> toJson() => _$PublicUserAttributesDtoToJson(this);
}
