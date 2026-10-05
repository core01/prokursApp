import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/exchange_points/presentation/forms/exchange_point_form.dart';
import 'package:prokurs/features/exchange_points/presentation/forms/form_inputs.dart';

ExchangePoint _point({String? description}) => ExchangePoint(
      id: 7,
      name: 'Обменник',
      info: 'ул. Абая 1',
      phones: ['+7 701 123 4567'],
      city_id: 2,
      gross: 0,
      day_and_night: 1,
      date_update: 1700000000,
      longitude: 76.9,
      latitude: 43.2,
      wholesaleNote: 'от 100 000',
      workModes: const WorkModesDto(mon: ['09:00', '18:00', '', '']),
      description: description,
      buyUSD: 480,
      sellUSD: 485,
      buyEUR: 0,
      sellEUR: 0,
      buyRUB: 0,
      sellRUB: 0,
      buyCNY: 0,
      sellCNY: 0,
      buyGBP: 0,
      sellGBP: 0,
    );

bool _rateAccepted(String text) =>
    rateInputFormatter
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text))
        .text ==
    text;

void main() {
  test('rate fields take only non-negative numbers with up to 2 decimals', () {
    for (final rate in ['', '0', '485', '485,5', '485.55', '999999.99']) {
      expect(_rateAccepted(rate), isTrue, reason: rate);
    }
    for (final rate in ['-1', '485.555', '1234567', '1e3', '48,5,5']) {
      expect(_rateAccepted(rate), isFalse, reason: rate);
    }
  });

  test('rate errors: blank is fine, the rest says what is wrong', () {
    String? error(String rate) => ExchangePointFormValidation.rateError(rate);

    expect(error(''), isNull);
    expect(error('485,55'), isNull);
    expect(error('-1'), 'не может быть отрицательным');
    expect(error('485,555'), 'не больше двух знаков после запятой');
    expect(error('1000000'), 'слишком большое значение');
    expect(error('abc'), 'введите число');
  });

  test('a rate from the server that is negative blocks saving and is named', () {
    final form = ExchangePointForm.fromExchangePoint(_point()).copyWith(buyUSD: '-1');

    expect(form.isValid, isFalse);
    expect(form.errorSummary(), ['Покупка USD — не может быть отрицательным']);
  });

  test('PUT body keeps the fields the form does not edit', () {
    final original = _point(description: 'Без комиссии');
    final form =
        ExchangePointForm.fromExchangePoint(original).copyWith(buyUSD: '490');

    final input = form.toReplaceInput(original);

    expect(input.buyUsd, 490);
    expect(input.phoneNumbers, ['+7 701 123 4567']);
    expect(input.dayAndNight, 1);
    expect(input.longitude, 76.9);
    expect(input.latitude, 43.2);
    expect(input.workModes?.mon, ['09:00', '18:00', '', '']);
    expect(input.description, 'Без комиссии');
  });

  test('the wholesale conditions are sent as typed, blank as null, kept with gross off', () {
    final original = _point();
    final form = ExchangePointForm.fromExchangePoint(original);
    expect(form.wholesaleNote, 'от 100 000');

    final typed = form.copyWith(wholesaleNote: '  от 1 000 000  ');
    expect(typed.toReplaceInput(original).wholesaleNote, 'от 1 000 000');
    // Off (gross 0) hides them in the API, so switching it back on brings them back.
    expect(typed.copyWith(gross: 0).toReplaceInput(original).wholesaleNote, 'от 1 000 000');

    final cleared = form.copyWith(wholesaleNote: '  ');
    expect(cleared.toReplaceInput(original).toJson()['wholesale_note'], isNull);
    expect(cleared.copyWith(city: const CityInput.dirty(2)).toCreateInput().wholesaleNote,
        isNull);
  });

  test('PUT body sends cleared fields as explicit null', () {
    final original = _point();
    final json =
        ExchangePointForm.fromExchangePoint(original).toReplaceInput(original).toJson();

    expect(json.containsKey('description'), isTrue);
    expect(json['description'], isNull);
  });

  test('days without a schedule are left out of work_modes', () {
    final json = const WorkModesDto(mon: ['09:00', '18:00', '', '']).toJson();

    expect(json.keys, ['mon']);
  });

  test('phones: +7 and 10 digits or a 4-digit short number', () {
    for (final phone in [
      '2274',
      '1174',
      '+77771234567',
      '+79991234567',
      '+7 701 123 4567',
      '+7 (7172) 55-55-55',
    ]) {
      expect(PhonesInput.isValidNumber(phone), isTrue, reason: phone);
    }
    for (final phone in [
      '87011234567',
      '+1 202 555 0123',
      '12345',
      '+7 701 123 456',
      '+7 701 123 45ab',
    ]) {
      expect(PhonesInput.isValidNumber(phone), isFalse, reason: phone);
    }
  });

  test('phones: blank fields are ignored, a number needs a country code', () {
    expect(const PhonesInput.dirty(['+7 701 123 4567', ' ']).numbers,
        ['+7 701 123 4567']);
    expect(const PhonesInput.dirty(['', '  ']).validator(['', '  ']),
        PhoneValidationError.empty);
    expect(const PhonesInput.dirty(['87011234567']).validator(['87011234567']),
        PhoneValidationError.invalid);
    expect(
        const PhonesInput.dirty(['+7 701 123 4567']).validator(['+7 701 123 4567']),
        isNull);
  });
}
