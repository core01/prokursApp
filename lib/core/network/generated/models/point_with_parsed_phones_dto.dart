// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'work_modes_dto.dart';

part 'point_with_parsed_phones_dto.g.dart';

@JsonSerializable()
class PointWithParsedPhonesDto {
  const PointWithParsedPhonesDto({
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
    required this.published,
    required this.sorting,
    required this.gross,
    required this.dateUpdate,
    required this.phones,
    this.info,
    this.longitude,
    this.latitude,
    this.atms,
    this.logo,
    this.wholesaleNote,
    this.workModes,
    this.description,
  });
  
  factory PointWithParsedPhonesDto.fromJson(Map<String, Object?> json) => _$PointWithParsedPhonesDtoFromJson(json);
  
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

  /// Publication status: 1 = published, 0 = on moderation
  final int published;

  /// Additional info / address
  @JsonKey(includeIfNull: false)
  final String? info;

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

  /// List of phone numbers
  final List<String> phones;

  Map<String, Object?> toJson() => _$PointWithParsedPhonesDtoToJson(this);
}
