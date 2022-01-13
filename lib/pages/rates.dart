import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:prokurs/models/city_list.dart';
import 'package:prokurs/providers/exchange_points.dart';
import 'package:prokurs/widgets/rates_table.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/city.dart';

class RatesPage extends StatefulWidget {
  @override
  _RatesPageState createState() => _RatesPageState();

  static const routeName = '/ratesPage';
}

class _RatesPageState extends State<RatesPage> {
  final CupertinoTabController _currencyTabController = CupertinoTabController();

  bool _isInitializationNeeded = true;
  bool _isLoading = true;

  late City _selectedCity;

  void setActiveTab(int activeTabIndex) {
    context.read<ExchangePoints>().changeSelectedCurrency(currency: CURRENCY_LIST[_currencyTabController.index].id);
  }

  void _toggleSortDirection() {
    debugPrint('RatesPage -> _toggleSortDirection');
    context.read<ExchangePoints>().changeSortDirection();
  }

  Future<void> _onRatesRefresh() async {
    try {
      await context.read<ExchangePoints>().fetchAndSetExchangeRates(cityId: _selectedCity.id);
    } catch (err) {
      debugPrint('RatesPage -> _onRatesRefresh: catch error $err');
    }
  }

  @override
  void didChangeDependencies() async {
    if (_isInitializationNeeded) {
      final prefs = await SharedPreferences.getInstance();

      final cityId = prefs.getInt('cityId') ?? CityList.NUR_SULTAN.id;
      debugPrint('Rates -> didChangeDependencies() -> cityId $cityId');
      _selectedCity = CityList().findById(cityId);
      final selectedCurrency = context.read<ExchangePoints>().selectedCurrency;
      int tabIndex = CURRENCY_LIST.indexWhere((currency) => currency.id == selectedCurrency);
      if (tabIndex > -1) {
        _currencyTabController.index = tabIndex;
        debugPrint('Rates -> didChangeDependencies() -> tabIndex $tabIndex');
      }
      try {
        await context.read<ExchangePoints>().fetchAndSetExchangeRates(cityId: cityId);
      } catch (err) {
        debugPrint('Rates -> didChangeDependencies -> catch error in fetchAndSetExchangeRates: $err');
      }

      setState(() {
        _isLoading = false;
      });
      _isInitializationNeeded = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext widgetContext) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: CURRENCY_LIST.map((currency) {
          return BottomNavigationBarItem(
            icon: Icon(currency.icon),
            label: currency.label,
          );
        }).toList(),
        onTap: (newIndex) => setActiveTab(newIndex),
      ),
      controller: _currencyTabController,
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            final showBuy = context.watch<ExchangePoints>().showBuy;
            final exchangeRates = context.watch<ExchangePoints>().items;
            final bestRetailRates = context.watch<ExchangePoints>().bestRetailRates;
            final bestGrossRates = context.watch<ExchangePoints>().bestGrossRates;
            final ratesUpdateTime = context.watch<ExchangePoints>().ratesUpdateTime;
            final selectedCurrency = widgetContext.watch<ExchangePoints>().selectedCurrency;
            debugPrint('Home -> build -> tabBuilder: selectedCurrency=$selectedCurrency');
            debugPrint('Home -> build -> tabBuilder: exchangeRates.length=${exchangeRates.length}');
            debugPrint('Home -> build -> tabBuilder: showBuy=$showBuy');
            return _isLoading
                ? CupertinoActivityIndicator(
                    radius: 15,
                  )
                : CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.pop(widgetContext);
                        },
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                CupertinoIcons.left_chevron,
                                size: 18,
                              ),
                              Text(
                                'Назад',
                                style: TextStyle(
                                  color: CupertinoTheme.of(context).primaryColor,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      middle: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedCity.title,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            ' ${ratesUpdateTime != null ? 'Время обновления $ratesUpdateTime' : '—'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Container(
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              child: RatesTable(
                                emptyNoticeText:
                                    'К сожалению, на данный момент нет информации по актуальному курсу ${showBuy ? 'покупки' : 'продажи'} $selectedCurrency в городе ${_selectedCity.title}',
                                exchangeRates: exchangeRates,
                                onToggleSortDirection: _toggleSortDirection,
                                selectedCurrency: selectedCurrency,
                                bestGrossRates: bestGrossRates,
                                bestRetailRates: bestRetailRates,
                                onRefresh: _onRatesRefresh,
                                showBuy: showBuy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
          },
        );
      },
    );
  }
}
