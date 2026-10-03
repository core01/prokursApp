// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'login_response_dto.g.dart';

@JsonSerializable()
class LoginResponseDto {
  const LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });
  
  factory LoginResponseDto.fromJson(Map<String, Object?> json) => _$LoginResponseDtoFromJson(json);
  
  /// JWT Access Token
  @JsonKey(name: 'access_token')
  final String accessToken;

  /// JWT Refresh Token
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  Map<String, Object?> toJson() => _$LoginResponseDtoToJson(this);
}
