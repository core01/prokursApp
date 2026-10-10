import 'package:flag/flag.dart';

class Currency {
  static const String usd = 'USD';
  static const String eur = 'EUR';
  static const String rub = 'RUB';
  static const String cny = 'CNY';
  static const String gbp = 'GBP';
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

const usd =
    CurrencyItem(Currency.usd, Currency.usd, '🇺🇸', '\u{0024}', FlagsCode.US);
const eur =
    CurrencyItem(Currency.eur, Currency.eur, '🇪🇺', '\u{20AC}', FlagsCode.EU);
const rub =
    CurrencyItem(Currency.rub, Currency.rub, '🇷🇺', '\u{20BD}', FlagsCode.RU);
const cny =
    CurrencyItem(Currency.cny, Currency.cny, '🇨🇳', '\u{00A5}', FlagsCode.CN);
const gbp =
    CurrencyItem(Currency.gbp, Currency.gbp, '🇬🇧', '\u{00A3}', FlagsCode.GB);

const List<CurrencyItem> currencyList = [
  usd,
  eur,
  rub,
  cny,
  gbp,
];

// A rate key is one of these plus the currency code: buyUSD, sellEUR.
const buyPrefix = 'buy';
const sellPrefix = 'sell';

class SignUpResult {
  final String email;
  final String password;

  SignUpResult({required this.email, required this.password});
}
