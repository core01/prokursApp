import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prokurs/models/arguments/ratesScreenArguments.dart';
import 'package:prokurs/models/cityList.dart';
import 'package:prokurs/pages/rates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  var cities = CityList().items;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('images/logo.png'),
                      ),
                      Container(
                        child: Text(
                          'Выберите город',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        margin: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                      ),
                      ...cities.map(
                        (city) => CupertinoButton(
                          child: Text(city.title),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setInt('cityId', city.id);
                            debugPrint('Home -> build -> setCityId ${city.id}');

                            Navigator.pushNamed(
                              context,
                              RatesPage.routeName,
                              arguments: RatesScreenArguments(city),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Text(
                //   'v1 2021',
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
