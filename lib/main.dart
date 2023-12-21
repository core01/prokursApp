import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prokurs/pages/about.dart';
import 'package:prokurs/pages/home.dart';
import 'package:prokurs/pages/point.dart';
import 'package:prokurs/pages/rates.dart';
import 'package:prokurs/providers/exchange_points.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final cityId = prefs.getInt('cityId');
  final bool hasSelectedCity = cityId != null;

  return runApp(
    MyApp(
      hasSelectedCity: hasSelectedCity,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSelectedCity;

  const MyApp({super.key, required this.hasSelectedCity});

  @override
  Widget build(BuildContext context) {
    // force device orientation to portrait only
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExchangePoints(),
        ),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        initialRoute:
            hasSelectedCity ? RatesPage.routeName : HomePage.routeName,
        routes: {
          HomePage.routeName: (context) => const HomePage(),
          RatesPage.routeName: (context) => const RatesPage(),
          PointPage.routeName: (context) => const PointPage(),
          AboutPage.routeName: (context) => const AboutPage(),
        },
        // builder: (context, child) {
        //   final mediaQueryData = MediaQuery.of(context);
        //   return MediaQuery(
        //     // Set the default textScaleFactor to 1.0 for
        //     // the whole subtree.
        //     data: mediaQueryData.copyWith(
        //         // textScaleFactor: 1.0,
        //         ),
        //     child: child ?? const SizedBox.shrink(),
        //   );
        // },
        theme: CupertinoThemeData(
            primaryColor: AppColors.darkTheme.generalWhite,
            scaffoldBackgroundColor: AppColors.darkTheme.mainBlack,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(
                fontFamily: 'Manrope',
                color: AppColors.darkTheme.generalBlack,
                fontFamilyFallback: const ['Montserrat'],
              ),
            )),
      ),
    );
  }
}
