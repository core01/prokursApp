import 'package:flag/flag.dart';
import 'package:flutter/cupertino.dart';

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

class DarkTheme {
  const DarkTheme();

  static const mainBlack = Color(0xFF24292f);

  static const darkSecondary = Color(0xFF8d8e8e);

  static const generalBlack = Color(0xFF1b1d1e);

  static const generalWhite = Color(0xFFFFFFFF);

  static const lightBg = Color(0xFFf4f4f5);

  static const lightSecondary = Color(0xFF9b9ca3);

  static const lightDivider = Color(0xFFebeded);

  static const mainGrey = Color(0xFF494a4b);

  static const mainBlue = Color(0xFF00A6FB);

  static const mainRed = Color(0xFFC14953);
}

class AppColors {
  static const generalBlack = Color(0xFF1B1D1E);
  static const mainBlack = Color(0xFF24292f); // Dark theme color
  static const lightBg = Color.fromRGBO(244, 244, 245, 1);
  static const lightSecondary = Color.fromRGBO(27, 29, 30, 0.35);
  static const lightDivider = Color.fromRGBO(5, 25, 35, 0.08);
  static const generalGreen = Color.fromRGBO(0, 165, 36, 1);
  static const generalGreenBg = Color.fromRGBO(0, 165, 36, 0.08);
  static const generalRed = Color.fromRGBO(218, 21, 0, 1);
  static const generalRedBg = Color.fromRGBO(218, 21, 0, 0.08);
}

class Typography {
  static const heading = TextStyle(
    fontFamily: "Manrope",
    fontSize: 22, // title 2   22, 28/22   // Design 20, 24/20
    fontWeight: FontWeight.w600,
    height: 26 / 22,
  );

  static const heading2 = TextStyle(
    fontFamily: "Manrope",
    fontSize: 17, // title 3 20, 25/20  // Design 14, 21/14
    fontWeight: FontWeight.w600,
    height: 22 / 17,
  );

  static const body = TextStyle(
    fontFamily: "Manrope",
    fontSize: 19, // body 17, 22/17 // Design 16, 24/16
    fontWeight: FontWeight.w500,
    height: 24 / 19,
  );

  static const body2 = TextStyle(
    fontFamily: "Manrope",
    fontSize: 17, // Callout 16, 21/16 // Design 14, 21/14
    fontWeight: FontWeight.w500,
    height: 22 / 17,
  );

  static const body3 = TextStyle(
    fontFamily: "Manrope",
    fontSize: 14, // Subhead  15, 20/15  // Design 12, 18/12
    fontWeight: FontWeight.w500,
    height: 19 / 14,
  );
}
