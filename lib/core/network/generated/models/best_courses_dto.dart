// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'best_courses_dto.g.dart';

@JsonSerializable()
class BestCoursesDto {
  const BestCoursesDto({
    required this.buyCny,
    required this.buyUsd,
    required this.buyEur,
    required this.buyRub,
    required this.buyXau,
    required this.buyGbp,
    required this.sellGbp,
    required this.sellEur,
    required this.sellCny,
    required this.sellRub,
    required this.sellUsd,
    required this.sellXau,
  });
  
  factory BestCoursesDto.fromJson(Map<String, Object?> json) => _$BestCoursesDtoFromJson(json);
  
  /// Buy rate for CNY
  @JsonKey(name: 'buyCNY')
  final num buyCny;

  /// Buy rate for USD
  @JsonKey(name: 'buyUSD')
  final num buyUsd;

  /// Buy rate for EUR
  @JsonKey(name: 'buyEUR')
  final num buyEur;

  /// Buy rate for RUB
  @JsonKey(name: 'buyRUB')
  final num buyRub;

  /// Buy rate for XAU
  @JsonKey(name: 'buyXAU')
  final num buyXau;

  /// Buy rate for GBP
  @JsonKey(name: 'buyGBP')
  final num buyGbp;

  /// Sell rate for GBP
  @JsonKey(name: 'sellGBP')
  final num sellGbp;

  /// Sell rate for EUR
  @JsonKey(name: 'sellEUR')
  final num sellEur;

  /// Sell rate for CNY
  @JsonKey(name: 'sellCNY')
  final num sellCny;

  /// Sell rate for RUB
  @JsonKey(name: 'sellRUB')
  final num sellRub;

  /// Sell rate for USD
  @JsonKey(name: 'sellUSD')
  final num sellUsd;

  /// Sell rate for XAU
  @JsonKey(name: 'sellXAU')
  final num sellXau;

  Map<String, Object?> toJson() => _$BestCoursesDtoToJson(this);
}
