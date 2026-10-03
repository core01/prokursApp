// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'work_modes_dto.g.dart';

@JsonSerializable()
class WorkModesDto {
  const WorkModesDto({
    this.mon,
    this.tue,
    this.wed,
    this.thu,
    this.fri,
    this.sat,
    this.sun,
    this.holyday,
  });
  
  factory WorkModesDto.fromJson(Map<String, Object?> json) => _$WorkModesDtoFromJson(json);
  
  /// Working hours for the day as [open1, close1, open2, close2]. An empty string pair means the office is closed. The second pair is an optional second shift (e.g. after a lunch break).
  @JsonKey(includeIfNull: false)
  final List<String>? mon;

  /// Working hours for the day as [open1, close1, open2, close2]. An empty string pair means the office is closed. The second pair is an optional second shift (e.g. after a lunch break).
  @JsonKey(includeIfNull: false)
  final List<String>? tue;

  /// Working hours for the day as [open1, close1, open2, close2]. An empty string pair means the office is closed. The second pair is an optional second shift (e.g. after a lunch break).
  @JsonKey(includeIfNull: false)
  final List<String>? wed;

  /// Working hours for the day as [open1, close1, open2, close2]. An empty string pair means the office is closed. The second pair is an optional second shift (e.g. after a lunch break).
  @JsonKey(includeIfNull: false)
  final List<String>? thu;

  /// Working hours for the day as [open1, close1, open2, close2]. An empty string pair means the office is closed. The second pair is an optional second shift (e.g. after a lunch break).
  @JsonKey(includeIfNull: false)
  final List<String>? fri;

  /// Working hours for the day as [open1, close1, open2, close2]. An empty string pair means the office is closed. The second pair is an optional second shift (e.g. after a lunch break).
  @JsonKey(includeIfNull: false)
  final List<String>? sat;

  /// Working hours for the day as [open1, close1, open2, close2]. An empty string pair means the office is closed. The second pair is an optional second shift (e.g. after a lunch break).
  @JsonKey(includeIfNull: false)
  final List<String>? sun;

  /// Working hours for the day as [open1, close1, open2, close2]. An empty string pair means the office is closed. The second pair is an optional second shift (e.g. after a lunch break). This entry overrides the weekday schedule on public holidays.
  @JsonKey(includeIfNull: false)
  final List<String>? holyday;

  Map<String, Object?> toJson() => _$WorkModesDtoToJson(this);
}
