import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/exchange_points/data/providers/cities_provider.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/add_exchange_point_page.dart';
import 'package:provider/provider.dart';

const _cities = [City(id: City.ASTANA_ID, title: 'Астана')];

class _FakeCities extends CitiesProvider {
  @override
  List<City> get cities => _cities;

  @override
  Future<List<City>> fetchCities() async => _cities;
}

void main() {
  testWidgets('the wholesale switch shows the field for its conditions', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    const placeholder = 'Оптовые курсы от 100 000 тенге';

    await tester.pumpWidget(ChangeNotifierProvider<CitiesProvider>(
      create: (_) => _FakeCities(),
      child: CupertinoApp(theme: appTheme, home: const AddExchangePointPage()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Возможна продажа по оптовому курсу'), findsOneWidget);
    expect(find.text(placeholder), findsNothing);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();
    expect(find.text(placeholder), findsOneWidget);

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();
    expect(find.text(placeholder), findsNothing);
  });
}
