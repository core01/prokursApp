import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:prokurs/models/bestRates.dart';
import 'dart:convert';

import 'package:prokurs/models/exchangeRate.dart';

class ExchangeRates with ChangeNotifier {
  List<ExchangeRate> _exchangeRates = [];

  String _currency = 'USD';
  bool _showBuy = true;
  DateTime? _updateTime;

  BestRates _bestRetailRates = BestRates();
  BestRates _bestGrossRates = BestRates();

  String get selectedCurrency => _currency;
  bool get showBuy => _showBuy;

  List<ExchangeRate> get items => _exchangeRates.where((el) {
        return el.get('buy$_currency') != 0 && el.get('sell$_currency') != 0;
      }).toList();

  BestRates get bestRetailRates => _bestRetailRates;
  BestRates get bestGrossRates => _bestGrossRates;

  String? get ratesUpdateTime {
    var f = new DateFormat('HH:mm');
    return _updateTime != null ? f.format(_updateTime!) : null;
  }

  void sortExchangeRates() {
    final String buyKey = 'buy$_currency';
    final String sellKey = 'sell$_currency';

    _exchangeRates.sort((a, b) => _showBuy
        ? b.get(buyKey).compareTo(a.get(buyKey))
        : a.get(sellKey).compareTo(b.get(sellKey)));

    print('ExchangeRates Provider -> sortExchangeRates - sorted $_currency');
  }

  void changeSelectedCurrency({String currency = ''}) {
    _currency = currency.isEmpty ? _currency : currency;
    print('ExchangeRates Provider -> _currency $_currency');
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

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print('receive rates ${extractedData['rates'].length}');
      List<ExchangeRate> exchangeRates = [];
      extractedData['rates'].forEach((exchangeData) {
        exchangeRates.add(ExchangeRate.fromJson(exchangeData));
      });
      _bestRetailRates = BestRates.fromJson(extractedData['best']['retail']);
      _bestGrossRates = BestRates.fromJson(extractedData['best']['gross']);
      _exchangeRates = exchangeRates;
      _updateTime = DateTime.now();
      sortExchangeRates();

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
