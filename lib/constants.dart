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
  final IconData icon;
  final String unicode;

  const CurrencyItem(this.id, this.label, this.icon, this.unicode);
}

const USD = CurrencyItem(Currency.USD, Currency.USD, CupertinoIcons.money_dollar_circle_fill, '\u{0024}');
const EUR = CurrencyItem(Currency.EUR, Currency.EUR, CupertinoIcons.money_euro_circle_fill, '\u{20AC}');
const RUR = CurrencyItem(Currency.RUR, Currency.RUR, CupertinoIcons.money_rubl_circle_fill, '\u{20BD}');
const CNY = CurrencyItem(Currency.CNY, Currency.CNY, CupertinoIcons.money_yen_circle_fill, '\u{00A5}');
const GBP = CurrencyItem(Currency.GBP, Currency.GBP, CupertinoIcons.money_pound_circle_fill, '\u{00A3}');

const List<CurrencyItem> CURRENCY_LIST = const [
  USD,
  EUR,
  RUR,
  CNY,
  GBP,
];

const BUY_KEY = 'buy';
const SELL_KEY = 'sell';
