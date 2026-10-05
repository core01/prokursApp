import 'package:flutter/cupertino.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/rates/domain/models/best_rates.dart';
import 'package:prokurs/features/rates/presentation/widgets/wholesale_info.dart';

class RatesTable extends StatefulWidget {
  final List<ExchangePoint> exchangeRates;
  final String selectedCurrency;
  final BestRates bestRetailRates;
  final BestRates bestGrossRates;
  final onPointClick;

  /// The list is sorted by the buy rate (highest first) or by the sell rate (lowest first).
  final bool sortedByBuy;

  const RatesTable({
    super.key,
    required this.exchangeRates,
    required this.selectedCurrency,
    required this.bestRetailRates,
    required this.bestGrossRates,
    required Function this.onPointClick,
    required this.sortedByBuy,
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

    // A number can't wrap: with large Dynamic Type it shrinks to its column instead of
    // overflowing it.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
      mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  /// A rate column's title; the column the list is sorted by shows the order with an arrow.
  Widget _columnTitle(String title, {required bool sorted, required bool descending}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(title, textAlign: TextAlign.center, style: AppTypography.subheadline),
        ),
        if (sorted) ...[
          const SizedBox(width: AppSpacing.xxs),
          Icon(
            descending ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
            size: AppTypography.subheadline.fontSize,
            applyTextScaling: true,
            semanticLabel: descending ? 'по убыванию' : 'по возрастанию',
          ),
        ],
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
        padding: const EdgeInsets.all(AppSpacing.md),
        color: AppColors.background.resolveFrom(context),
        child: SafeArea(
            bottom: false,
            top: false,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
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
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _columnTitle(
                            'Покупка',
                            sorted: widget.sortedByBuy,
                            descending: true,
                          ),
                        ),
                        Expanded(
                          child: _columnTitle(
                            'Продажа',
                            sorted: !widget.sortedByBuy,
                            descending: false,
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
            return CupertinoButton(
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.label.resolveFrom(context),
              onPressed: () {
                widget.onPointClick(exchangeRates[index]);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm, horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: AppStroke.hairline,
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
                                        margin: const EdgeInsets.only(right: AppSpacing.xs),
                                        child: Image.network(
                                          rate.logo!,
                                          width: AppIconSize.regular,
                                          height: AppIconSize.regular,
                                        ))
                                  ],
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: AppSpacing.xxs),
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
                                margin: const EdgeInsets.only(left: AppSpacing.xxs),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: getPointCurrencyRateContainer(
                                        rate,
                                        '$BUY_KEY$selectedCurrency',
                                      ),
                                    ),
                                    Expanded(
                                      child: getPointCurrencyRateContainer(
                                        rate,
                                        '$SELL_KEY$selectedCurrency',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
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
                          const Padding(
                            padding: EdgeInsets.only(top: AppSpacing.xs),
                            child: WholesaleBadge(),
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
