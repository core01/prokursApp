// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'public_user_profile_dto.g.dart';

@JsonSerializable()
class PublicUserProfileDto {
  const PublicUserProfileDto({
    this.firstName,
    this.lastName,
  });
  
  factory PublicUserProfileDto.fromJson(Map<String, Object?> json) => _$PublicUserProfileDtoFromJson(json);
  
  /// First name
  @JsonKey(includeIfNull: false)
  final String? firstName;

  /// Last name
  @JsonKey(includeIfNull: false)
  final String? lastName;

  Map<String, Object?> toJson() => _$PublicUserProfileDtoToJson(this);
}
