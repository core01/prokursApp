// The rules for an organization's data, the same as the API's (UpdateOrganizationInput in the
// monolith) and the web's (entities/user/lib/bin.ts). Keep the three in step: their specs run
// the same numbers.

/// Spaces dropped: a БИН is often pasted grouped («123 456 789 012»).
String normalizeBin(String value) => value.replaceAll(RegExp(r'\s'), '');

// The registration's year and month (YYMM, the month 01-12), the legal entity's type (4-6: 4 is
// a resident, 5 a non-resident), its kind, a 5-digit number and a check digit.
final _binStructure = RegExp(r'^\d{2}(0[1-9]|1[0-2])[4-6]\d{7}$');

// The check digit: the first 11 digits weighted 1..11, mod 11. A remainder of 10 repeats it with
// the second weights; 10 again means no БИН has these 11 digits.
const _binWeights = [
  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
  [3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2],
];

int? _checkDigit(List<int> digits) {
  for (final weights in _binWeights) {
    var sum = 0;
    for (var i = 0; i < weights.length; i++) {
      sum += digits[i] * weights[i];
    }
    final rest = sum % 11;
    if (rest < 10) return rest;
  }
  return null;
}

/// A valid БИН: 12 digits of the right structure with the right check digit. [value] is taken
/// as is: pass it through [normalizeBin] first.
bool isValidBin(String value) {
  if (!_binStructure.hasMatch(value)) return false;
  final digits = value.codeUnits.map((c) => c - 0x30).toList();
  return _checkDigit(digits.sublist(0, 11)) == digits[11];
}

/// Separators people type (spaces, hyphens, parentheses) taken out: what the API stores.
String normalizeContactPhone(String value) => value.replaceAll(RegExp(r'[\s()-]'), '');

final _contactPhone = RegExp(r'^\+7\d{10}$');

/// An organization's contact phone: +7 and 10 digits, separators allowed. Unlike a point's
/// phone, a 4-digit short number isn't one.
bool isValidContactPhone(String value) => _contactPhone.hasMatch(normalizeContactPhone(value));

/// A date as a day, without a time.
DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// Today in Almaty, the project's time zone (UTC+5, no daylight saving since 2024).
DateTime todayInAlmaty([DateTime? now]) =>
    dateOnly((now ?? DateTime.now()).toUtc().add(const Duration(hours: 5)));

/// A license or an appendix is issued on a day that has come: not later than today in Almaty.
bool isNotFutureDate(DateTime value, [DateTime? now]) =>
    !dateOnly(value).isAfter(todayInAlmaty(now));

/// «15.03.2024», as people write a date; no locale data needed.
String formatDate(DateTime value) {
  final d = value.day.toString().padLeft(2, '0');
  final m = value.month.toString().padLeft(2, '0');
  return '$d.$m.${value.year}';
}
