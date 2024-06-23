import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Typography;
import 'package:prokurs/constants.dart';
import 'package:prokurs/models/city.dart';
import 'package:prokurs/pages/rates.dart';
import 'package:prokurs/providers/cities.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  const HomePage({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  late TextEditingController textController;

  buildCityList(List<City> cities) {
    return ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: cities.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(
              color: DarkTheme.lightDivider,
              // height: 20,
              indent: 0,
            ),
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          City city = cities[index];

          return GestureDetector(
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  Text(
                    city.title,
                    style: Typography.body,
                  ),
                  const Spacer(),
                  const Icon(
                    CupertinoIcons.chevron_forward,
                    color: DarkTheme.lightSecondary,
                    size: 24,
                  ),
                ],
              ),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setInt('cityId', city.id);
              if (mounted) {
                Navigator.pushNamed(context, RatesPage.routeName);
              }
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: 'initial text');
    context.read<CitiesProvider>().fetchCities();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  bool onSubmitted = false;
  bool bottomEnabled = false;

  @override
  Widget build(BuildContext context) {
    final popularCities = context.watch<CitiesProvider>().popularCities;
    final unpopularCities = context.watch<CitiesProvider>().unpopularCities;

    return CupertinoPageScaffold(
      backgroundColor: DarkTheme.lightBg,
      // A ScrollView that creates custom scroll effects using slivers.
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
        child: CustomScrollView(
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(
              // This title is visible in both collapsed and expanded states.
              // When the "middle" parameter is omitted, the widget provided
              // in the "largeTitle" parameter is used instead in the collapsed state.
              largeTitle: Text('Выберите город'),
              backgroundColor: DarkTheme.lightBg,
              border: Border(),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: DarkTheme.generalWhite,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: buildCityList(popularCities),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: DarkTheme.generalWhite,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: buildCityList(unpopularCities),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
