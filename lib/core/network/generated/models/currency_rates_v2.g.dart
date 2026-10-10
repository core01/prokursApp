// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_rates_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyRatesV2 _$CurrencyRatesV2FromJson(Map<String, dynamic> json) =>
    CurrencyRatesV2(
      buyUsd: json['buyUSD'] as num,
      sellUsd: json['sellUSD'] as num,
      buyEur: json['buyEUR'] as num,
      sellEur: json['sellEUR'] as num,
      buyRub: json['buyRUB'] as num,
      sellRub: json['sellRUB'] as num,
      buyCny: json['buyCNY'] as num,
      sellCny: json['sellCNY'] as num,
      buyGbp: json['buyGBP'] as num,
      sellGbp: json['sellGBP'] as num,
    );

Map<String, dynamic> _$CurrencyRatesV2ToJson(CurrencyRatesV2 instance) =>
    <String, dynamic>{
      'buyUSD': instance.buyUsd,
      'sellUSD': instance.sellUsd,
      'buyEUR': instance.buyEur,
      'sellEUR': instance.sellEur,
      'buyRUB': instance.buyRub,
      'sellRUB': instance.sellRub,
      'buyCNY': instance.buyCny,
      'sellCNY': instance.sellCny,
      'buyGBP': instance.buyGbp,
      'sellGBP': instance.sellGbp,
    };
