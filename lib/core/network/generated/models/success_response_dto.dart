// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'success_response_dto.g.dart';

@JsonSerializable()
class SuccessResponseDto {
  const SuccessResponseDto({
    required this.success,
    this.message,
  });
  
  factory SuccessResponseDto.fromJson(Map<String, Object?> json) => _$SuccessResponseDtoFromJson(json);
  
  /// Indicates whether the operation succeeded
  final bool success;

  /// Optional human-readable message describing the result
  @JsonKey(includeIfNull: false)
  final String? message;

  Map<String, Object?> toJson() => _$SuccessResponseDtoToJson(this);
}
