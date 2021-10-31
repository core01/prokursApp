import 'dart:core';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:prokurs/models/arguments/ratesScreenArguments.dart';
import 'package:prokurs/providers/exchangeRates.dart';
import 'package:prokurs/widgets/RatesTable.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class RatesPage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

  static const routeName = '/ratesPage';
}

class _HomePageState extends State<RatesPage> {
  int _activeTabIndex = 1;

  var buttonContainerVisible = true;

  bool _isInit = true;
  bool _isLoading = true;

  void setActiveTab(int activeTabIndex) {
    setState(() {
      this._activeTabIndex = activeTabIndex;
    });

    Provider.of<ExchangeRates>(context, listen: false)
        .changeSelectedCurrency(currency: currencies[_activeTabIndex]['id']);
  }

  void _toggleSortDirection() {
    context.read<ExchangeRates>().changeSortDirection();
  }

  Future<void> _onRatesRefresh() {
    print('_onRatesRefresh');
    final args =
        ModalRoute.of(context)!.settings.arguments as RatesScreenArguments;
    return context
        .read<ExchangeRates>()
        .fetchAndSetExchangeRates(cityId: args.city.id);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final args =
          ModalRoute.of(context)!.settings.arguments as RatesScreenArguments;

      Provider.of<ExchangeRates>(context)
          .fetchAndSetExchangeRates(cityId: args.city.id)
          .then((_) {
        setState(() {
          _isLoading = false;
        });
        _isInit = false;
      });
    }

    super.didChangeDependencies();
  }

  final List<Map<String, dynamic>> currencies = const [
    {
      'id': Currency.USD,
      'label': 'USD',
      'icon': CupertinoIcons.money_dollar_circle_fill,
      'unicode': '\u{0024}'
    },
    {
      'id': Currency.EUR,
      'label': 'EUR',
      'icon': CupertinoIcons.money_euro_circle_fill,
      'unicode': '\u{20AC}'
    },
    {
      'id': Currency.RUR,
      'label': 'RUR',
      'icon': CupertinoIcons.money_rubl_circle_fill,
      'unicode': '\u{20BD}'
    },
    {
      'id': Currency.CNY,
      'label': 'CNY',
      'icon': CupertinoIcons.money_yen_circle_fill,
      'unicode': '\u{00A5}',
    },
    {
      'id': Currency.GBP,
      'label': 'GBP',
      'icon': CupertinoIcons.money_pound_circle_fill,
      'unicode': '\u{00A3}'
    },
  ];

  @override
  Widget build(BuildContext widgetContext) {
    final args =
        ModalRoute.of(context)!.settings.arguments as RatesScreenArguments;

    print('Home -> build fired _ $_isLoading');
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: currencies.map((currency) {
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
            final showBuy = context.watch<ExchangeRates>().showBuy;
            final exchangeRates = Provider.of<ExchangeRates>(context).items;
            final bestRetailRates =
                Provider.of<ExchangeRates>(context).bestRetailRates;
            final bestGrossRates =
                Provider.of<ExchangeRates>(context).bestGrossRates;
            final selectedCurrency =
                Provider.of<ExchangeRates>(context).selectedCurrency;
            final ratesUpdateTime =
                Provider.of<ExchangeRates>(context).ratesUpdateTime;
            final exchangeRatesLength = exchangeRates.length;
            print('Home -> build -> inside builder -> $selectedCurrency');
            print(
                'Home -> build -> inside builder exchangeRates lenth-> ${exchangeRates.length}');
            return _isLoading
                ? CupertinoActivityIndicator(
                    radius: 15,
                  )
                : CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                      leading: GestureDetector(
                        onTap: () {
                          debugPrint('Back button tapped');
                          Navigator.pop(widgetContext);
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(CupertinoIcons.left_chevron),
                            Text(
                              'Назад',
                              style: TextStyle(
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      middle: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(args.city.title),
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
                                            'К сожалению, на данный момент нет информации по ${showBuy ? 'покупке' : 'продаже'} ${currencies[_activeTabIndex]['unicode']} в городе ${args.city.title}',
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
