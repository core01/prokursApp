import 'package:flutter/cupertino.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/exchange_point/domain/models/exchange_point.dart';
import 'package:prokurs/features/rates/domain/models/best_rates.dart';

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

    return SliverStickyHeader(
      header: Container(
        padding: const EdgeInsets.all(16),
        color: DarkTheme.lightBg,
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
                      style: Typography.body3.merge(const TextStyle(
                        color: DarkTheme.generalBlack,
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
                            style: Typography.body3.merge(const TextStyle(
                              color: DarkTheme.generalBlack,
                            )),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Продажа',
                            textAlign: TextAlign.center,
                            style: Typography.body3.merge(const TextStyle(
                              color: DarkTheme.generalBlack,
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
                decoration: const BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border(
                    top: BorderSide(
                      width: 1,
                      color: DarkTheme.lightDivider,
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
                              child: Row(
                                children: [
                                  if (rate.hasLogo) ...[
                                    Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: Image.network(
                                          rate.logo!,
                                          width: 24,
                                          height: 24,
                                        ))
                                  ],
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        rate.name,
                                        style: Typography.body2,
                                      ),
                                    ),
                                  ),
                                ],
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
                                style: Typography.body3.merge(const TextStyle(
                                  color: DarkTheme.lightSecondary,
                                )),
                              ),
                              Text(
                                DateFormat('HH:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    rate.date_update * 1000 as int,
                                  ),
                                ),
                                style: Typography.body3.merge(const TextStyle(
                                  color: DarkTheme.lightSecondary,
                                )),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          rate.info ?? '-',
                          textAlign: TextAlign.left,
                          style: Typography.body3.merge(const TextStyle(
                            color: DarkTheme.lightSecondary,
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
  }
}
