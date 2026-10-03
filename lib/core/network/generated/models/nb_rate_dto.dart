// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'nb_rate_dto.g.dart';

@JsonSerializable()
class NbRateDto {
  const NbRateDto({
    required this.code,
    required this.value,
    required this.quant,
  });
  
  factory NbRateDto.fromJson(Map<String, Object?> json) => _$NbRateDtoFromJson(json);
  
  /// Currency code
  final String code;

  /// Rate value
  @JsonKey(includeIfNull: true)
  final num? value;

  /// Quantity
  final int quant;

  Map<String, Object?> toJson() => _$NbRateDtoToJson(this);
}
