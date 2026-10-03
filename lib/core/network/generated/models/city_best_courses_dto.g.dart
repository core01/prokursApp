// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_best_courses_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityBestCoursesDto _$CityBestCoursesDtoFromJson(Map<String, dynamic> json) =>
    CityBestCoursesDto(
      gross: BestCoursesDto.fromJson(json['gross'] as Map<String, dynamic>),
      retail: BestCoursesDto.fromJson(json['retail'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CityBestCoursesDtoToJson(CityBestCoursesDto instance) =>
    <String, dynamic>{'gross': instance.gross, 'retail': instance.retail};
