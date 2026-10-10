import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/features/profile/domain/models/user_profile.dart';
import 'package:prokurs/features/profile/presentation/forms/organization_form.dart';

// A БИН with the right check digit: one of the numbers the API's and the web's specs use.
const _bin = '971240001315';

const _valid = OrganizationForm(organizationName: 'ТОО «Обмен»', bin: _bin);

void main() {
  group('validation', () {
    test('the name and the БИН are required, the rest may be blank', () {
      const empty = OrganizationForm();

      expect(empty.organizationNameError, 'Введите наименование организации');
      expect(empty.binError, 'Введите БИН');
      expect(empty.isValid, isFalse);
      expect(_valid.isValid, isTrue);
    });

    test('whether the form is valid does not depend on it being submitted', () {
      expect(const OrganizationForm().isSubmitted, isFalse);
      expect(const OrganizationForm().isValid, isFalse);
      expect(_valid.markSubmitted().isValid, isTrue);
    });

    test('a БИН is taken with the spaces people paste it with', () {
      expect(_valid.copyWith(bin: '9712 4000 1315').binError, isNull);
    });

    test('a БИН without the right check digit or length is wrong', () {
      const wrong = 'Неверный БИН: проверьте все 12 цифр';

      expect(_valid.copyWith(bin: '240540000700').binError, wrong);
      expect(_valid.copyWith(bin: '12345').binError, wrong);
    });

    test('the contact phone is +7 and 10 digits, separators allowed', () {
      expect(_valid.copyWith(contactPhone: '+7 (701) 123-45-67').contactPhoneError, isNull);
      expect(_valid.copyWith(contactPhone: '').contactPhoneError, isNull);
      expect(_valid.copyWith(contactPhone: '8 701 123 4567').contactPhoneError,
          'Формат: +7 701 123 4567');
      // A short number is a point's phone, not an organization's.
      expect(_valid.copyWith(contactPhone: '2274').contactPhoneError, isNotNull);
    });

    test('a license date can not be later than today', () {
      final later = DateTime.now().add(const Duration(days: 2));

      expect(_valid.copyWith(licenseDate: later).licenseDateError, 'Дата не может быть в будущем');
      expect(_valid.copyWith(licenseDate: DateTime(2024, 3, 5)).licenseDateError, isNull);
    });

    test("texts stop at the API's 255 characters", () {
      expect(_valid.copyWith(legalAddress: 'я' * 256).legalAddressError, 'Не больше 255 символов');
      expect(_valid.copyWith(legalAddress: 'я' * 255).legalAddressError, isNull);
    });
  });

  group('the request', () {
    test('sends every field, cleaned', () {
      final json = _valid
          .copyWith(
            organizationName: '  ТОО «Обмен» ',
            bin: '9712 4000 1315',
            legalAddress: ' г. Астана ',
            contactPhone: '+7 (701) 123-45-67',
            licenseNumber: ' 12-34 ',
            licenseDate: DateTime(2024, 3, 5),
          )
          .toInput()
          .toJson();

      expect(json, {
        'organizationName': 'ТОО «Обмен»',
        'bin': '971240001315',
        'legalAddress': 'г. Астана',
        // A blank text is sent as '': the API clears it.
        'directorName': '',
        'contactPhone': '+77011234567',
        'licenseNumber': '12-34',
        'licenseDate': '2024-03-05T00:00:00.000',
      });
    });

    test('a blank date is sent as an explicit null: a missing key means «unchanged»', () {
      final json = _valid.toInput().toJson();

      expect(json.containsKey('licenseDate'), isTrue);
      expect(json['licenseDate'], isNull);
    });

    test('clearing the date takes a set date away, other edits keep it', () {
      final form = _valid.copyWith(licenseDate: DateTime(2024, 3, 5));

      expect(form.copyWith(clearLicenseDate: true).licenseDate, isNull);
      expect(form.copyWith(bin: _bin).licenseDate, DateTime(2024, 3, 5));
    });
  });

  test('a form starts from the saved profile', () {
    final form = OrganizationForm.fromProfile(UserProfile(
      username: 'owner@mail.kz',
      organizationName: 'ТОО «Обмен»',
      bin: _bin,
      licenseDate: DateTime(2024, 3, 5),
    ));

    expect(form.organizationName, 'ТОО «Обмен»');
    expect(form.bin, _bin);
    expect(form.legalAddress, '');
    expect(form.licenseDate, DateTime(2024, 3, 5));
    expect(form.isSubmitted, isFalse);
  });
}
