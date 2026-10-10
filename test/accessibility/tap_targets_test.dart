import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/about/presentation/pages/about_page.dart';
import 'package:prokurs/features/auth/presentation/pages/sign_in_page.dart';
import 'package:prokurs/features/auth/presentation/pages/sign_up_page.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:prokurs/features/exchange_points/data/providers/cities_provider.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/add_exchange_point_page.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/my_points_page.dart';
import 'package:prokurs/features/home/presentation/pages/home_page.dart';
import 'package:prokurs/features/point/presentation/navigation/point_screen_arguments.dart';
import 'package:prokurs/features/point/presentation/pages/point_page.dart';
import 'package:prokurs/features/rates/presentation/pages/rates_page.dart';
import 'package:prokurs/features/rates/presentation/state/exchange_rates_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// No network in tests (the API client isn't initialized): the providers serve fixed data.
const _cities = [
  City(id: City.astanaId, title: 'Астана'),
  City(id: 10, title: 'Караганда'),
];

class _FakeCities extends CitiesProvider {
  @override
  List<City> get cities => _cities;

  @override
  List<City> get popularCities => [_cities.first];

  @override
  List<City> get unpopularCities => [_cities.last];

  @override
  Future<List<City>> fetchCities() async => _cities;
}

// Without coordinates: the point screen shows no map, which is a platform view.
ExchangePoint _point(int id) => ExchangePoint(
  id: id,
  name: 'Обменник $id',
  info: 'ул. Абая, $id',
  phones: const ['+7 701 123 4567', '2274'],
  buyUSD: 470.5,
  sellUSD: 475,
  buyEUR: 0,
  sellEUR: 0,
  buyRUB: 0,
  sellRUB: 0,
  buyCNY: 0,
  sellCNY: 0,
  buyGBP: 0,
  sellGBP: 0,
  dateUpdate: 1700000000,
  dayAndNight: 0,
  gross: 0,
  cityId: City.astanaId,
);

class _FakeRates extends ExchangeRatesProvider {
  @override
  List<ExchangePoint> get items => [_point(1), _point(2)];

  @override
  Future<void> fetchAndSetExchangeRates({required int cityId}) async {}
}

/// Apple HIG (Accessibility): controls are 44×44 pt by default and 28×28 pt at least. Segments of
/// a segmented control keep the system size, 28 pt tall; every other target needs 44 pt.
class _TapTargetGuideline extends MinimumTapTargetGuideline {
  const _TapTargetGuideline({required super.size, required this.segments})
    : super(
        link: 'https://developer.apple.com/design/human-interface-guidelines/accessibility',
      );

  /// Checks the segments only, or everything but them.
  final bool segments;

  @override
  bool shouldSkipNode(SemanticsNode node) =>
      super.shouldSkipNode(node) ||
      node.getSemanticsData().flagsCollection.isInMutuallyExclusiveGroup !=
          segments;
}

/// Checks Apple's minimum touch targets on [page] on an iPhone-sized screen, and,
/// for a root page, that every target has a VoiceOver label. A pushed page shows the standard
/// back button, which keeps its label on a child node that labeledTapTargetGuideline doesn't
/// look into, so labels are checked on root pages only. Layout overflows fail the test too.
Future<void> expectAccessibleTargets(
  WidgetTester tester,
  Widget page, {
  double textScale = 1,
  Object? arguments,
}) async {
  final semantics = tester.ensureSemantics();
  tester.view.physicalSize = const Size(1179, 2556); // iPhone 15
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<CitiesProvider>(create: (_) => _FakeCities()),
        ChangeNotifierProvider<ExchangeRatesProvider>(
          create: (_) => _FakeRates(),
        ),
      ],
      child: CupertinoApp(
        navigatorKey: navigator,
        theme: appTheme,
        home: arguments == null ? page : const SizedBox(),
      ),
    ),
  );
  if (arguments != null) {
    navigator.currentState!.push(
      CupertinoPageRoute(
        builder: (_) => page,
        settings: RouteSettings(arguments: arguments),
      ),
    );
  }
  await tester.pumpAndSettle();

  await expectLater(
    tester,
    meetsGuideline(
      const _TapTargetGuideline(size: Size(44, 44), segments: false),
    ),
  );
  await expectLater(
    tester,
    meetsGuideline(
      const _TapTargetGuideline(size: Size(28, 28), segments: true),
    ),
  );
  if (arguments == null) {
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  }
  semantics.dispose();
}

// The app's fonts instead of the test font, whose square glyphs are much wider: overflow
// checks then match what the screen shows.
Future<void> _loadAppFonts() async {
  for (final family in ['Manrope', 'Montserrat']) {
    final loader = FontLoader(family);
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final bytes = File('assets/fonts/$family-$weight.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(_loadAppFonts);

  setUp(() {
    SharedPreferences.setMockInitialValues({'cityId': City.astanaId});
    PackageInfo.setMockInitialValues(
      appName: 'prokurs',
      packageName: 'kz.prokurs',
      version: '3.0.3',
      buildNumber: '43',
      buildSignature: '',
    );
  });

  final pages = <(String, Widget, Object?)>[
    ('home', const HomePage(), null),
    ('rates', const RatesPage(), null),
    ('point', const PointPage(), PointScreenArguments(_point(1))),
    ('about', const AboutPage(), null),
    ('sign in', const SignInPage(), null),
    ('sign up', const SignUpPage(), null),
    ('my points', const MyPointsPage(), null),
    ('new exchange point', const AddExchangePointPage(), null),
  ];

  for (final (name, page, arguments) in pages) {
    testWidgets(
      name,
      (tester) => expectAccessibleTargets(tester, page, arguments: arguments),
    );

    // Dynamic Type: the screens still fit with text twice the default size.
    testWidgets(
      '$name with larger text',
      (tester) => expectAccessibleTargets(
        tester,
        page,
        arguments: arguments,
        textScale: 2,
      ),
    );
  }
}
