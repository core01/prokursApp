import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/rates/domain/models/best_rates.dart';
import 'package:prokurs/features/rates/presentation/widgets/rates_table.dart';

void main() {
  // The buy rates are sorted highest first, the sell rates lowest first.
  for (final (sortedByBuy, title, arrow, otherArrow) in [
    (true, 'Покупка', CupertinoIcons.arrow_down, CupertinoIcons.arrow_up),
    (false, 'Продажа', CupertinoIcons.arrow_up, CupertinoIcons.arrow_down),
  ]) {
    testWidgets('sorted by "$title": an arrow next to its title shows the order',
        (tester) async {
      await tester.pumpWidget(CupertinoApp(
        theme: appTheme,
        home: CustomScrollView(slivers: [
          RatesTable(
            exchangeRates: const [],
            selectedCurrency: 'USD',
            bestRetailRates: BestRates(),
            bestGrossRates: BestRates(),
            onPointClick: (_) {},
            sortedByBuy: sortedByBuy,
          ),
        ]),
      ));

      final titleRow =
          find.ancestor(of: find.text(title), matching: find.byType(Row)).first;
      expect(find.descendant(of: titleRow, matching: find.byIcon(arrow)), findsOneWidget);
      expect(find.byIcon(otherArrow), findsNothing);
    });
  }
}
