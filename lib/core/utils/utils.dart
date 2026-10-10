import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:url_launcher/url_launcher.dart';

const String emptyCurrencyValue = '-';

String getPointCurrencyRateStringFormatted(
    ExchangePoint point, String property) {
  var numberFormatter = NumberFormat("####.00");
  num currencyValue = point.get(property);

  return currencyValue == 0
      ? emptyCurrencyValue
      : numberFormatter.format((currencyValue));
}

bool canRenderCurrencyRow(String buyValue, String sellValue) {
  return buyValue != emptyCurrencyValue || sellValue != emptyCurrencyValue;
}

String getUpdateTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}

void openUrl({required String url}) async {
  final uri = Uri.parse(url);
  var isEmail = url.startsWith('mailto:');

  try {
    await launchUrl(uri);
  } catch (e) {
    if (isEmail) {
      await Clipboard.setData(
          ClipboardData(text: url.substring("mailto:".length)));
    }
    throw 'Could not launch $uri';
  }
}
