// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'work_modes_dto.dart';

part 'create_point_v2_input.g.dart';

@JsonSerializable()
class CreatePointV2Input {
  const CreatePointV2Input({
    required this.name,
    required this.cityId,
    required this.info,
    required this.gross,
    this.buyUsd = 0,
    this.sellUsd = 0,
    this.buyEur = 0,
    this.sellEur = 0,
    this.buyRub = 0,
    this.sellRub = 0,
    this.buyCny = 0,
    this.sellCny = 0,
    this.buyGbp = 0,
    this.sellGbp = 0,
    this.dayAndNight,
    this.phoneNumbers,
    this.longitude,
    this.latitude,
    this.wholesaleNote,
    this.workModes,
    this.description,
    this.licenseAppendixNumber,
    this.licenseAppendixDate,
  });
  
  factory CreatePointV2Input.fromJson(Map<String, Object?> json) => _$CreatePointV2InputFromJson(json);
  
  /// Point name
  final String name;

  /// City identifier
  @JsonKey(name: 'city_id')
  final int cityId;

  /// Additional info / address
  final String info;

  /// Gross flag
  final int gross;

  /// Day & night flag
  @JsonKey(includeIfNull: false,name: 'day_and_night')
  final int? dayAndNight;

  /// Phone numbers: Kazakhstan/Russia numbers as +7 and 10 digits (e.g. +77771234567) or 4-digit short numbers (e.g. 2274). Spaces, hyphens and parentheses are accepted and stripped before saving.
  @JsonKey(includeIfNull: false,name: 'phone_numbers')
  final List<String>? phoneNumbers;

  /// Longitude coordinate
  @JsonKey(includeIfNull: false)
  final num? longitude;

  /// Latitude coordinate
  @JsonKey(includeIfNull: false)
  final num? latitude;

  /// Wholesale rate condition note, shown when gross=1
  @JsonKey(includeIfNull: false,name: 'wholesale_note')
  final String? wholesaleNote;

  /// Weekly working-hours schedule
  @JsonKey(includeIfNull: false,name: 'work_modes')
  final WorkModesDto? workModes;

  /// Free-text description of the office
  @JsonKey(includeIfNull: false)
  final String? description;

  /// Number of the license appendix issued for this point
  @JsonKey(includeIfNull: false,name: 'license_appendix_number')
  final String? licenseAppendixNumber;

  /// Date the license appendix was issued, as YYYY-MM-DD, not later than today (Almaty)
  @JsonKey(includeIfNull: false,name: 'license_appendix_date')
  final DateTime? licenseAppendixDate;

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

  Map<String, Object?> toJson() => _$CreatePointV2InputToJson(this);
}
