import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/core/utils/organization_rules.dart';

/// The signed-in user as the profile shows them: the account and the organization (legal
/// entity) they run points for. Text the API doesn't have is '', so a form takes it as it is.
class UserProfile {
  const UserProfile({
    required this.username,
    this.organizationName = '',
    this.bin = '',
    this.legalAddress = '',
    this.directorName = '',
    this.contactPhone = '',
    this.licenseNumber = '',
    this.licenseDate,
    this.licenseStatus = 'unverified',
  });

  final String username;
  final String organizationName;
  final String bin;
  final String legalAddress;
  final String directorName;
  final String contactPhone;
  final String licenseNumber;

  /// The day the license was issued.
  final DateTime? licenseDate;

  /// The administration's check of the license: `unverified`, `verified` or `rejected`. Never
  /// edited here.
  final String licenseStatus;

  factory UserProfile.fromDto(PublicUserDto dto) {
    final organization = dto.organization;
    final date = organization?.licenseDate;
    return UserProfile(
      username: dto.username,
      organizationName: organization?.organizationName ?? '',
      bin: organization?.bin ?? '',
      legalAddress: organization?.legalAddress ?? '',
      directorName: organization?.directorName ?? '',
      contactPhone: organization?.contactPhone ?? '',
      licenseNumber: organization?.licenseNumber ?? '',
      licenseDate: date == null ? null : dateOnly(date),
      licenseStatus: organization?.licenseStatus?.json ?? 'unverified',
    );
  }
}
