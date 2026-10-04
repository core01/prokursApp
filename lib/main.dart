import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    _redirectToSignInOnSignOut(authProvider);

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
      authProvider: authProvider,
      citiesProvider: citiesProvider,
    ),
  );
}

/// The one place that navigates on auth changes: whenever the session ends — the user signs
/// out or the server rejects the session — the user lands on the sign-in screen over Home.
void _redirectToSignInOnSignOut(AuthProvider authProvider) {
  var wasAuthenticated = authProvider.isAuthenticated;
  authProvider.addListener(() {
    if (wasAuthenticated && !authProvider.isAuthenticated) {
      navigatorKey.currentState
        ?..pushNamedAndRemoveUntil(HomePage.routeName, (route) => false)
        ..pushNamed(SignInPage.routeName);
    }
    wasAuthenticated = authProvider.isAuthenticated;
  });
}

class MyApp extends StatelessWidget {
  final bool hasSelectedCity;
  final bool isAuthenticated;
  final AuthProvider authProvider;
  final CitiesProvider citiesProvider;

  const MyApp({
    super.key,
    required this.hasSelectedCity,
    required this.isAuthenticated,
    required this.authProvider,
    required this.citiesProvider,
  });

  String _getInitialRoute() {
    if (isAuthenticated) {
      return MyPointsPage.routeName;
    }
    if (hasSelectedCity) {
      return RatesPage.routeName;
    }
    return HomePage.routeName;
  }

  @override
  Widget build(BuildContext context) {
    // force device orientation to portrait only
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => ExchangeRatesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => citiesProvider,
        ),
      ],
      child: CupertinoApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        initialRoute: _getInitialRoute(),
        onGenerateRoute: (RouteSettings settings) {
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
        },
        theme: appTheme,
      ),
    );
  }
}
