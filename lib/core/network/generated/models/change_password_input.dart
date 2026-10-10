// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'change_password_input.g.dart';

@JsonSerializable()
class ChangePasswordInput {
  const ChangePasswordInput({
    required this.currentPassword,
    required this.newPassword,
  });
  
  factory ChangePasswordInput.fromJson(Map<String, Object?> json) => _$ChangePasswordInputFromJson(json);
  
  /// The current password
  final String currentPassword;

  /// The new password, at least 8 characters
  final String newPassword;

  Map<String, Object?> toJson() => _$ChangePasswordInputToJson(this);
}
