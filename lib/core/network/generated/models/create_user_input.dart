// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_user_input.g.dart';

@JsonSerializable()
class CreateUserInput {
  const CreateUserInput({
    required this.fullName,
    required this.username,
    required this.password,
  });
  
  factory CreateUserInput.fromJson(Map<String, Object?> json) => _$CreateUserInputFromJson(json);
  
  /// Full name of the user
  final String fullName;

  /// Username for login
  final String username;

  /// Password
  final String password;

  Map<String, Object?> toJson() => _$CreateUserInputToJson(this);
}
