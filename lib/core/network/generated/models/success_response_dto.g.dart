// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuccessResponseDto _$SuccessResponseDtoFromJson(Map<String, dynamic> json) =>
    SuccessResponseDto(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SuccessResponseDtoToJson(SuccessResponseDto instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': ?instance.message,
    };
