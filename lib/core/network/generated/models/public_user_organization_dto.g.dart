// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_user_organization_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicUserOrganizationDto _$PublicUserOrganizationDtoFromJson(
  Map<String, dynamic> json,
) => PublicUserOrganizationDto(
  organizationName: json['organizationName'] as String?,
  bin: json['bin'] as String?,
  legalAddress: json['legalAddress'] as String?,
  directorName: json['directorName'] as String?,
  contactPhone: json['contactPhone'] as String?,
  licenseNumber: json['licenseNumber'] as String?,
  licenseDate: json['licenseDate'] == null
      ? null
      : DateTime.parse(json['licenseDate'] as String),
  licenseStatus: json['licenseStatus'] == null
      ? null
      : PublicUserOrganizationDtoLicenseStatus.fromJson(
          json['licenseStatus'] as String,
        ),
);

Map<String, dynamic> _$PublicUserOrganizationDtoToJson(
  PublicUserOrganizationDto instance,
) => <String, dynamic>{
  'organizationName': ?instance.organizationName,
  'bin': ?instance.bin,
  'legalAddress': ?instance.legalAddress,
  'directorName': ?instance.directorName,
  'contactPhone': ?instance.contactPhone,
  'licenseNumber': ?instance.licenseNumber,
  'licenseDate': ?instance.licenseDate?.toIso8601String(),
  'licenseStatus':
      ?_$PublicUserOrganizationDtoLicenseStatusEnumMap[instance.licenseStatus],
};

const _$PublicUserOrganizationDtoLicenseStatusEnumMap = {
  PublicUserOrganizationDtoLicenseStatus.unverified: 'unverified',
  PublicUserOrganizationDtoLicenseStatus.verified: 'verified',
  PublicUserOrganizationDtoLicenseStatus.rejected: 'rejected',
  PublicUserOrganizationDtoLicenseStatus.$unknown: r'$unknown',
};
