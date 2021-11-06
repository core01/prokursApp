import 'package:prokurs/pages/point.dart';
import 'package:prokurs/pages/rates.dart';
import 'package:prokurs/providers/exchangePoints.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:prokurs/pages/home.dart';
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
        initialRoute:
            hasSelectedCity ? RatesPage.routeName : HomePage.routeName,
        routes: {
          HomePage.routeName: (context) => HomePage(),
          RatesPage.routeName: (context) => RatesPage(),
          PointPage.routeName: (context) => PointPage(),
        },
      ),
    );
  }
}
