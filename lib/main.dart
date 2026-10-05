import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prokurs/features/auth/presentation/pages/sign_in_page.dart';
import 'package:prokurs/features/auth/presentation/pages/sign_up_page.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:prokurs/features/exchange_points/data/providers/cities_provider.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/add_exchange_point_page.dart';
import 'package:prokurs/features/rates/presentation/state/exchange_rates_provider.dart';
import 'package:prokurs/features/rates/presentation/pages/rates_page.dart';
import 'package:prokurs/features/about/presentation/pages/about_page.dart';
import 'package:prokurs/features/home/presentation/pages/home_page.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/my_points_page.dart';
import 'package:prokurs/features/point/presentation/pages/point_page.dart';
import 'package:prokurs/core/network/api_client.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prokurs/core/utils/env_helper.dart';
import 'package:prokurs/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  EnvHelper.initialize();

  final prefs = await SharedPreferences.getInstance();
  final cityId = prefs.getInt('cityId');
  final citiesProvider = CitiesProvider();
  final authProvider = AuthProvider();

  bool hasSelectedCity = false;
  bool isAuthenticated = false;

  try {
    // The client reads tokens from the provider lazily, so it doesn't depend on checkAuth.
    ApiClient.initialize(authProvider);
    isAuthenticated = await authProvider.checkAuth();

    debugPrint('main -> isAuthenticated: $isAuthenticated');
  } catch (e) {
    debugPrint('main -> error in authProvider.checkAuth: $e');
  }

  try {
    await citiesProvider.fetchCities();
    hasSelectedCity = cityId != null &&
        citiesProvider.cities.any((city) => city.id == cityId);
  } catch (e) {
    debugPrint('Error in citiesProvider.fetchCities: $e');
    hasSelectedCity = false;
  }

  return runApp(
    MyApp(
      hasSelectedCity: hasSelectedCity,
      isAuthenticated: isAuthenticated,
      reopenCabinet: prefs.getBool(MyPointsPage.reopenOnLaunchKey) ?? false,
      authProvider: authProvider,
      citiesProvider: citiesProvider,
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool hasSelectedCity;
  final bool isAuthenticated;

  /// The cabinet was open when the app last closed (see [MyPointsPage.reopenOnLaunchKey]).
  final bool reopenCabinet;
  final AuthProvider authProvider;
  final CitiesProvider citiesProvider;

  const MyApp({
    super.key,
    required this.hasSelectedCity,
    required this.isAuthenticated,
    this.reopenCabinet = false,
    required this.authProvider,
    required this.citiesProvider,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late bool _wasAuthenticated;

  @override
  void initState() {
    super.initState();
    // Now, not lazily: the first read would come from the listener, after the change.
    _wasAuthenticated = widget.authProvider.isAuthenticated;
    widget.authProvider.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    widget.authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  /// The one place that navigates on auth changes. When the session ends, the user goes back
  /// to the rates; the sign-in screen opens only if the server ended it, to say why.
  void _onAuthChanged() {
    final auth = widget.authProvider;
    if (_wasAuthenticated && !auth.isAuthenticated) {
      final navigator = _navigatorKey.currentState;
      navigator?.popUntil((route) => route.isFirst);
      if (auth.sessionExpired) {
        navigator?.pushNamed(SignInPage.routeName);
      }
    }
    _wasAuthenticated = auth.isAuthenticated;
  }

  /// The public part is always at the bottom: the rates, or the city choice before them. An
  /// owner who closed the app in the cabinet finds it open again, over the rates (Apple HIG,
  /// Launching: restore the previous state).
  List<Route<dynamic>> _initialRoutes(String _) => [
        _generateRoute(RouteSettings(
          name: widget.hasSelectedCity ? RatesPage.routeName : HomePage.routeName,
        )),
        if (widget.isAuthenticated && widget.reopenCabinet)
          _generateRoute(const RouteSettings(name: MyPointsPage.routeName)),
      ];

  @override
  Widget build(BuildContext context) {
    // force device orientation to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => widget.authProvider),
        ChangeNotifierProvider(create: (_) => ExchangeRatesProvider()),
        ChangeNotifierProvider(create: (_) => widget.citiesProvider),
      ],
      child: CupertinoApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        // System texts (back button label for VoiceOver, text selection menu) in Russian.
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        onGenerateInitialRoutes: _initialRoutes,
        onGenerateRoute: _generateRoute,
        theme: appTheme,
      ),
    );
  }

  static Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomePage.routeName:
        return CupertinoPageRoute(
          builder: (context) => const HomePage(),
          settings: settings,
        );
      case RatesPage.routeName:
        return CupertinoPageRoute(
          builder: (context) => const RatesPage(),
          settings: settings,
        );
      case PointPage.routeName:
        return CupertinoPageRoute(
          builder: (context) => const PointPage(),
          settings: settings,
        );
      case AboutPage.routeName:
        return CupertinoPageRoute(
          builder: (context) => const AboutPage(),
          settings: settings,
        );
      case SignInPage.routeName:
        return CupertinoPageRoute(
          builder: (context) => const SignInPage(),
          settings: settings,
        );
      case SignUpPage.routeName:
        return CupertinoPageRoute(
          builder: (context) => const SignUpPage(),
          settings: settings,
        );
      case MyPointsPage.routeName:
        return CupertinoPageRoute(
          builder: (context) => const MyPointsPage(),
          settings: settings,
        );
      case AddExchangePointPage.routeName:
        return CupertinoPageRoute(
          builder: (context) => const AddExchangePointPage(),
          settings: settings,
        );
      default:
        return CupertinoPageRoute(
          builder: (context) => const HomePage(),
          settings: settings,
        );
    }
  }
}
