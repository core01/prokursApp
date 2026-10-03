// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum SortBy {
  @JsonValue('buyUSD')
  buyUsd('buyUSD'),
  @JsonValue('sellUSD')
  sellUsd('sellUSD'),
  @JsonValue('buyEUR')
  buyEur('buyEUR'),
  @JsonValue('sellEUR')
  sellEur('sellEUR'),
  @JsonValue('buyRUB')
  buyRub('buyRUB'),
  @JsonValue('sellRUB')
  sellRub('sellRUB'),
  @JsonValue('buyCNY')
  buyCny('buyCNY'),
  @JsonValue('sellCNY')
  sellCny('sellCNY'),
  @JsonValue('buyGBP')
  buyGbp('buyGBP'),
  @JsonValue('sellGBP')
  sellGbp('sellGBP'),
  @JsonValue('buyXAU')
  buyXau('buyXAU'),
  @JsonValue('sellXAU')
  sellXau('sellXAU'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const SortBy(this.json);

  factory SortBy.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<SortBy> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
