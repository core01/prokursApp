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
import 'package:prokurs/core/constants/app_constants.dart';

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
    // First check authentication
    isAuthenticated = await authProvider.checkAuth();
    // Then initialize API client with the authenticated provider
    ApiClient.initialize(authProvider);

    debugPrint('main -> isAuthenticated: $isAuthenticated');
    debugPrint(
        'main -> authProvider.tokens = ${authProvider.tokens?.accessToken}');
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
        theme: CupertinoThemeData(
          primaryColor: CupertinoDynamicColor.withBrightness(
            color: AppColors.generalBlack,
            darkColor: AppColors.generalWhite,
          ),
          primaryContrastingColor: CupertinoDynamicColor.withBrightness(
            color: AppColors.generalWhite,
            darkColor: AppColors.generalBlack,
          ),
          scaffoldBackgroundColor: CupertinoDynamicColor.withBrightness(
            color: AppColors.lightBg,
            darkColor: AppColors.mainBlack,
          ),
          barBackgroundColor: CupertinoDynamicColor.withBrightness(
            color: AppColors.mainBlack,
            darkColor: AppColors.mainBlack,
          ),
          textTheme: CupertinoTextThemeData(
            textStyle: const TextStyle(fontFamily: 'Manrope', fontFamilyFallback: ['Montserrat']).copyWith(
              color: CupertinoDynamicColor.withBrightness(
                color: AppColors.mainBlack,
                darkColor: AppColors.generalWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
