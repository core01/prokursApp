// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'best_courses_dto.dart';

part 'city_best_courses_dto.g.dart';

@JsonSerializable()
class CityBestCoursesDto {
  const CityBestCoursesDto({
    required this.gross,
    required this.retail,
  });
  
  factory CityBestCoursesDto.fromJson(Map<String, Object?> json) => _$CityBestCoursesDtoFromJson(json);
  
  /// Best gross rates
  final BestCoursesDto gross;

  /// Best retail rates
  final BestCoursesDto retail;

  Map<String, Object?> toJson() => _$CityBestCoursesDtoToJson(this);
}
