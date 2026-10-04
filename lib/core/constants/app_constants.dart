import 'package:flag/flag.dart';

class Currency {
  static const String USD = 'USD';
  static const String EUR = 'EUR';
  static const String RUR = 'RUB';
  static const String CNY = 'CNY';
  static const String GBP = 'GBP';
}

class CurrencyItem {
  final String id;
  final String label;
  final String icon;
  final String unicode;
  final FlagsCode countryCode;

  const CurrencyItem(
      this.id, this.label, this.icon, this.unicode, this.countryCode);
}

const USD =
    CurrencyItem(Currency.USD, Currency.USD, '🇺🇸', '\u{0024}', FlagsCode.US);
const EUR =
    CurrencyItem(Currency.EUR, Currency.EUR, '🇪🇺', '\u{20AC}', FlagsCode.EU);
const RUR =
    CurrencyItem(Currency.RUR, Currency.RUR, '🇷🇺', '\u{20BD}', FlagsCode.RU);
const CNY =
    CurrencyItem(Currency.CNY, Currency.CNY, '🇨🇳', '\u{00A5}', FlagsCode.CN);
const GBP =
    CurrencyItem(Currency.GBP, Currency.GBP, '🇬🇧', '\u{00A3}', FlagsCode.GB);

const List<CurrencyItem> CURRENCY_LIST = [
  USD,
  EUR,
  RUR,
  CNY,
  GBP,
];

const BUY_KEY = 'buy';
const SELL_KEY = 'sell';

class SignUpResult {
  final String email;
  final String password;

  SignUpResult({required this.email, required this.password});
}
