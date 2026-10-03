// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'work_modes_dto.dart';

part 'replace_point_v2_input.g.dart';

@JsonSerializable()
class ReplacePointV2Input {
  const ReplacePointV2Input({
    required this.name,
    required this.cityId,
    required this.info,
    required this.gross,
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
    required this.dayAndNight,
    required this.phoneNumbers,
    required this.longitude,
    required this.latitude,
    required this.wholesaleNote,
    required this.workModes,
    required this.description,
  });
  
  factory ReplacePointV2Input.fromJson(Map<String, Object?> json) => _$ReplacePointV2InputFromJson(json);
  
  /// Point name
  final String name;

  /// City identifier
  @JsonKey(name: 'city_id')
  final int cityId;

  /// Additional info / address
  final String info;

  /// Gross flag
  final int gross;

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

  /// Day & night flag
  @JsonKey(name: 'day_and_night')
  final int dayAndNight;

  /// Phone numbers: Kazakhstan/Russia numbers as +7 and 10 digits (e.g. +77771234567) or 4-digit short numbers (e.g. 2274). Spaces, hyphens and parentheses are accepted and stripped before saving.
  @JsonKey(includeIfNull: true,name: 'phone_numbers')
  final List<String>? phoneNumbers;

  /// Longitude coordinate
  @JsonKey(includeIfNull: true)
  final num? longitude;

  /// Latitude coordinate
  @JsonKey(includeIfNull: true)
  final num? latitude;

  /// Wholesale rate condition note, shown when gross=1
  @JsonKey(includeIfNull: true,name: 'wholesale_note')
  final String? wholesaleNote;

  /// Weekly working-hours schedule
  @JsonKey(includeIfNull: true,name: 'work_modes')
  final WorkModesDto? workModes;

  /// Free-text description of the office
  @JsonKey(includeIfNull: true)
  final String? description;

  Map<String, Object?> toJson() => _$ReplacePointV2InputToJson(this);
}
