// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'refresh_response_dto.g.dart';

@JsonSerializable()
class RefreshResponseDto {
  const RefreshResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });
  
  factory RefreshResponseDto.fromJson(Map<String, Object?> json) => _$RefreshResponseDtoFromJson(json);
  
  /// JWT Access Token
  final String accessToken;

  /// JWT Refresh Token
  final String refreshToken;

  Map<String, Object?> toJson() => _$RefreshResponseDtoToJson(this);
}
