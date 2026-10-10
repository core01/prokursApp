// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserInput _$CreateUserInputFromJson(Map<String, dynamic> json) =>
    CreateUserInput(
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      organizationName: json['organizationName'] as String?,
      bin: json['bin'] as String?,
    );

Map<String, dynamic> _$CreateUserInputToJson(CreateUserInput instance) =>
    <String, dynamic>{
      'organizationName': ?instance.organizationName,
      'bin': ?instance.bin,
      'fullName': instance.fullName,
      'username': instance.username,
      'password': instance.password,
    };
