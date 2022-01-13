import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:prokurs/constants.dart';
import 'package:prokurs/models/best_rates.dart';
import 'package:prokurs/models/exchange_point.dart';

class ExchangePoints with ChangeNotifier {
  List<ExchangePoint> _exchangeRates = [];

  String _currency = 'USD';
  bool _showBuy = true;
  DateTime? _updateTime;

  BestRates _bestRetailRates = BestRates();
  BestRates _bestGrossRates = BestRates();

  String get selectedCurrency => _currency;

  bool get showBuy => _showBuy;

  String get buyKey => '$BUY_KEY$_currency';

  String get sellKey => '$SELL_KEY$_currency';

  List<ExchangePoint> get items => _exchangeRates.where((el) {
        return el.get(buyKey) != 0 || el.get(sellKey) != 0;
      }).toList();

  BestRates get bestRetailRates => _bestRetailRates;

  BestRates get bestGrossRates => _bestGrossRates;

  String? get ratesUpdateTime {
    var f = new DateFormat('HH:mm');
    return _updateTime != null ? f.format(_updateTime!) : null;
  }

  void setShowBuy(bool value) {
    _showBuy = value;
    notifyListeners();
  }

  void sortExchangeRates() {
    _exchangeRates.sort((a, b) {
      var returningValue;
      var compareValue;
      var value;
      if (_showBuy) {
        value = b.get(buyKey);
        compareValue = a.get(buyKey);

        if (value == 0) {
          returningValue = -1;
        } else if (compareValue == 0) {
          returningValue = 1;
        } else {
          returningValue = value.compareTo(compareValue);
        }
      } else {
        value = a.get(sellKey);
        compareValue = b.get(sellKey);

        if (compareValue == 0) {
          returningValue = -1;
        } else if (value == 0) {
          returningValue = 1;
        } else {
          returningValue = value.compareTo(compareValue);
        }
      }
      debugPrint('exchangePoints -> sortExchangeRates NAME:${b.get('name')} vs ${a.get('name')}');
      debugPrint(
          'exchangePoints -> sortExchangeRates _showBuy:$_showBuy, value:$value, compareWith:$compareValue, returningValue: $returningValue');
      return returningValue;
    });

    debugPrint('ExchangeRates Provider -> sortExchangeRates - sorted $_currency');
  }

  void changeSelectedCurrency({String currency = ''}) {
    _currency = currency.isEmpty ? _currency : currency;
    debugPrint('ExchangeRates Provider -> changeSelectedCurrency _currency: $_currency');
    sortExchangeRates();

    notifyListeners();
  }

  void changeSortDirection() {
    _showBuy = !_showBuy;
    sortExchangeRates();
    notifyListeners();
  }

  Future<void> fetchAndSetExchangeRates({required int cityId}) async {
    final url = Uri.parse('https://api.cityinfo.kz/courses/$cityId');

    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    List<ExchangePoint> exchangeRates = [];
    extractedData['rates'].forEach((exchangeData) {
      exchangeRates.add(ExchangePoint.fromJson(exchangeData));
    });
    _bestRetailRates = BestRates.fromJson(extractedData['best']['retail']);
    _bestGrossRates = BestRates.fromJson(extractedData['best']['gross']);
    _exchangeRates = exchangeRates;
    _updateTime = DateTime.now();
    sortExchangeRates();

    notifyListeners();
  }
}
