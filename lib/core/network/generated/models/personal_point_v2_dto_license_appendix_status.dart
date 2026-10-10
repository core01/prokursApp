// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// The platform's check of the appendix; owners can't change it
@JsonEnum()
enum PersonalPointV2DtoLicenseAppendixStatus {
  @JsonValue('unverified')
  unverified('unverified'),
  @JsonValue('verified')
  verified('verified'),
  @JsonValue('rejected')
  rejected('rejected'),
  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const PersonalPointV2DtoLicenseAppendixStatus(this.json);

  factory PersonalPointV2DtoLicenseAppendixStatus.fromJson(String json) => values.firstWhere(
        (e) => e.json == json,
        orElse: () => $unknown,
      );

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  /// Returns all defined enum values excluding the $unknown value.
  static List<PersonalPointV2DtoLicenseAppendixStatus> get $valuesDefined => values.where((value) => value != $unknown).toList();
}
