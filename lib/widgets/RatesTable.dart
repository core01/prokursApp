import 'package:flutter/cupertino.dart';

import 'package:intl/intl.dart';
import 'package:prokurs/models/arguments/pointScreenArguments.dart';
import 'package:prokurs/models/bestRates.dart';
import 'package:prokurs/models/exchangePoint.dart';
import 'package:prokurs/pages/point.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RatesTable extends StatefulWidget {
  final List<ExchangePoint> exchangeRates;
  final String selectedCurrency;
  final onToggleSortDirection;
  final BestRates bestRetailRates;
  final BestRates bestGrossRates;
  final onRefresh;
  final bool showBuy;
  final String emptyNoticeText;

  const RatesTable({
    Key? key,
    required this.exchangeRates,
    required this.selectedCurrency,
    required Function this.onToggleSortDirection,
    required this.bestRetailRates,
    required this.bestGrossRates,
    required Function this.onRefresh,
    required this.showBuy,
    required this.emptyNoticeText,
  }) : super(key: key);

  @override
  _RatesTable createState() => _RatesTable();
}

class _RatesTable extends State<RatesTable> {
  void _onToggleSortDirection() {
    debugPrint('RatesTable -> _onToggleSortDirection');
    widget.onToggleSortDirection();
  }

  Future<void> _onRefresh() async {
    await widget.onRefresh();
  }

  String getRateCurrencyStringValue(ExchangePoint rate, String property) {
    var numberFormatter = NumberFormat("###.00");
    num currencyValue = rate.get(property);

    debugPrint(
        'Home -> getRateCurrencyStringValue property $property currencyValue $currencyValue');
    return currencyValue == 0 ? '-' : numberFormatter.format((currencyValue));
  }

// синий покупка  /  красный продажа
  TextStyle getRateCurrencyTextStyle(ExchangePoint rate, String property) {
    num currencyValue = rate.get(property);
    bool isBestGross =
        rate.gross > 0 && currencyValue == widget.bestGrossRates.get(property);
    bool isBestRetail = rate.gross == 0 &&
        currencyValue == widget.bestRetailRates.get(property);
    debugPrint(
        'getRateCurrencyTextStyle best retail ${widget.bestRetailRates.get(property)}');
    debugPrint(
        'getRateCurrencyTextStyle best gross ${widget.bestGrossRates.get(property)}');
    debugPrint('getRateCurrencyTextStyle currencyValue $currencyValue');

    bool isBuy = property.contains('buy');
    var color;
    var fontWeight = FontWeight.normal;
    if (isBestGross || isBestRetail) {
      color = isBuy ? Color(0xff800000) : Color(0xff0c14b2);
      fontWeight = FontWeight.bold;
    } else {
      color = CupertinoColors.black;
    }

    return new TextStyle(
      color: color,
      fontWeight: fontWeight,
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final Map<int, Widget> ratesTabs = <int, Widget>{
      0: Text("Покупка", style: TextStyle(fontSize: 16 / textScaleFactor)),
      1: Text("Продажа", style: TextStyle(fontSize: 16 / textScaleFactor)),
    };

    final List<ExchangePoint> exchangeRates = widget.exchangeRates;
    final String selectedCurrency = widget.selectedCurrency;
    final bool showBuy = widget.showBuy;
    final String emptyNoticeText = widget.emptyNoticeText;
    List<Widget> items = [];

    if (exchangeRates.length < 1) {
      items = <Widget>[
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Text(
            emptyNoticeText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16 / textScaleFactor),
          ),
        ),
      ];
    } else {
      items = <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Обменный пункт',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18 / textScaleFactor,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: CupertinoSlidingSegmentedControl(
                    groupValue: showBuy ? 0 : 1,
                    children: ratesTabs,
                    onValueChanged: (i) {
                      _onToggleSortDirection();
                    }),
              ),
            ],
          ),
        ),
        ...exchangeRates.map((rate) {
          return GestureDetector(
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => PointPage(),
                expand: true,
                settings: RouteSettings(
                  arguments: PointScreenArguments(rate),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 2,
                    color: CupertinoColors.systemGrey6,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      rate.name,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    margin: EdgeInsets.only(bottom: 5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (rate.gross > 0)
                                Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    'Оптовый курс',
                                    style: TextStyle(
                                      color: CupertinoColors.systemOrange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              Container(
                                margin: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  '${rate.info != null ? rate.info : '-'}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
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
                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        Text(
                          'Обновлено в ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              rate.date_update * 1000 as int,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ];
    }

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
