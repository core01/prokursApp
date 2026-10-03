// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nb_rate_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NbRateDto _$NbRateDtoFromJson(Map<String, dynamic> json) => NbRateDto(
  code: json['code'] as String,
  value: json['value'] as num?,
  quant: (json['quant'] as num).toInt(),
);

Map<String, dynamic> _$NbRateDtoToJson(NbRateDto instance) => <String, dynamic>{
  'code': instance.code,
  'value': instance.value,
  'quant': instance.quant,
};
