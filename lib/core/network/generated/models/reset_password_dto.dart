// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reset_password_dto.g.dart';

@JsonSerializable()
class ResetPasswordDto {
  const ResetPasswordDto({
    required this.username,
  });
  
  factory ResetPasswordDto.fromJson(Map<String, Object?> json) => _$ResetPasswordDtoFromJson(json);
  
  /// Email address of the user
  final String username;

  Map<String, Object?> toJson() => _$ResetPasswordDtoToJson(this);
}
