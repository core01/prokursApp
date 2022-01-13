import 'package:flutter/cupertino.dart';
import 'package:prokurs/models/city_list.dart';
import 'package:prokurs/pages/rates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  var cities = CityList().items;

  Iterable<CupertinoButton> formatCityList() {
    return cities.map((city) => CupertinoButton(
        child: Text(
          city.title,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('cityId', city.id);
          debugPrint('Home -> formatCityList -> onPressed ${city.id}');

          Navigator.pushNamed(context, RatesPage.routeName);
        }));
  }

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
                      Container(
                        child: Text(
                          'Выберите город',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        margin: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                      ),
                      ...formatCityList()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
