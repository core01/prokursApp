// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicUserDto _$PublicUserDtoFromJson(Map<String, dynamic> json) =>
    PublicUserDto(
      username: json['username'] as String,
      attributes: json['attributes'] == null
          ? null
          : PublicUserAttributesDto.fromJson(
              json['attributes'] as Map<String, dynamic>,
            ),
      profile: json['profile'] == null
          ? null
          : PublicUserProfileDto.fromJson(
              json['profile'] as Map<String, dynamic>,
            ),
      organization: json['organization'] == null
          ? null
          : PublicUserOrganizationDto.fromJson(
              json['organization'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PublicUserDtoToJson(PublicUserDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'attributes': ?instance.attributes,
      'profile': ?instance.profile,
      'organization': ?instance.organization,
    };
