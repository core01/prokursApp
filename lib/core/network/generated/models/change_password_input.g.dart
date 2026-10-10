// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordInput _$ChangePasswordInputFromJson(Map<String, dynamic> json) =>
    ChangePasswordInput(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$ChangePasswordInputToJson(
  ChangePasswordInput instance,
) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
};
