import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/widgets/empty_state.dart';
import 'package:prokurs/features/exchange_points/data/providers/cities_provider.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';
import 'package:prokurs/features/home/presentation/widgets/city_list.dart';
import 'package:prokurs/features/rates/presentation/pages/rates_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  Future<void> _selectCity(City city) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('cityId', city.id);
    if (mounted) {
      // The rates become the root: the city is changed from their header from now on.
      Navigator.pushReplacementNamed(context, RatesPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final popularCities = context.watch<CitiesProvider>().popularCities;
    final unpopularCities = context.watch<CitiesProvider>().unpopularCities;

    Future<void> refresh() => context.read<CitiesProvider>().fetchCities();

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          if (popularCities.isEmpty && unpopularCities.isEmpty) ...[
            CupertinoSliverRefreshControl(onRefresh: refresh),
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                title: 'Список городов получить не удалось',
                actionLabel: 'Повторить',
                onAction: refresh,
              ),
            ),
          ] else ...[
            CupertinoSliverNavigationBar(
              largeTitle: const Text('Выберите город'),
              backgroundColor: AppColors.background,
              border: null,
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: CityList(
                  popular: popularCities,
                  others: unpopularCities,
                  onSelect: _selectCity,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
