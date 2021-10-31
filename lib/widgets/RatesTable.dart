import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/models/bestRates.dart';
import 'package:prokurs/models/exchangeRate.dart';

class RatesTable extends StatefulWidget {
  final List<ExchangeRate> exchangeRates;
  final String selectedCurrency;
  final onToggleSortDirection;
  final BestRates bestRetailRates;
  final BestRates bestGrossRates;
  final onRefresh;

  const RatesTable({
    Key? key,
    required this.exchangeRates,
    required this.selectedCurrency,
    required Function this.onToggleSortDirection,
    required this.bestRetailRates,
    required this.bestGrossRates,
    required Function this.onRefresh,
  }) : super(key: key);

  @override
  _RatesTable createState() => _RatesTable();
}

class _RatesTable extends State<RatesTable> {
  int ratesTabValue = 0;
  final Map<int, Widget> ratesTabs = const <int, Widget>{
    0: Text("Покупка"),
    1: Text("Продажа")
  };

  void _onToggleSortDirection() {
    widget.onToggleSortDirection();
  }

  Future<void> _onRefresh() async {
    widget.onRefresh();
  }

  String getRateCurrencyStringValue(ExchangeRate rate, String property) {
    var numberFormatter = NumberFormat("###.00");
    num currencyValue = rate.get(property);

    print(
        'Home -> getRateCurrencyStringValue property $property currencyValue $currencyValue');
    return currencyValue == 0 ? '-' : numberFormatter.format((currencyValue));
  }

// синий покупка  /  красный продажа
  TextStyle getRateCurrencyTextStyle(ExchangeRate rate, String property) {
    num currencyValue = rate.get(property);
    bool isBestGross =
        rate.gross > 0 && currencyValue == widget.bestGrossRates.get(property);
    bool isBestRetail = rate.gross == 0 &&
        currencyValue == widget.bestRetailRates.get(property);
    print(
        'getRateCurrencyColor best retail ${widget.bestRetailRates.get(property)}');
    print(
        'getRateCurrencyColor best gross ${widget.bestGrossRates.get(property)}');
    print('getRateCurrencyColor currencyValue $currencyValue');

    bool isBuy = property.contains('buy');
    var color;
    var fontWeight = FontWeight.normal;
    if (isBestGross || isBestRetail) {
      color = isBuy ? Color(0xff800000) : Color(0xff0c14b2);
      fontWeight = FontWeight.bold;
    } else {
      print('getRateCurrencyColor is not best rate');
      color = CupertinoColors.black;
    }

    return new TextStyle(
      color: color,
      fontWeight: fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    var exchangeRates = widget.exchangeRates;
    var selectedCurrency = widget.selectedCurrency;

    var items = <Widget>[
      Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Обменный пункт',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: 160,
              alignment: Alignment.center,
              child: CupertinoSlidingSegmentedControl(
                  groupValue: ratesTabValue,
                  children: ratesTabs,
                  onValueChanged: (i) {
                    setState(() {
                      ratesTabValue = (i as int);
                    });
                    _onToggleSortDirection();
                  }),
            ),
          ],
        ),
      ),
      ...exchangeRates.map((rate) {
        print('RatesTable -> build -> inside map -> ${rate.name}');
        print('RatesTable -> build -> inside map ->  ${exchangeRates.length}');

        return Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(right: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rate.name,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (rate.gross > 0)
                            Text(
                              'Оптовый курс',
                              style: TextStyle(
                                color: CupertinoColors.systemPink,
                                fontSize: 13,
                              ),
                            ),
                          Text(
                            '${rate.info != null ? rate.info : '-'}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                    ),
                  ),
                  Container(
                    width: 75,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          width: 0.5,
                          color: Color(0xFFAFAFAF),
                        ),
                      ),
                    ),
                    child: Text(
                      getRateCurrencyStringValue(
                        rate,
                        'buy$selectedCurrency',
                      ),
                      style: getRateCurrencyTextStyle(
                        rate,
                        'buy$selectedCurrency',
                      ),
                    ),
                  ),
                  Container(
                    width: 75,
                    alignment: Alignment.center,
                    child: Text(
                      getRateCurrencyStringValue(
                        rate,
                        'sell$selectedCurrency',
                      ),
                      style: getRateCurrencyTextStyle(
                        rate,
                        'sell$selectedCurrency',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    ];

    return Container(
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: <Widget>[
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    print('TESTER');
                    await _onRefresh();
                  },
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) => items[index],
                    childCount: items.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
