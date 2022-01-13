import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/models/exchange_point.dart';

var isDarkModeOn = () => SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;

String getPointCurrencyRateStringFormatted(ExchangePoint point, String property) {
  var numberFormatter = NumberFormat("####.00");
  num currencyValue = point.get(property);

  debugPrint('Utils -> getPointCurrencyRateStringFormatted property $property currencyValue $currencyValue');
  return currencyValue == 0 ? '-' : numberFormatter.format((currencyValue));
}
