import 'package:flutter/cupertino.dart';
import 'package:prokurs/pages/home.dart';
import 'package:prokurs/pages/point.dart';
import 'package:prokurs/pages/rates.dart';
import 'package:prokurs/providers/exchange_points.dart';
import 'package:prokurs/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final cityId = prefs.getInt('cityId');
  final bool _hasSelectedCity = cityId != null;

  return runApp(
    MyApp(
      hasSelectedCity: _hasSelectedCity,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSelectedCity;

  MyApp({required this.hasSelectedCity});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: ExchangePoints(),
        ),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        initialRoute: hasSelectedCity ? RatesPage.routeName : HomePage.routeName,
        routes: {
          HomePage.routeName: (context) => HomePage(),
          RatesPage.routeName: (context) => RatesPage(),
          PointPage.routeName: (context) => PointPage(),
        },
        theme: isDarkModeOn()
            ? CupertinoThemeData(
                brightness: Brightness.dark,
                primaryColor: Color(0xff4079ae),
                scaffoldBackgroundColor: Color(0xff000000),
                barBackgroundColor: Color(0xff151615),
                textTheme: CupertinoTextThemeData(
                  navTitleTextStyle: TextStyle(
                    color: Color(0xff8d8d8e),
                  ),
                  textStyle: TextStyle(
                    color: Color(0xff8d8d8e),
                    // fontSize: 16,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
