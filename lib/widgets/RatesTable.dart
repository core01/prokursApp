import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/models/exchangeRate.dart';

class RatesTable extends StatefulWidget {
  final List<ExchangeRate> exchangeRates;
  final String selectedCurrency;
  final onScroll;
  final onToggleSortDirection;

  const RatesTable({
    Key? key,
    required this.exchangeRates,
    required Function this.onScroll,
    required this.selectedCurrency,
    required Function this.onToggleSortDirection,
  }) : super(key: key);

  @override
  _RatesTable createState() => _RatesTable();
}

class _RatesTable extends State<RatesTable> {
  final ScrollController _scrollController = ScrollController();
  int ratesTabValue = 0;
  final Map<int, Widget> ratesTabs = const <int, Widget>{
    0: Text("Покупка"),
    1: Text("Продажа")
  };

  void _scrollListener() {
    widget.onScroll(_scrollController.position.userScrollDirection);
  }

  void _onToggleSortDirection() {
    widget.onToggleSortDirection();
  }

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  String getRateCurrencyStringValue(ExchangeRate rate, String property) {
    var numberFormatter = NumberFormat("###.00");
    num currencyValue = rate.get(property);

    print(
        'Home -> getRateCurrencyStringValue property $property currencyValue $currencyValue');
    return currencyValue == 0 ? '-' : numberFormatter.format((currencyValue));
  }

  @override
  Widget build(BuildContext context) {
    var exchangeRates = widget.exchangeRates;
    var selectedCurrency = widget.selectedCurrency;

    return Container(
      child: Column(
        children: [
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
          Expanded(
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 8),
              children: <Widget>[
                ...exchangeRates.map((rate) {
                  print('RatesTable -> build -> inside map -> ${rate.name}');
                  print(
                      'RatesTable -> build -> inside map ->  ${exchangeRates.length}');

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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      rate.name,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                                    rate, 'buy$selectedCurrency'),
                              ),
                            ),
                            Container(
                              width: 75,
                              alignment: Alignment.center,
                              child: Text(
                                getRateCurrencyStringValue(
                                    rate, 'sell$selectedCurrency'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(5),
                    //     border: Border.all(
                    //       color: CupertinoColors.tertiarySystemGroupedBackground,
                    //       width: 2,
                    //     )),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
