import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/core/utils/organization_rules.dart';
import 'package:prokurs/features/profile/domain/models/user_profile.dart';

/// [UpdateOrganizationInput] that can also say «clear the date»: the generated model leaves a
/// null out of the JSON, and the API reads a field left out as «unchanged».
class OrganizationInput extends UpdateOrganizationInput {
  const OrganizationInput({
    super.organizationName,
    super.bin,
    super.legalAddress,
    super.directorName,
    super.contactPhone,
    super.licenseNumber,
    super.licenseDate,
    this.clearLicenseDate = false,
  });

  final bool clearLicenseDate;

  @override
  Map<String, Object?> toJson() => {
        ...super.toJson(),
        if (clearLicenseDate) 'licenseDate': null,
      };
}

/// The profile's organization form: what is typed, what is wrong with it, and the request.
/// The name and the БИН are required, as on the web; the rest may be blank, which clears it.
class OrganizationForm {
  const OrganizationForm({
    this.organizationName = '',
    this.bin = '',
    this.legalAddress = '',
    this.directorName = '',
    this.contactPhone = '',
    this.licenseNumber = '',
    this.licenseDate,
    this.isSubmitted = false,
  });

  /// The API's column length for every text.
  static const maxLength = 255;

  final String organizationName;
  final String bin;
  final String legalAddress;
  final String directorName;
  final String contactPhone;
  final String licenseNumber;
  final DateTime? licenseDate;

  /// Errors are shown from the first press of «Сохранить».
  final bool isSubmitted;

  factory OrganizationForm.fromProfile(UserProfile profile) => OrganizationForm(
        organizationName: profile.organizationName,
        bin: profile.bin,
        legalAddress: profile.legalAddress,
        directorName: profile.directorName,
        contactPhone: profile.contactPhone,
        licenseNumber: profile.licenseNumber,
        licenseDate: profile.licenseDate,
      );

  OrganizationForm copyWith({
    String? organizationName,
    String? bin,
    String? legalAddress,
    String? directorName,
    String? contactPhone,
    String? licenseNumber,
    DateTime? licenseDate,
    // A null date can't say «no date» by itself: it means «unchanged».
    bool clearLicenseDate = false,
    bool? isSubmitted,
  }) {
    return OrganizationForm(
      organizationName: organizationName ?? this.organizationName,
      bin: bin ?? this.bin,
      legalAddress: legalAddress ?? this.legalAddress,
      directorName: directorName ?? this.directorName,
      contactPhone: contactPhone ?? this.contactPhone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseDate: clearLicenseDate ? null : licenseDate ?? this.licenseDate,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  OrganizationForm markSubmitted() => isSubmitted ? this : copyWith(isSubmitted: true);

  // What is wrong with each field, or null. The page shows them once [isSubmitted].

  String? get organizationNameError {
    if (organizationName.trim().isEmpty) return 'Введите наименование организации';
    return _tooLong(organizationName);
  }

  String? get binError {
    final value = normalizeBin(bin);
    if (value.isEmpty) return 'Введите БИН';
    return isValidBin(value) ? null : 'Неверный БИН: проверьте все 12 цифр';
  }

  String? get legalAddressError => _tooLong(legalAddress);

  String? get directorNameError => _tooLong(directorName);

  String? get licenseNumberError => _tooLong(licenseNumber);

  String? get contactPhoneError {
    final value = contactPhone.trim();
    if (value.isEmpty) return null;
    return isValidContactPhone(value) ? null : 'Формат: +7 701 123 4567';
  }

  /// The wheel doesn't go past today, so a later day can only be one the server already holds.
  String? get licenseDateError {
    final date = licenseDate;
    if (date == null) return null;
    return isNotFutureDate(date) ? null : 'Дата не может быть в будущем';
  }

  bool get isValid => [
        organizationNameError,
        binError,
        legalAddressError,
        directorNameError,
        licenseNumberError,
        contactPhoneError,
        licenseDateError,
      ].every((error) => error == null);

  /// Call only on a valid form. Every field is sent, as on the web: a blank text
  /// clears it, and so does [OrganizationInput.clearLicenseDate] for the date.
  OrganizationInput toInput() => OrganizationInput(
        organizationName: organizationName.trim(),
        bin: normalizeBin(bin),
        legalAddress: legalAddress.trim(),
        directorName: directorName.trim(),
        contactPhone: normalizeContactPhone(contactPhone.trim()),
        licenseNumber: licenseNumber.trim(),
        licenseDate: licenseDate,
        clearLicenseDate: licenseDate == null,
      );

  static String? _tooLong(String value) =>
      value.trim().length > maxLength ? 'Не больше $maxLength символов' : null;
}
