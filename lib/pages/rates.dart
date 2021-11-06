import 'dart:core';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:prokurs/models/cityList.dart';
import 'package:prokurs/providers/exchangePoints.dart';
import 'package:prokurs/widgets/RatesTable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city.dart';

import '../constants.dart';

class RatesPage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

  static const routeName = '/ratesPage';
}

class _HomePageState extends State<RatesPage> {
  int _activeTabIndex = 0;

  var buttonContainerVisible = true;

  bool _isInit = true;
  bool _isLoading = true;
  late City _selectedCity;

  void setActiveTab(int activeTabIndex) {
    setState(() {
      this._activeTabIndex = activeTabIndex;
    });
    context
        .read<ExchangePoints>()
        .changeSelectedCurrency(currency: CURRENCY_LIST[_activeTabIndex]['id']);
  }

  void _toggleSortDirection() {
    debugPrint('RatesPage -> _toggleSortDirection');
    context.read<ExchangePoints>().changeSortDirection();
  }

  Future<void> _onRatesRefresh() {
    return context
        .read<ExchangePoints>()
        .fetchAndSetExchangeRates(cityId: _selectedCity.id);
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final prefs = await SharedPreferences.getInstance();

      final cityId = prefs.getInt('cityId') ?? CityList.NUR_SULTAN.id;
      debugPrint('Rates -> didChangeDependencies() -> cityId $cityId');
      _selectedCity = CityList().findById(cityId);
      await context
          .read<ExchangePoints>()
          .fetchAndSetExchangeRates(cityId: cityId);

      setState(() {
        _isLoading = false;
      });
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext widgetContext) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: CURRENCY_LIST.map((currency) {
          return BottomNavigationBarItem(
            icon: Icon(currency['icon']),
            label: currency['label'],
          );
        }).toList(),
        currentIndex: _activeTabIndex,
        onTap: (newIndex) => setActiveTab(newIndex),
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            final showBuy = context.watch<ExchangePoints>().showBuy;
            final exchangeRates = context.watch<ExchangePoints>().items;
            final bestRetailRates =
                context.watch<ExchangePoints>().bestRetailRates;
            final bestGrossRates =
                context.watch<ExchangePoints>().bestGrossRates;
            final selectedCurrency =
                context.watch<ExchangePoints>().selectedCurrency;
            final ratesUpdateTime =
                context.watch<ExchangePoints>().ratesUpdateTime;
            final exchangeRatesLength = exchangeRates.length;
            debugPrint(
                'Home -> build -> tabBuilder: selectedCurrency=$selectedCurrency');
            debugPrint(
                'Home -> build -> tabBuilder: exchangeRates.lenth=${exchangeRates.length}');
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
                          child: Icon(CupertinoIcons.left_chevron),
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
                            'Время обновления $ratesUpdateTime',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        constraints: BoxConstraints.expand(),
                        child: Stack(
                          children: [
                            Container(
                              child: exchangeRatesLength < 1
                                  ? Center(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                            'К сожалению, на данный момент нет информации по ${showBuy ? 'покупке' : 'продаже'} ${CURRENCY_LIST[_activeTabIndex]['unicode']} в городе ${_selectedCity.title}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    )
                                  : RatesTable(
                                      exchangeRates: exchangeRates,
                                      onToggleSortDirection:
                                          _toggleSortDirection,
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
