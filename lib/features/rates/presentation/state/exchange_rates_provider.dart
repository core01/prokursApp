import 'package:flutter/foundation.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/network/api_client.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/rates/domain/models/best_rates.dart';

class ExchangeRatesProvider with ChangeNotifier {
  List<ExchangePoint> _exchangeRates = [];
  int? _cityId;

  String _currency = 'USD';
  bool _showBuy = true;
  DateTime _updateTime = DateTime.now();

  BestRates _bestRetailRates = BestRates();
  BestRates _bestGrossRates = BestRates();

  String get selectedCurrency => _currency;

  bool get showBuy => _showBuy;

  String get buyKey => '$buyPrefix$_currency';

  String get sellKey => '$sellPrefix$_currency';

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

  /// Loads the rates of the city shown again: after an owner changed a point in the cabinet.
  Future<void> refresh() async {
    if (_cityId != null) await fetchAndSetExchangeRates(cityId: _cityId!);
  }

  Future<void> fetchAndSetExchangeRates({required int cityId}) async {
    _cityId = cityId;
    try {
      final response = await ApiClient.instance.api.cities
          .citiesControllerGetPointsV2(id: cityId);
      _exchangeRates = response.rates.map(ExchangePoint.fromRate).toList();
      _bestRetailRates = BestRates.fromDto(response.best.retail);
      _bestGrossRates = BestRates.fromDto(response.best.gross);

      notifyListeners();
    } catch (err) {
      debugPrint("Error during rates fetch $err");
    }

    _updateTime = DateTime.now();
    sortExchangeRates();
  }
}
