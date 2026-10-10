// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'currency_rates_v2.dart';

part 'update_points_rates_v2_input.g.dart';

@JsonSerializable()
class UpdatePointsRatesV2Input {
  const UpdatePointsRatesV2Input({
    required this.pointIds,
    required this.rates,
  });
  
  factory UpdatePointsRatesV2Input.fromJson(Map<String, Object?> json) => _$UpdatePointsRatesV2InputFromJson(json);
  
  /// Ids of the caller's points to update (1 to 100, no repeats)
  final List<int> pointIds;

  /// The rates every listed point gets
  final CurrencyRatesV2 rates;

  Map<String, Object?> toJson() => _$UpdatePointsRatesV2InputToJson(this);
}
