import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
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
    final theme = CupertinoTheme.of(context);
    final themePrimaryColor = CupertinoDynamicColor.resolve(theme.primaryColor, context);
    final themePrimaryContrastingColor = CupertinoDynamicColor.resolve(theme.primaryContrastingColor, context);
    final themeScaffoldBackgroundColor = CupertinoDynamicColor.resolve(theme.scaffoldBackgroundColor, context);
    final themeBarBackgroundColor = CupertinoDynamicColor.resolve(theme.barBackgroundColor, context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: themePrimaryContrastingColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey6.withOpacity(0.5),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Валюта',
                    style: Typography.body3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DarkTheme.darkSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Покупка / Продажа',
                    style: Typography.body3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DarkTheme.darkSecondary,
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
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Обновлено: ${formatDateTime(point.date_update)}',
                style: Typography.body3.copyWith(
                  color: DarkTheme.darkSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              currency,
              style: Typography.body3.copyWith(
                fontWeight: FontWeight.w500,
                // color: DarkTheme.generalBlack,
              ),
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
                        style: Typography.body3.copyWith(
                          color: AppColors.generalGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' / ',
                        style: Typography.body3.copyWith(
                          color: DarkTheme.darkSecondary,
                        ),
                      ),
                      Text(
                        sell == 0 ? '-' : '$sell',
                        style: Typography.body3.copyWith(
                          color: AppColors.generalRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Не указано',
                    style: Typography.body3.copyWith(
                      color: DarkTheme.darkSecondary,
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
    return Container(
      height: 0.5,
      width: double.infinity,
      color: CupertinoColors.systemGrey5.withOpacity(0.5),
    );
  }
}
