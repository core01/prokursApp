import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/rates/domain/models/best_rates.dart';
import 'package:prokurs/features/rates/presentation/widgets/rates_table.dart';

ExchangePoint _point({required num gross}) => ExchangePoint(
      id: 1,
      name: 'Обменник',
      info: null,
      phones: const [],
      buyUSD: 470,
      sellUSD: 475,
      buyEUR: 0,
      sellEUR: 0,
      buyRUB: 0,
      sellRUB: 0,
      buyCNY: 0,
      sellCNY: 0,
      buyGBP: 0,
      sellGBP: 0,
      date_update: 1700000000,
      day_and_night: 0,
      gross: gross,
      city_id: 3,
    );

Widget _table(List<ExchangePoint> points, {bool sortedByBuy = true}) => CupertinoApp(
      theme: appTheme,
      home: CustomScrollView(slivers: [
        RatesTable(
          exchangeRates: points,
          selectedCurrency: 'USD',
          bestRetailRates: BestRates(),
          bestGrossRates: BestRates(),
          onPointClick: (_) {},
          sortedByBuy: sortedByBuy,
        ),
      ]),
    );

void main() {
  for (final (gross, shown) in [(1, true), (0, false)]) {
    testWidgets('gross $gross: ${shown ? 'marked' : 'not marked'} as selling wholesale',
        (tester) async {
      await tester.pumpWidget(_table([_point(gross: gross)]));

      expect(find.text('Есть оптовые курсы'), shown ? findsOneWidget : findsNothing);
      expect(find.text('Оптовый курс'), findsNothing);
    });
  }

  // The buy rates are sorted highest first, the sell rates lowest first.
  for (final (sortedByBuy, title, arrow, otherArrow) in [
    (true, 'Покупка', CupertinoIcons.arrow_down, CupertinoIcons.arrow_up),
    (false, 'Продажа', CupertinoIcons.arrow_up, CupertinoIcons.arrow_down),
  ]) {
    testWidgets('sorted by "$title": an arrow next to its title shows the order',
        (tester) async {
      await tester.pumpWidget(_table(const [], sortedByBuy: sortedByBuy));

      final titleRow =
          find.ancestor(of: find.text(title), matching: find.byType(Row)).first;
      expect(find.descendant(of: titleRow, matching: find.byIcon(arrow)), findsOneWidget);
      expect(find.byIcon(otherArrow), findsNothing);
    });
  }
}
