// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_organization_input.g.dart';

@JsonSerializable()
class UpdateOrganizationInput {
  const UpdateOrganizationInput({
    this.organizationName,
    this.bin,
    this.legalAddress,
    this.directorName,
    this.contactPhone,
    this.licenseNumber,
    this.licenseDate,
  });
  
  factory UpdateOrganizationInput.fromJson(Map<String, Object?> json) => _$UpdateOrganizationInputFromJson(json);
  
  /// Full name of the legal entity
  @JsonKey(includeIfNull: false)
  final String? organizationName;

  /// BIN: 12 digits, with a correct check digit
  @JsonKey(includeIfNull: false)
  final String? bin;

  /// Legal address
  @JsonKey(includeIfNull: false)
  final String? legalAddress;

  /// The head's full name
  @JsonKey(includeIfNull: false)
  final String? directorName;

  /// Contact phone: +7 and 10 digits (e.g. +77771234567). Spaces, hyphens and parentheses are accepted and stripped before saving.
  @JsonKey(includeIfNull: false)
  final String? contactPhone;

  /// License number
  @JsonKey(includeIfNull: false)
  final String? licenseNumber;

  /// Date the license was issued, as YYYY-MM-DD, not later than today (Almaty)
  @JsonKey(includeIfNull: false)
  final DateTime? licenseDate;

  Map<String, Object?> toJson() => _$UpdateOrganizationInputToJson(this);
}
