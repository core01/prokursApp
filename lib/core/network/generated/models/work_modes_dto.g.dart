// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_modes_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkModesDto _$WorkModesDtoFromJson(Map<String, dynamic> json) => WorkModesDto(
  mon: (json['mon'] as List<dynamic>?)?.map((e) => e as String).toList(),
  tue: (json['tue'] as List<dynamic>?)?.map((e) => e as String).toList(),
  wed: (json['wed'] as List<dynamic>?)?.map((e) => e as String).toList(),
  thu: (json['thu'] as List<dynamic>?)?.map((e) => e as String).toList(),
  fri: (json['fri'] as List<dynamic>?)?.map((e) => e as String).toList(),
  sat: (json['sat'] as List<dynamic>?)?.map((e) => e as String).toList(),
  sun: (json['sun'] as List<dynamic>?)?.map((e) => e as String).toList(),
  holyday: (json['holyday'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$WorkModesDtoToJson(WorkModesDto instance) =>
    <String, dynamic>{
      'mon': ?instance.mon,
      'tue': ?instance.tue,
      'wed': ?instance.wed,
      'thu': ?instance.thu,
      'fri': ?instance.fri,
      'sat': ?instance.sat,
      'sun': ?instance.sun,
      'holyday': ?instance.holyday,
    };
