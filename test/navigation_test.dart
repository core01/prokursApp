import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/network/api_client.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/auth/domain/models/auth_tokens.dart';
import 'package:prokurs/features/auth/presentation/pages/sign_in_page.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:prokurs/features/exchange_points/data/providers/cities_provider.dart';
import 'package:prokurs/features/exchange_points/data/services/exchange_points_service.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/my_points_page.dart';
import 'package:prokurs/features/point/presentation/navigation/point_screen_arguments.dart';
import 'package:prokurs/features/point/presentation/pages/point_page.dart';
import 'package:prokurs/features/rates/presentation/pages/rates_page.dart';
import 'package:prokurs/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A JWT whose payload is {"username":"owner@mail.kz"}; the signature isn't checked.
const _accessToken = 'x.eyJ1c2VybmFtZSI6Im93bmVyQG1haWwua3oifQ.x';

const _cities = [City(id: City.ASTANA_ID, title: 'Астана')];

class _FakeCities extends CitiesProvider {
  @override
  List<City> get cities => _cities;

  @override
  Future<List<City>> fetchCities() async => _cities;
}

class _CountingService extends ExchangePointsService {
  int calls = 0;

  @override
  Future<List<ExchangePoint>> getMyExchangePointsList() async {
    calls++;
    return [];
  }
}

// The test binding answers every HTTP request with an error, so screens get their error states.
Future<AuthProvider> _authProvider({required bool signedIn}) async {
  final authProvider = AuthProvider();
  dotenv.loadFromString(
    envString: 'API_URL_IOS=http://localhost\nAPI_URL_ANDROID=http://localhost',
  );
  ApiClient.initialize(authProvider);
  if (signedIn) {
    await authProvider.updateTokens(
      AuthTokens(accessToken: _accessToken, refreshToken: 'r'),
    );
  }
  return authProvider;
}

Future<void> _launch(
  WidgetTester tester,
  AuthProvider authProvider, {
  bool reopenCabinet = false,
}) async {
  await tester.pumpWidget(
    MyApp(
      hasSelectedCity: true,
      isAuthenticated: authProvider.isAuthenticated,
      reopenCabinet: reopenCabinet,
      authProvider: authProvider,
      citiesProvider: _FakeCities(),
    ),
  );
  await tester.pumpAndSettle();
}

// Without coordinates, no map: it's a platform view.
ExchangePoint _pointWith({
  required num gross,
  num? latitude,
  num? longitude,
}) =>
    ExchangePoint(
      id: 1,
      name: 'Обменник',
      info: null,
      phones: const ['2274'],
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
      wholesaleNote: 'Оптовые курсы от 100 000 тенге',
      city_id: City.ASTANA_ID,
      latitude: latitude,
      longitude: longitude,
    );

/// The point's screen over another route, as the app opens it from the rates.
Future<void> _openPoint(WidgetTester tester, ExchangePoint point) async {
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(CupertinoApp(
    navigatorKey: navigator,
    theme: appTheme,
    home: const SizedBox(),
  ));
  navigator.currentState!.push(CupertinoPageRoute(
    builder: (_) => const PointPage(),
    settings: RouteSettings(arguments: PointScreenArguments(point)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({'cityId': City.ASTANA_ID}),
  );

  testWidgets(
    'an owner who closed the app in the cabinet finds it again, over the rates',
    (tester) async {
      await _launch(
        tester,
        await _authProvider(signedIn: true),
        reopenCabinet: true,
      );
      expect(find.byType(MyPointsPage), findsOneWidget);

      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      expect(find.byType(RatesPage), findsOneWidget);
      expect(find.byType(MyPointsPage), findsNothing);
      // Left the cabinet: the next launch opens the rates.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(MyPointsPage.reopenOnLaunchKey), isFalse);
    },
  );

  testWidgets(
    'an owner who left the rates open starts on the rates, a tap from the cabinet',
    (tester) async {
      await _launch(tester, await _authProvider(signedIn: true));
      expect(find.byType(RatesPage), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.person_circle).hitTestable());
      await tester.pumpAndSettle();
      expect(find.byType(MyPointsPage), findsOneWidget);
    },
  );

  testWidgets(
    'a guest sees no cabinet over the rates; the way in is in "О приложении"',
    (tester) async {
      await _launch(tester, await _authProvider(signedIn: false));
      expect(find.byType(RatesPage), findsOneWidget);
      expect(
        find.byIcon(CupertinoIcons.person_circle).hitTestable(),
        findsNothing,
      );

      await tester.tap(find.byIcon(CupertinoIcons.info_circle).hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Для обменных пунктов'));
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
    },
  );

  testWidgets('signing out goes back to the rates', (tester) async {
    final authProvider = await _authProvider(signedIn: true);
    await _launch(tester, authProvider, reopenCabinet: true);

    await authProvider.signOut();
    await tester.pumpAndSettle();

    expect(find.byType(RatesPage), findsOneWidget);
    expect(find.byType(MyPointsPage), findsNothing);
    expect(find.byType(SignInPage), findsNothing);
  });

  testWidgets('an expired session opens sign-in over the rates, saying why', (
    tester,
  ) async {
    final authProvider = await _authProvider(signedIn: true);
    await _launch(tester, authProvider, reopenCabinet: true);

    await authProvider.expireSession();
    await tester.pumpAndSettle();

    expect(find.byType(SignInPage), findsOneWidget);
    expect(
      find.text('Сессия истекла. Войдите снова, чтобы продолжить'),
      findsOneWidget,
    );

    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(RatesPage), findsOneWidget);
  });

  testWidgets(
    'the point lists each phone once, even after the appearance changes',
    (tester) async {
      await _openPoint(tester, _pointWith(gross: 0));

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await tester.pumpAndSettle();

      expect(find.text('2274'), findsOneWidget);
    },
  );

  for (final (gross, shown) in [(1, true), (0, false)]) {
    testWidgets('gross $gross: the point ${shown ? 'shows' : 'hides'} its wholesale conditions',
        (tester) async {
      await _openPoint(tester, _pointWith(gross: gross));

      expect(find.text('Есть оптовые курсы'), shown ? findsOneWidget : findsNothing);
      expect(find.text('Оптовые курсы от 100 000 тенге'), shown ? findsOneWidget : findsNothing);
    });
  }

  // MapKit rejects camera moves until it has a surface to draw on: moveCamera returns false.
  testWidgets('the map repeats the camera move until MapKit accepts it', (tester) async {
    final accepted = [false, false, true];
    final moves = <Map>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, (call) async {
      if (call.method == 'create') {
        final id = (call.arguments as Map)['id'];
        messenger.setMockMethodCallHandler(MethodChannel('yandex_mapkit/yandex_map_$id'),
            (call) async {
          if (call.method != 'moveCamera') return null;
          moves.add(call.arguments as Map);
          return accepted[moves.length - 1];
        });
      }
      return null;
    });

    await _openPoint(tester, _pointWith(gross: 0, latitude: 51, longitude: 71.4));

    expect(moves, hasLength(3));
    expect(moves.last['cameraUpdate']['params']['cameraPosition'],
        containsPair('zoom', 16.0));
    expect(moves.last['cameraUpdate']['params']['cameraPosition']['target'],
        {'latitude': 51.0, 'longitude': 71.4});
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('my points load the list once', (tester) async {
    final service = _CountingService();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: CupertinoApp(
          theme: appTheme,
          home: MyPointsPage(service: service),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(service.calls, 1);
    expect(find.text('У вас пока нет обменных пунктов'), findsOneWidget);
  });
}
