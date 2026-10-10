// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileInput _$UpdateProfileInputFromJson(Map<String, dynamic> json) =>
    UpdateProfileInput(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
    );

Map<String, dynamic> _$UpdateProfileInputToJson(UpdateProfileInput instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': ?instance.lastName,
    };
