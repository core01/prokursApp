import 'package:flutter/cupertino.dart';

class Currency {
  static const String USD = 'USD';
  static const String EUR = 'EUR';
  static const String RUR = 'RUB';
  static const String CNY = 'CNY';
  static const String GBP = 'GBP';
}

const List<Map<String, dynamic>> CURRENCY_LIST = const [
  {
    'id': Currency.USD,
    'label': 'USD',
    'icon': CupertinoIcons.money_dollar_circle_fill,
    'unicode': '\u{0024}'
  },
  {
    'id': Currency.EUR,
    'label': 'EUR',
    'icon': CupertinoIcons.money_euro_circle_fill,
    'unicode': '\u{20AC}'
  },
  {
    'id': Currency.RUR,
    'label': 'RUR',
    'icon': CupertinoIcons.money_rubl_circle_fill,
    'unicode': '\u{20BD}'
  },
  {
    'id': Currency.CNY,
    'label': 'CNY',
    'icon': CupertinoIcons.money_yen_circle_fill,
    'unicode': '\u{00A5}',
  },
  {
    'id': Currency.GBP,
    'label': 'GBP',
    'icon': CupertinoIcons.money_pound_circle_fill,
    'unicode': '\u{00A3}'
  },
];
