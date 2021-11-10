import 'dart:core';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/cupertino.dart';
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
  _RatesPageState createState() => _RatesPageState();

  static const routeName = '/ratesPage';
}

class _RatesPageState extends State<RatesPage> {
  int _activeTabIndex = 0;

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

  Future<void> _onRatesRefresh() async {
    try {
      await context
          .read<ExchangePoints>()
          .fetchAndSetExchangeRates(cityId: _selectedCity.id);
    } catch (err) {
      debugPrint('RatesPage -> _onRatesRefresh: catch error $err');
    }
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final prefs = await SharedPreferences.getInstance();

      final cityId = prefs.getInt('cityId') ?? CityList.NUR_SULTAN.id;
      debugPrint('Rates -> didChangeDependencies() -> cityId $cityId');
      _selectedCity = CityList().findById(cityId);
      try {
        await context
            .read<ExchangePoints>()
            .fetchAndSetExchangeRates(cityId: cityId);
      } catch (err) {
        debugPrint(
            'Rates -> didChangeDependencies -> catch error in fetchAndSetExchangeRates: $err');
      }

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
                                  color: CupertinoColors.activeBlue,
                                  fontSize: 16,
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
                              fontSize: 12,
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
                                    'К сожалению, на данный момент нет информации по актуальному курсу ${showBuy ? 'покупки' : 'продажи'} ${CURRENCY_LIST[_activeTabIndex]['unicode']} в городе ${_selectedCity.title}',
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
