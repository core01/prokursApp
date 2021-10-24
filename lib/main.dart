import 'package:prokurs/pages/rates.dart';
import 'package:prokurs/providers/exchangeRates.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:prokurs/pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: ExchangeRates(),
        ),
      ],
      child: CupertinoApp(
        initialRoute: '/',
        routes: {
          HomePage.routeName: (context) => HomePage(),
          RatesPage.routeName: (context) => RatesPage(),
        },
      ),
    );
  }
}
