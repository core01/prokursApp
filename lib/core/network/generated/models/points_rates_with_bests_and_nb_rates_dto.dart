// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'city_best_courses_dto.dart';
import 'nb_rate_dto.dart';
import 'point_with_parsed_phones_dto.dart';

part 'points_rates_with_bests_and_nb_rates_dto.g.dart';

@JsonSerializable()
class PointsRatesWithBestsAndNbRatesDto {
  const PointsRatesWithBestsAndNbRatesDto({
    required this.rates,
    required this.best,
    required this.nbRates,
  });
  
  factory PointsRatesWithBestsAndNbRatesDto.fromJson(Map<String, Object?> json) => _$PointsRatesWithBestsAndNbRatesDtoFromJson(json);
  
  /// List of exchange points with rates
  final List<PointWithParsedPhonesDto> rates;

  /// Best rates in the city
  final CityBestCoursesDto best;

  /// National Bank rates
  final List<NbRateDto> nbRates;

  Map<String, Object?> toJson() => _$PointsRatesWithBestsAndNbRatesDtoToJson(this);
}
