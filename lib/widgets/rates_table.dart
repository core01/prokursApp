import 'package:flutter/cupertino.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/constants.dart';
import 'package:prokurs/models/best_rates.dart';
import 'package:prokurs/models/exchange_point.dart';
import 'package:prokurs/utils.dart';

class RatesTable extends StatefulWidget {
  final List<ExchangePoint> exchangeRates;
  final String selectedCurrency;
  final BestRates bestRetailRates;
  final BestRates bestGrossRates;
  final onPointClick;

  const RatesTable({
    super.key,
    required this.exchangeRates,
    required this.selectedCurrency,
    required this.bestRetailRates,
    required this.bestGrossRates,
    required Function this.onPointClick,
  });

  @override
  _RatesTable createState() => _RatesTable();
}

class _RatesTable extends State<RatesTable> {
  getPointCurrencyRateContainer(ExchangePoint rate, String property) {
    num currencyValue = rate.get(property);
    bool isBestGross =
        rate.gross > 0 && currencyValue == widget.bestGrossRates.get(property);
    bool isBestRetail = rate.gross == 0 &&
        currencyValue == widget.bestRetailRates.get(property);

    bool isBuy = property.contains(BUY_KEY);

    Color? color;
    // Color? bgColor;
    if (isBestGross || isBestRetail) {
      // var bestBgColors = [
      //   AppColors.generalGreenBg, // bestSellBG green
      //   AppColors.generalRedBg, // bestBuyBG red
      // ];

      var bestColors = [
        AppColors.generalGreen, // BestSell green
        AppColors.generalRed, // BestBuy red
      ];
      color = isBuy ? bestColors[0] : bestColors[1];
      // bgColor = isBuy ? bestBgColors[0] : bestBgColors[1];
    } else {
      color = CupertinoTheme.of(context).textTheme.textStyle.color;
      // bgColor = null;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          getPointCurrencyRateStringFormatted(rate, property),
          textAlign: TextAlign.center,
          style: Typography.body2.merge(
            TextStyle(
              color: color,
            ),
          ),
        ),
        if (currencyValue != 0) ...[
          // Tenge sign
          Text(
            '\u{20B8}',
            textAlign: TextAlign.center,
            style: Typography.body3.merge(
              TextStyle(
                color: color,
              ),
            ),
          ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ExchangePoint> exchangeRates = widget.exchangeRates;
    final String selectedCurrency = widget.selectedCurrency;
    List<Widget> items = [];

    items = <Widget>[
      Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.darkTheme.lightBg,
        child: SafeArea(
          bottom: false,
          top: false,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  alignment: Alignment.centerLeft,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      'Обменный пункт',
                      style: Typography.body3.merge(TextStyle(
                        color: AppColors.darkTheme.generalBlack,
                      )),
                    ),
                    onPressed: () async {},
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Покупка',
                          style: Typography.body3.merge(TextStyle(
                            color: AppColors.darkTheme.generalBlack,
                          )),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Продажа',
                          style: Typography.body3.merge(TextStyle(
                            color: AppColors.darkTheme.generalBlack,
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ...exchangeRates.map((rate) {
        return GestureDetector(
          onTap: () {
            widget.onPointClick(rate);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: AppColors.darkTheme.lightDivider,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          rate.name,
                          style: Typography.body2,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            getPointCurrencyRateContainer(
                              rate,
                              '$BUY_KEY$selectedCurrency',
                            ),
                            getPointCurrencyRateContainer(
                              rate,
                              '$SELL_KEY$selectedCurrency',
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        'Обновлено в ',
                        style: Typography.body3.merge(TextStyle(
                          color: AppColors.darkTheme.lightSecondary,
                        )),
                      ),
                      Text(
                        DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            rate.date_update * 1000 as int,
                          ),
                        ),
                        style: Typography.body3.merge(TextStyle(
                          color: AppColors.darkTheme.lightSecondary,
                        )),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    rate.info ?? '-',
                    textAlign: TextAlign.left,
                    style: Typography.body3.merge(TextStyle(
                      color: AppColors.darkTheme.lightSecondary,
                    )),
                  ),
                ),
                if (rate.gross > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Оптовый курс',
                      style: Typography.body3.merge(const TextStyle(
                        color: CupertinoColors.systemOrange,
                      )),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    ];

    return SliverStickyHeader(
      header: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.darkTheme.lightBg,
        child: SafeArea(
            bottom: false,
            top: false,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Обменный пункт',
                      style: Typography.body3.merge(TextStyle(
                        color: AppColors.darkTheme.generalBlack,
                      )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Покупка',
                            textAlign: TextAlign.center,
                            style: Typography.body3.merge(TextStyle(
                              color: AppColors.darkTheme.generalBlack,
                            )),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Продажа',
                            textAlign: TextAlign.center,
                            style: Typography.body3.merge(TextStyle(
                              color: AppColors.darkTheme.generalBlack,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            var rate = exchangeRates[index];
            return GestureDetector(
              onTap: () {
                widget.onPointClick(exchangeRates[index]);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border(
                    top: BorderSide(
                      width: 1,
                      color: AppColors.darkTheme.lightDivider,
                    ),
                  ),
                ),
                child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  rate.name,
                                  style: Typography.body2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: const EdgeInsets.only(left: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          getPointCurrencyRateContainer(
                                            rate,
                                            '$BUY_KEY$selectedCurrency',
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          getPointCurrencyRateContainer(
                                            rate,
                                            '$SELL_KEY$selectedCurrency',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                'Обновлено в ',
                                style: Typography.body3.merge(TextStyle(
                                  color: AppColors.darkTheme.lightSecondary,
                                )),
                              ),
                              Text(
                                DateFormat('HH:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    rate.date_update * 1000 as int,
                                  ),
                                ),
                                style: Typography.body3.merge(TextStyle(
                                  color: AppColors.darkTheme.lightSecondary,
                                )),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          rate.info ?? '-',
                          textAlign: TextAlign.left,
                          style: Typography.body3.merge(TextStyle(
                            color: AppColors.darkTheme.lightSecondary,
                          )),
                        ),
                        if (rate.gross > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Оптовый курс',
                              style: Typography.body3.merge(const TextStyle(
                                color: CupertinoColors.systemOrange,
                              )),
                            ),
                          ),
                      ],
                    )),
              ),
            );
          },
          childCount: exchangeRates.length, // Количество элементов списка
        ),
      ),
    );
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => items[index],
        childCount: items.length,
      ),
    );
    // return Container(
    //     child: Column(
    //   children: [...items],
    // ));
  }
}
