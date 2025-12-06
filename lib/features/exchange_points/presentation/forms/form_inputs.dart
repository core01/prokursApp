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

class PhonesInput extends FormzInput<String, PhoneValidationError> {
  const PhonesInput.pure() : super.pure('');
  const PhonesInput.dirty([super.value = '']) : super.dirty();

  @override
  PhoneValidationError? validator(String value) {
    return value.isEmpty ? PhoneValidationError.empty : null;
  }
}

// Rate Input (for currency rates)
enum RateValidationError { invalid }

class RateInput extends FormzInput<String, RateValidationError> {
  const RateInput.pure() : super.pure('');
  const RateInput.dirty([super.value = '']) : super.dirty();

  static final _rateRegex = RegExp(r'^(\d*\.?\d{0,2})?$');

  @override
  RateValidationError? validator(String value) {
    if (value.isEmpty) return null; // Empty is valid (no rate provided)

    // Check if it's a valid format
    if (!_rateRegex.hasMatch(value)) return RateValidationError.invalid;

    // Check if it's a valid number
    final parsed = double.tryParse(value);
    if (parsed == null) return RateValidationError.invalid;

    // Valid number within reasonable range
    return null;
  }

  double? toDouble() {
    if (value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  // Format the rate for display with proper decimal places
  String formattedValue() {
    if (value.isEmpty) return '';
    final parsed = double.tryParse(value);
    if (parsed == null) return value;

    // Format with 2 decimal places
    return parsed.toStringAsFixed(2);
  }
}

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
