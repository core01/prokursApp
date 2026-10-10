// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'currency_rates_v2.g.dart';

@JsonSerializable()
class CurrencyRatesV2 {
  const CurrencyRatesV2({
    required this.buyUsd,
    required this.sellUsd,
    required this.buyEur,
    required this.sellEur,
    required this.buyRub,
    required this.sellRub,
    required this.buyCny,
    required this.sellCny,
    required this.buyGbp,
    required this.sellGbp,
  });
  
  factory CurrencyRatesV2.fromJson(Map<String, Object?> json) => _$CurrencyRatesV2FromJson(json);
  
  /// USD buy rate
  @JsonKey(name: 'buyUSD')
  final num buyUsd;

  /// USD sell rate
  @JsonKey(name: 'sellUSD')
  final num sellUsd;

  /// EUR buy rate
  @JsonKey(name: 'buyEUR')
  final num buyEur;

  /// EUR sell rate
  @JsonKey(name: 'sellEUR')
  final num sellEur;

  /// RUB buy rate
  @JsonKey(name: 'buyRUB')
  final num buyRub;

  /// RUB sell rate
  @JsonKey(name: 'sellRUB')
  final num sellRub;

  /// CNY buy rate
  @JsonKey(name: 'buyCNY')
  final num buyCny;

  /// CNY sell rate
  @JsonKey(name: 'sellCNY')
  final num sellCny;

  /// GBP buy rate
  @JsonKey(name: 'buyGBP')
  final num buyGbp;

  /// GBP sell rate
  @JsonKey(name: 'sellGBP')
  final num sellGbp;

  Map<String, Object?> toJson() => _$CurrencyRatesV2ToJson(this);
}
