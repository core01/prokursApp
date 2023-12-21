import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/models/exchange_point.dart';

var isDarkModeOn = () =>
    SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

const String EMPTY_CURRENCY_VALUE = '-';

String getPointCurrencyRateStringFormatted(
    ExchangePoint point, String property) {
  var numberFormatter = NumberFormat("####.00");
  num currencyValue = point.get(property);

  return currencyValue == 0
      ? EMPTY_CURRENCY_VALUE
      : numberFormatter.format((currencyValue));
}

bool canRenderCurrencyRow(String buyValue, String sellValue) {
  return buyValue != EMPTY_CURRENCY_VALUE || sellValue != EMPTY_CURRENCY_VALUE;
}

String getUpdateTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}
