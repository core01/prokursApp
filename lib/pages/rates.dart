import 'dart:core';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  void _toggleRatesType() {
    context.read<ExchangeRates>().changeRatesType();
  }

  void _toggleSortDirection() {
    context.read<ExchangeRates>().changeSortDirection();
  }

  void _scrollListener(scrollDirection) {
    print('SCROLLING');
    if (scrollDirection == ScrollDirection.reverse) {
      if (buttonContainerVisible)
        setState(() {
          buttonContainerVisible = !buttonContainerVisible;
        });
    }
    if (scrollDirection == ScrollDirection.forward) {
      if (buttonContainerVisible == false)
        setState(() {
          buttonContainerVisible = true;
        });
    }
  }

  @override
  void initState() {
    print('INIT');
    super.initState();
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
            final isGross = context.watch<ExchangeRates>().isGross;
            final exchangeRates = Provider.of<ExchangeRates>(context).items;
            final selectedCurrency =
                Provider.of<ExchangeRates>(context).selectedCurrency;
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
                      middle: Text(args.city.title),
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
                                            'К сожалению, на данный момент нет информации по ${isGross ? 'оптовой' : 'розничной'} ${showBuy ? 'покупке' : 'продаже'} ${currencies[_activeTabIndex]['unicode']} в городе ${args.city.title}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    )
                                  : RatesTable(
                                      exchangeRates: exchangeRates,
                                      onScroll: _scrollListener,
                                      onToggleSortDirection:
                                          _toggleSortDirection,
                                      selectedCurrency: selectedCurrency,
                                    ),
                            ),
                            Positioned(
                              bottom: 50,
                              left: 10.0,
                              right: 10.0,
                              child: Visibility(
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: ElevatedButton(
                                          onPressed: () => _toggleRatesType(),
                                          child:
                                              Text(isGross ? 'Опт' : 'Розница'),
                                        ),
                                        width: 100,
                                      ),
                                      Container(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _toggleSortDirection(),
                                          child: Text(
                                              'Сортировка: ${showBuy ? 'Покупка' : 'Продажа'}'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                visible: buttonContainerVisible,
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
