// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'work_modes_dto.dart';

part 'public_point_v2_dto.g.dart';

@JsonSerializable()
class PublicPointV2Dto {
  const PublicPointV2Dto({
    required this.id,
    required this.name,
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
    required this.cityId,
    required this.dayAndNight,
    required this.companyId,
    required this.sorting,
    required this.gross,
    required this.dateUpdate,
    required this.phones,
    this.info,
    this.phoneNumbers,
    this.longitude,
    this.latitude,
    this.atms,
    this.logo,
    this.wholesaleNote,
    this.workModes,
    this.description,
  });
  
  factory PublicPointV2Dto.fromJson(Map<String, Object?> json) => _$PublicPointV2DtoFromJson(json);
  
  /// Unique identifier of the point
  final int id;

  /// Point name
  final String name;

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

  /// City identifier
  @JsonKey(name: 'city_id')
  final int cityId;

  /// Day & night flag
  @JsonKey(name: 'day_and_night')
  final int dayAndNight;

  /// Company identifier
  @JsonKey(name: 'company_id')
  final int companyId;

  /// Additional info / address
  @JsonKey(includeIfNull: false)
  final String? info;

  /// Structured phone numbers (preferred going forward; falls back to the legacy phones string when absent)
  @JsonKey(includeIfNull: false,name: 'phone_numbers')
  final List<String>? phoneNumbers;

  /// Sorting priority value
  final int sorting;

  /// Longitude coordinate
  @JsonKey(includeIfNull: false)
  final num? longitude;

  /// Latitude coordinate
  @JsonKey(includeIfNull: false)
  final num? latitude;

  /// Gross flag: 1 = wholesale rates offered
  final int gross;

  /// Available ATM description
  @JsonKey(includeIfNull: false)
  final String? atms;

  /// Logo URL
  @JsonKey(includeIfNull: false)
  final String? logo;

  /// Wholesale rate condition note, shown when gross=1
  @JsonKey(includeIfNull: false,name: 'wholesale_note')
  final String? wholesaleNote;

  /// Weekly working-hours schedule
  @JsonKey(includeIfNull: false,name: 'work_modes')
  final WorkModesDto? workModes;

  /// Free-text description of the office
  @JsonKey(includeIfNull: false)
  final String? description;

  /// Unix timestamp (seconds) when the point was last updated
  @JsonKey(name: 'date_update')
  final int dateUpdate;

  /// The point's phone_numbers formatted for display: +7 numbers in international format, 4-digit short numbers as they are
  final List<String> phones;

  Map<String, Object?> toJson() => _$PublicPointV2DtoToJson(this);
}
