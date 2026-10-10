// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'public_user_attributes_dto.dart';
import 'public_user_organization_dto.dart';
import 'public_user_profile_dto.dart';

part 'public_user_dto.g.dart';

@JsonSerializable()
class PublicUserDto {
  const PublicUserDto({
    required this.username,
    this.attributes,
    this.profile,
    this.organization,
  });
  
  factory PublicUserDto.fromJson(Map<String, Object?> json) => _$PublicUserDtoFromJson(json);
  
  /// Username
  final String username;

  /// User attributes
  @JsonKey(includeIfNull: false)
  final PublicUserAttributesDto? attributes;

  /// First and last name, from the cabinet's own profile
  @JsonKey(includeIfNull: false)
  final PublicUserProfileDto? profile;

  /// The organization (legal entity) the user runs points for, and its license. API v2 only: v1 answers without it
  @JsonKey(includeIfNull: false)
  final PublicUserOrganizationDto? organization;

  Map<String, Object?> toJson() => _$PublicUserDtoToJson(this);
}
