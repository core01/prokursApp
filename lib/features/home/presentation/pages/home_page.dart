import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/features/auth/presentation/pages/sign_in_page.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:prokurs/features/exchange_points/data/providers/cities_provider.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/my_points_page.dart';
import 'package:prokurs/features/rates/presentation/pages/rates_page.dart';
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
  
  buildCityList(List<City> cities, BuildContext context) {
    return ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: cities.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(
              color: AppColors.separator.resolveFrom(context),
              indent: 0,
            ),
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          City city = cities[index];

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Text(
                    city.title,
                    style: AppTypography.body,
                  ),
                  const Spacer(),
                Icon(
                    CupertinoIcons.chevron_forward,
                    color: AppColors.secondaryLabel.resolveFrom(context),
                    size: 24,
                  ),
                ],
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
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    final popularCities = context.watch<CitiesProvider>().popularCities;
    final unpopularCities = context.watch<CitiesProvider>().unpopularCities;
    final surface = AppColors.surface.resolveFrom(context);

    return CupertinoPageScaffold(
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
        child: CustomScrollView(
          slivers: <Widget>[
            if (popularCities.isEmpty && unpopularCities.isEmpty) ...[
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await context.read<CitiesProvider>().fetchCities();
                },
                builder: (
                  BuildContext context,
                  RefreshIndicatorMode refreshState,
                  double pulledExtent,
                  double refreshTriggerPullDistance,
                  double refreshIndicatorExtent,
                ) {
                      return Center(
                      child: CupertinoActivityIndicator(
                          radius: 14.0,
                        ),
                   );
                },
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Список городов получить не удалось',
                        style: AppTypography.title3,
                      ),
                    ),
                    Text(
                      'Потяните вниз, что бы попробовать снова',
                      style: AppTypography.subheadline,
                    ),
                  ],
                ),
              )
            ] else ...[
              CupertinoSliverNavigationBar(
                largeTitle: Text('Выберите город'),
                trailing: GestureDetector(
                  onTap: () {
                    debugPrint('isAuthenticated: $isAuthenticated');
                    isAuthenticated
                        ? Navigator.pushNamed(context, MyPointsPage.routeName)
                        : Navigator.pushNamed(context, SignInPage.routeName);
                  },
                  child: Icon(
                    CupertinoIcons.person_circle,
                    size: 24.0,
                  ),
                ),
                backgroundColor: AppColors.background,
                border: Border(),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  if (popularCities.isNotEmpty) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      //padding: EdgeInsets.symmetric(horizontal: 15),
                      child: buildCityList(popularCities, context),
                    ),
                  ],
                  if (unpopularCities.isNotEmpty) ...[
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      //padding: EdgeInsets.symmetric(horizontal: 15),
                      child: buildCityList(unpopularCities, context),
                    ),
                  ],
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
