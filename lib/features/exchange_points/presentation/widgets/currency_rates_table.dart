import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';

class CurrencyRatesTable extends StatelessWidget {
  const CurrencyRatesTable({
    super.key,
    required this.point,
    required this.formatDateTime,
  });

  final ExchangePoint point;
  final String Function(num timestamp) formatDateTime;

  @override
  Widget build(BuildContext context) {
    final secondaryLabel = AppColors.secondaryLabel.resolveFrom(context);
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Валюта',
                    style: AppTypography.subheadline.copyWith(
                      fontWeight: FontWeight.w600,
                      color: secondaryLabel,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Покупка / Продажа',
                    style: AppTypography.subheadline.copyWith(
                      fontWeight: FontWeight.w600,
                      color: secondaryLabel,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const CurrencyRowDivider(),
          CurrencyRateRow(
            currency: 'USD',
            buy: point.buyUSD,
            sell: point.sellUSD,
          ),
          const CurrencyRowDivider(),
          CurrencyRateRow(
            currency: 'EUR',
            buy: point.buyEUR,
            sell: point.sellEUR,
          ),
          const CurrencyRowDivider(),
          CurrencyRateRow(
            currency: 'RUB',
            buy: point.buyRUB,
            sell: point.sellRUB,
          ),
          const CurrencyRowDivider(),
          CurrencyRateRow(
            currency: 'CNY',
            buy: point.buyCNY,
            sell: point.sellCNY,
          ),
          const CurrencyRowDivider(),
          CurrencyRateRow(
            currency: 'GBP',
            buy: point.buyGBP,
            sell: point.sellGBP,
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Обновлено: ${formatDateTime(point.dateUpdate)}',
                style: AppTypography.caption1.copyWith(color: secondaryLabel),
              ),
            ),
          ),
        ],
    );
  }
}

class CurrencyRateRow extends StatelessWidget {
  const CurrencyRateRow({
    super.key,
    required this.currency,
    required this.buy,
    required this.sell,
  });

  final String currency;
  final num buy;
  final num sell;

  @override
  Widget build(BuildContext context) {
    final bool hasRates = buy != 0 || sell != 0;
    final secondaryLabel = AppColors.secondaryLabel.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              currency,
              style: AppTypography.subheadline,
            ),
          ),
          Expanded(
            flex: 3,
            child: hasRates
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        buy == 0 ? '-' : '$buy',
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.buy.resolveFrom(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' / ',
                        style: AppTypography.subheadline.copyWith(
                          color: secondaryLabel,
                        ),
                      ),
                      Text(
                        sell == 0 ? '-' : '$sell',
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.sell.resolveFrom(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Не указано',
                    style: AppTypography.subheadline.copyWith(
                      color: secondaryLabel,
                    ),
                    textAlign: TextAlign.right,
                  ),
          ),
        ],
      ),
    );
  }
}

class CurrencyRowDivider extends StatelessWidget {
  const CurrencyRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.separator.resolveFrom(context),
            width: AppStroke.hairline,
          ),
        ),
      ),
      child: const SizedBox(width: double.infinity),
    );
  }
}
