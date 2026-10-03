// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_rates_with_bests_and_nb_rates_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointsRatesWithBestsAndNbRatesDto _$PointsRatesWithBestsAndNbRatesDtoFromJson(
  Map<String, dynamic> json,
) => PointsRatesWithBestsAndNbRatesDto(
  rates: (json['rates'] as List<dynamic>)
      .map((e) => PointWithParsedPhonesDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  best: CityBestCoursesDto.fromJson(json['best'] as Map<String, dynamic>),
  nbRates: (json['nbRates'] as List<dynamic>)
      .map((e) => NbRateDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PointsRatesWithBestsAndNbRatesDtoToJson(
  PointsRatesWithBestsAndNbRatesDto instance,
) => <String, dynamic>{
  'rates': instance.rates,
  'best': instance.best,
  'nbRates': instance.nbRates,
};
