import 'package:flutter/cupertino.dart';
import 'package:prokurs/constants.dart';
import 'package:prokurs/models/city_list.dart';
import 'package:prokurs/pages/rates.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  const HomePage({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  var cities = CityList().items;

  Iterable<Container> formatCityList() {
    return cities.map(
      (city) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: CupertinoButton(
          color: AppColors.darkTheme.lightBg,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),

          // @todo rethink logic to add padding to all items but last
          child: Text(
            city.title,
            style: Typography.body.merge(TextStyle(
              color: AppColors.darkTheme.generalBlack,
            )),
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setInt('cityId', city.id);

            Navigator.pushNamed(context, RatesPage.routeName);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.darkTheme.generalWhite,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 97.5, 0, 22),
                          child: const Image(
                            width: 195,
                            height: 143,
                            image:
                                AssetImage('assets/images/home/background.png'),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 82),
                          child: const Image(
                            width: 130,
                            height: 162,
                            image: AssetImage('assets/images/home/point.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.fromLTRB(0, 32, 0, 24),
                    child: const Text(
                      'Выберите город',
                      style: Typography.heading,
                    ),
                  ),
                  ...formatCityList()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
