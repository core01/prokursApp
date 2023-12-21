import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:prokurs/constants.dart';
import 'package:prokurs/models/best_rates.dart';
import 'package:prokurs/models/exchange_point.dart';

import '../utils.dart';

class ExchangePoints with ChangeNotifier {
  List<ExchangePoint> _exchangeRates = [];

  String _currency = 'USD';
  bool _showBuy = true;
  DateTime _updateTime = DateTime.now();

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

  String get ratesUpdateTime {
    return getUpdateTime(_updateTime);
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
      return returningValue;
    });

    debugPrint(
        'ExchangeRates Provider -> sortExchangeRates - sorted $_currency');
  }

  void changeSelectedCurrency({String currency = ''}) {
    _currency = currency.isEmpty ? _currency : currency;
    debugPrint(
        'ExchangeRates Provider -> changeSelectedCurrency _currency: $_currency');
    sortExchangeRates();

    notifyListeners();
  }

  void changeSortDirection() {
    sortExchangeRates();
    notifyListeners();
  }

  void sortByBestBuy() {
    if (!_showBuy) {
      _showBuy = true;
      changeSortDirection();
    }
  }

  void sortByBestSell() {
    if (_showBuy) {
      _showBuy = false;
      changeSortDirection();
    }
  }

  Future<void> fetchAndSetExchangeRates({required int cityId}) async {
    final url = Uri.parse('https://api.cityinfo.kz/courses/$cityId');
    // final url = Uri.parse('http://192.168.1.36:3000/courses/$cityId');
    // debugPrint(
    //     '1111 -> requesting ${Uri.parse('http://192.168.1.36:3000/courses/$cityId')}');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      debugPrint('1111 -> received ${extractedData['rates'].length}');
      List<ExchangePoint> exchangeRates = [];
      extractedData['rates'].forEach((exchangeData) {
        exchangeRates.add(ExchangePoint.fromJson(exchangeData));
      });
      _bestRetailRates = BestRates.fromJson(extractedData['best']['retail']);
      _bestGrossRates = BestRates.fromJson(extractedData['best']['gross']);
      _exchangeRates = exchangeRates;

      notifyListeners();
    } catch (err) {
      debugPrint("ASDASD $err");
    }

    _updateTime = DateTime.now();
    sortExchangeRates();
    // debugPrint(response.toString());
  }
}
