// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_organization_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateOrganizationInput _$UpdateOrganizationInputFromJson(
  Map<String, dynamic> json,
) => UpdateOrganizationInput(
  organizationName: json['organizationName'] as String?,
  bin: json['bin'] as String?,
  legalAddress: json['legalAddress'] as String?,
  directorName: json['directorName'] as String?,
  contactPhone: json['contactPhone'] as String?,
  licenseNumber: json['licenseNumber'] as String?,
  licenseDate: json['licenseDate'] == null
      ? null
      : DateTime.parse(json['licenseDate'] as String),
);

Map<String, dynamic> _$UpdateOrganizationInputToJson(
  UpdateOrganizationInput instance,
) => <String, dynamic>{
  'organizationName': ?instance.organizationName,
  'bin': ?instance.bin,
  'legalAddress': ?instance.legalAddress,
  'directorName': ?instance.directorName,
  'contactPhone': ?instance.contactPhone,
  'licenseNumber': ?instance.licenseNumber,
  'licenseDate': ?instance.licenseDate?.toIso8601String(),
};
