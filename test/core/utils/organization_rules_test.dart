import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/utils/organization_rules.dart';

// The same numbers as the API's bin.util.spec.ts and the web's bin.spec.ts.
void main() {
  group('isValidBin', () {
    test('accepts real and synthetic БИН, including one on the second weights', () {
      for (final bin in [
        '971240001315', // Kaspi Bank
        '940140000385', // Halyk Bank
        '240540123458',
        '240540000711', // the first weights leave 10: the second give the check digit
      ]) {
        expect(isValidBin(bin), isTrue, reason: bin);
      }
    });

    test('rejects a wrong check digit, a typo, a swap and a number no БИН can have', () {
      for (final bin in [
        '971240001316', // wrong check digit
        '971240001415', // a mistyped digit
        '971240010315', // two digits swapped
        '240540000700', // both weight sequences leave 10: no valid 12th digit
      ]) {
        expect(isValidBin(bin), isFalse, reason: bin);
      }
    });

    test('rejects a wrong month or type digit, a wrong length and non-digits', () {
      for (final bin in [
        '971340001315', // month 13
        '970040001315', // month 00
        '971230001315', // type digit 3
        '971270001315', // type digit 7
        '123456789012', // an invented number
        '97124000131', // 11 digits
        '9712400013155', // 13 digits
        '97124000131a',
        '971 240 001 315', // spaces: normalizeBin first
        '',
      ]) {
        expect(isValidBin(bin), isFalse, reason: bin);
      }
    });

    test('normalizeBin drops the spaces of a grouped, pasted number', () {
      expect(isValidBin(normalizeBin('971 240 001 315')), isTrue);
      expect(normalizeBin(' 971240001315 '), '971240001315');
    });
  });

  group('contact phone', () {
    test('takes +7 and 10 digits, separators allowed', () {
      for (final phone in ['+77771234567', '+7 701 123 4567', '+7 (7172) 55-55-55']) {
        expect(isValidContactPhone(phone), isTrue, reason: phone);
      }
      expect(normalizeContactPhone('+7 (777) 123-45-67'), '+77771234567');
    });

    test("rejects a point's 4-digit short number and other formats", () {
      for (final phone in ['2274', '87011234567', '+1 202 555 0123', '+7 701 123 456', '']) {
        expect(isValidContactPhone(phone), isFalse, reason: phone);
      }
    });
  });

  group('dates', () {
    // 22:00 UTC on 9 Oct is already 10 Oct 03:00 in Almaty (UTC+5), whatever the machine's zone.
    final now = DateTime.utc(2026, 10, 9, 22);

    test('today is the day in Almaty', () {
      expect(todayInAlmaty(now), DateTime(2026, 10, 10));
    });

    test('a day up to today is not in the future, a later one is', () {
      expect(isNotFutureDate(DateTime(2026, 10, 10), now), isTrue);
      expect(isNotFutureDate(DateTime(2024, 3, 15), now), isTrue);
      expect(isNotFutureDate(DateTime(2026, 10, 11), now), isFalse);
      expect(isNotFutureDate(DateTime(2099, 1, 1), now), isFalse);
    });

    test('a date is written the way people write it', () {
      expect(formatDate(DateTime(2024, 3, 5)), '05.03.2024');
      expect(dateOnly(DateTime(2024, 3, 15, 13, 45)), DateTime(2024, 3, 15));
    });
  });
}
