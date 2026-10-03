import 'package:flutter/services.dart';
import 'package:formz/formz.dart';

// Name Input
enum NameValidationError { empty }

class NameInput extends FormzInput<String, NameValidationError> {
  const NameInput.pure() : super.pure('');
  const NameInput.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String value) {
    return value.isEmpty ? NameValidationError.empty : null;
  }
}

// Address Input
enum AddressValidationError { empty }

class InfoInput extends FormzInput<String, AddressValidationError> {
  const InfoInput.pure() : super.pure('');
  const InfoInput.dirty([super.value = '']) : super.dirty();

  @override
  AddressValidationError? validator(String value) {
    return value.isEmpty ? AddressValidationError.empty : null;
  }
}

// Phone Input
enum PhoneValidationError { empty, invalid }

/// One entry per phone field on the form, blank fields included.
class PhonesInput extends FormzInput<List<String>, PhoneValidationError> {
  const PhonesInput.pure() : super.pure(const ['']);
  const PhonesInput.dirty([super.value = const ['']]) : super.dirty();

  // The API v2 rule: a 4-digit short number (2274) or +7 and 10 digits. Spaces, hyphens and
  // parentheses are allowed: the API strips them before saving.
  static final _phoneRegex = RegExp(r'^(\d{4}|\+7\d{10})$');

  static bool isValidNumber(String phone) =>
      _phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s()-]'), ''));

  static List<String> _filled(List<String> phones) =>
      phones.map((phone) => phone.trim()).where((p) => p.isNotEmpty).toList();

  /// The entered numbers without the blank fields.
  List<String> get numbers => _filled(value);

  @override
  PhoneValidationError? validator(List<String> value) {
    final numbers = _filled(value);
    if (numbers.isEmpty) return PhoneValidationError.empty;
    return numbers.every(isValidNumber) ? null : PhoneValidationError.invalid;
  }
}

/// Lets a rate field hold only what the API accepts: no minus, at most 2 decimal places and 6
/// digits before the separator (the column is DECIMAL(8,2)). Blank is fine: it is saved as 0.
final rateInputFormatter = TextInputFormatter.withFunction(
  (oldValue, newValue) =>
      RegExp(r'^\d{0,6}([.,]\d{0,2})?$').hasMatch(newValue.text) ? newValue : oldValue,
);

// City Input
enum CityValidationError { empty }

class CityInput extends FormzInput<int?, CityValidationError> {
  const CityInput.pure() : super.pure(null);
  const CityInput.dirty([super.value]) : super.dirty();

  @override
  CityValidationError? validator(int? value) {
    return value == null ? CityValidationError.empty : null;
  }
}
