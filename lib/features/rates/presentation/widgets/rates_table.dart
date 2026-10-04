import 'package:flutter/cupertino.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
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

    // The best rate is bold as well as colored: color alone doesn't reach everyone (Apple HIG).
    final style = isBestGross || isBestRetail
        ? AppTypography.body.copyWith(
            color: (isBuy ? AppColors.buy : AppColors.sell).resolveFrom(context),
            fontWeight: FontWeight.w700,
          )
        : AppTypography.body;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          getPointCurrencyRateStringFormatted(rate, property),
          textAlign: TextAlign.center,
          style: style,
        ),
        if (currencyValue != 0) ...[
          // Tenge sign
          Text(
            '\u{20B8}',
            textAlign: TextAlign.center,
            style: style,
          ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ExchangePoint> exchangeRates = widget.exchangeRates;
    final String selectedCurrency = widget.selectedCurrency;
    final secondaryLabel = AppColors.secondaryLabel.resolveFrom(context);
    
    return SliverStickyHeader(
      header: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.background.resolveFrom(context),
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
                      style: AppTypography.subheadline,
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
                            style: AppTypography.subheadline,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Продажа',
                            textAlign: TextAlign.center,
                            style: AppTypography.subheadline,
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
                  border: Border(
                    top: BorderSide(
                      width: 1,
                      color: AppColors.separator.resolveFrom(context),
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
                                        style: AppTypography.body,
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
                                style: AppTypography.subheadline.copyWith(color: secondaryLabel),
                              ),
                              Text(
                                DateFormat('HH:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    rate.date_update * 1000 as int,
                                  ),
                                ),
                                style: AppTypography.subheadline.copyWith(color: secondaryLabel),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          rate.info ?? '-',
                          textAlign: TextAlign.left,
                          style: AppTypography.subheadline.copyWith(color: secondaryLabel),
                        ),
                        if (rate.gross > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Оптовый курс',
                              style: AppTypography.subheadline.copyWith(
                                color: AppColors.warning.resolveFrom(context),
                              ),
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
