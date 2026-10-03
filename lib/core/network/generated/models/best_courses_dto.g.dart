// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'best_courses_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BestCoursesDto _$BestCoursesDtoFromJson(Map<String, dynamic> json) =>
    BestCoursesDto(
      buyCny: json['buyCNY'] as num,
      buyUsd: json['buyUSD'] as num,
      buyEur: json['buyEUR'] as num,
      buyRub: json['buyRUB'] as num,
      buyXau: json['buyXAU'] as num,
      buyGbp: json['buyGBP'] as num,
      sellGbp: json['sellGBP'] as num,
      sellEur: json['sellEUR'] as num,
      sellCny: json['sellCNY'] as num,
      sellRub: json['sellRUB'] as num,
      sellUsd: json['sellUSD'] as num,
      sellXau: json['sellXAU'] as num,
    );

Map<String, dynamic> _$BestCoursesDtoToJson(BestCoursesDto instance) =>
    <String, dynamic>{
      'buyCNY': instance.buyCny,
      'buyUSD': instance.buyUsd,
      'buyEUR': instance.buyEur,
      'buyRUB': instance.buyRub,
      'buyXAU': instance.buyXau,
      'buyGBP': instance.buyGbp,
      'sellGBP': instance.sellGbp,
      'sellEUR': instance.sellEur,
      'sellCNY': instance.sellCny,
      'sellRUB': instance.sellRub,
      'sellUSD': instance.sellUsd,
      'sellXAU': instance.sellXau,
    };
