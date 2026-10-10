// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_points_rates_v2_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePointsRatesV2Input _$UpdatePointsRatesV2InputFromJson(
  Map<String, dynamic> json,
) => UpdatePointsRatesV2Input(
  pointIds: (json['pointIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  rates: CurrencyRatesV2.fromJson(json['rates'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UpdatePointsRatesV2InputToJson(
  UpdatePointsRatesV2Input instance,
) => <String, dynamic>{'pointIds': instance.pointIds, 'rates': instance.rates};
