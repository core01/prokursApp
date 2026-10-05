import 'dart:core';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prokurs/features/about/presentation/pages/about_page.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:prokurs/features/exchange_points/presentation/pages/my_points_page.dart';
import 'package:prokurs/features/point/presentation/navigation/point_screen_arguments.dart';
import 'package:prokurs/features/point/presentation/pages/point_page.dart';
import 'package:prokurs/features/exchange_points/data/providers/cities_provider.dart';
import 'package:prokurs/features/rates/presentation/state/exchange_rates_provider.dart';
import 'package:prokurs/features/rates/presentation/widgets/my_sliver_pinned_persistent_header_delegate.dart';
import 'package:prokurs/features/rates/presentation/widgets/rates_table.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/widgets/empty_state.dart';
import 'package:prokurs/features/home/presentation/widgets/city_list.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';

class RatesPage extends StatefulWidget {
  const RatesPage({super.key});

  @override
  _RatesPageState createState() => _RatesPageState();

  static const routeName = '/ratesPage';
}

enum Sorting { buy, sell }

class _RatesPageState extends State<RatesPage> {
  late ScrollController scrollController = ScrollController();

  bool _isLoading = true;
  bool _showSorting = true;

  late City _selectedCity;

  Sorting _sorting = Sorting.buy;

  List<City> cities = [];
  List<City> popularCities = [];
  List<City> unpopularCities = [];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    _load();
  }

  Future<void> _load() async {
    try {
      final citiesProvider = context.read<CitiesProvider>();
      // main.dart loaded the cities at launch; fetch them only if that failed.
      if (citiesProvider.cities.isEmpty) {
        await citiesProvider.fetchCities();
      }

      cities = citiesProvider.cities;
      popularCities = citiesProvider.popularCities;
      unpopularCities = citiesProvider.unpopularCities;

      final prefs = await SharedPreferences.getInstance();
      final cityId = prefs.getInt('cityId');
      if (!mounted) return;
      await onCitySelect(
        cities.any((city) => city.id == cityId) ? cityId! : cities.first.id,
      );
    } catch (err) {
      debugPrint('RatesPage -> _load: $err');
    } finally {
      // Right away: the content cross-fades in (see build), nobody waits for a delay.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void onCurrencySelect(CurrencyItem currency) {
    context.read<ExchangeRatesProvider>().changeSelectedCurrency(
      currency: currency.id,
    );
  }

  void _toggleByBestBuy() {
    debugPrint('RatesPage -> _toggleByBestBuy');
    context.read<ExchangeRatesProvider>().sortByBestBuy();
  }

  void _toggleByBestSell() {
    debugPrint('RatesPage -> _toggleByBestSell');
    context.read<ExchangeRatesProvider>().sortByBestSell();
  }

  Future<void> _onRatesRefresh() async {
    try {
      await context.read<ExchangeRatesProvider>().fetchAndSetExchangeRates(
        cityId: _selectedCity.id,
      );
    } catch (err) {
      debugPrint('RatesPage -> _onRatesRefresh: catch error $err');
    }
  }

  onCitySelect(int cityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      prefs.setInt('cityId', cityId);
    } catch (err) {
      debugPrint('RatesPage -> onCitySelect: catch error $err');
    }

    setState(() {
      _selectedCity = context.read<CitiesProvider>().findById(cityId);
    });

    if (!mounted) {
      return;
    }

    await context.read<ExchangeRatesProvider>().fetchAndSetExchangeRates(
      cityId: cityId,
    );
  }

  @override
  dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose(); // Dispose the controller

    super.dispose();
  }

  void _scrollListener() {
    if ((scrollController.position.pixels + 25.0) >=
        scrollController.position.maxScrollExtent) {
      setState(() {
        _showSorting = false;
      });
    } else {
      setState(() {
        _showSorting = true;
      });
    }
  }

  void _showCitySheet() {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background.resolveFrom(context),
      topRadius: AppRadius.card.topLeft,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xl),
                child: Text(
                  "Выберите город",
                  style: AppTypography.title2,
                  textAlign: TextAlign.center,
                ),
              ),
              CityList(
                popular: popularCities,
                others: unpopularCities,
                onSelect: (city) async {
                  await onCitySelect(city.id);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencySheet(String selectedCurrency) {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background.resolveFrom(context),
      topRadius: AppRadius.card.topLeft,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xxl,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xl),
                child: Text(
                  "Выберите валюту",
                  style: AppTypography.title2,
                  textAlign: TextAlign.center,
                ),
              ),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final currency in CURRENCY_LIST)
                    SizedBox(
                      // Options of one set share a size (Apple HIG, Buttons).
                      width: 160,
                      child: CupertinoButton(
                        color: selectedCurrency == currency.id
                            ? AppColors.accent
                            : AppColors.surface,
                        foregroundColor:
                            (selectedCurrency == currency.id
                                    ? AppColors.onAccent
                                    : AppColors.label)
                                .resolveFrom(sheetContext),
                        borderRadius: AppRadius.card,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(currency.label),
                        onPressed: () {
                          onCurrencySelect(currency);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A currency in the header: a pill, with the full 44-pt touch target around it.
  Widget _currencyChip(CurrencyItem currency, {required bool isSelected}) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onCurrencySelect(currency),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.onHeader : AppColors.headerFill,
          borderRadius: AppRadius.capsule,
          border: Border.all(
            color: AppColors.onHeaderSecondary,
            width: AppStroke.hairline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Text(
            '${currency.unicode}  ${currency.label}',
            style: AppTypography.body.copyWith(
              color: isSelected ? AppColors.header : AppColors.onHeader,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedHeader(
    String ratesUpdateTime,
    String selectedCurrency, {
    required bool isAuthenticated,
  }) {
    return Container(
      color: AppColors.header,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          foregroundColor: AppColors.onHeader,
                          onPressed: _showCitySheet,
                          child: Row(
                            children: [
                              Text(
                                _selectedCity.title,
                                style: AppTypography.title2,
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                              const Icon(CupertinoIcons.chevron_down),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Only for owners who signed in: the cabinet isn't advertised
                            // to everyone else (they find it in "О приложении").
                            if (isAuthenticated)
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                foregroundColor: AppColors.onHeader,
                                onPressed: () =>
                                    Navigator.of(context)
                                        .pushNamed(MyPointsPage.routeName),
                                child: const Icon(
                                  CupertinoIcons.person_circle,
                                  size: AppIconSize.regular,
                                  semanticLabel: 'Мои пункты',
                                ),
                              ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              foregroundColor: AppColors.onHeader,
                              onPressed: () =>
                                  Navigator.of(context)
                                      .pushNamed(AboutPage.routeName),
                              child: const Icon(
                                CupertinoIcons.info_circle,
                                size: AppIconSize.regular,
                                semanticLabel: 'О приложении',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "Обновлено в $ratesUpdateTime",
                      style: AppTypography.body.copyWith(
                        color: AppColors.onHeaderSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    for (final currency in CURRENCY_LIST)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpacing.xs,
                        ),
                        child: _currencyChip(
                          currency,
                          isSelected: selectedCurrency == currency.id,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedHeader(
    String ratesUpdateTime,
    String selectedCurrency,
  ) {
    return Container(
      color: AppColors.header,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_selectedCity.title),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                    child: Text("•"),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.onHeader,
                    onPressed: () => _showCurrencySheet(selectedCurrency),
                    child: Row(
                      children: [
                        Text(selectedCurrency),
                        const Icon(CupertinoIcons.chevron_down),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                "Обновлено в $ratesUpdateTime",
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.onHeaderSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void onPointClick(rate) {
      Navigator.of(
        context,
      ).pushNamed(PointPage.routeName, arguments: PointScreenArguments(rate));
    }

    final exchangeRates = context.watch<ExchangeRatesProvider>().items;
    final bestRetailRates = context
        .watch<ExchangeRatesProvider>()
        .bestRetailRates;
    final bestGrossRates = context
        .watch<ExchangeRatesProvider>()
        .bestGrossRates;
    final ratesUpdateTime = context
        .watch<ExchangeRatesProvider>()
        .ratesUpdateTime;
    final selectedCurrency = context
        .watch<ExchangeRatesProvider>()
        .selectedCurrency;
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // iOS: statusBarBrightness controls status bar appearance
        // Brightness.dark = dark background → light icons (for dark header)
        statusBarBrightness: Brightness.dark,
        // Android: statusBarIconBrightness controls icon colors
        // Brightness.light = light icons (for dark background)
        statusBarIconBrightness: Brightness.light,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: AppColors.surface,
        // The rates replace the spinner with a short cross-fade, as soon as they arrive.
        child: AnimatedSwitcher(
          duration: AppMotion.duration,
          switchInCurve: AppMotion.curve,
          switchOutCurve: AppMotion.curve,
          child: _isLoading
              ? const Center(
                  key: ValueKey('loading'),
                  child: CupertinoActivityIndicator(),
                )
              : Stack(
                  key: const ValueKey('rates'),
                  children: [
                    CustomScrollView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: <Widget>[
                        SliverPinnedPersistentHeader(
                          delegate: MySliverPinnedPersistentHeaderDelegate(
                            maxExtentProtoType: _buildExpandedHeader(
                              ratesUpdateTime,
                              selectedCurrency,
                              isAuthenticated: isAuthenticated,
                            ),
                            minExtentProtoType: _buildCollapsedHeader(
                              ratesUpdateTime,
                              selectedCurrency,
                            ),
                          ),
                        ),
                        CupertinoSliverRefreshControl(
                          onRefresh: _onRatesRefresh,
                        ),
                        if (exchangeRates.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: ColoredBox(
                              color: AppColors.background.resolveFrom(context),
                              child: EmptyState(
                                title: 'Курсов пока нет',
                                message:
                                    'К сожалению, на данный момент нет информации по актуальному курсу ${_sorting == Sorting.buy ? 'покупки' : 'продажи'} $selectedCurrency в городе ${_selectedCity.title}',
                              ),
                            ),
                          )
                        else
                          RatesTable(
                            exchangeRates: exchangeRates,
                            selectedCurrency: selectedCurrency,
                            bestGrossRates: bestGrossRates,
                            bestRetailRates: bestRetailRates,
                            onPointClick: onPointClick,
                          ),
                      ],
                    ),
                    if (exchangeRates.isNotEmpty &&
                        (_showSorting || exchangeRates.length <= 4))
                      Positioned(
                        left: 0,
                        right: 0,
                        // Above the home indicator.
                        bottom:
                            MediaQuery.paddingOf(context).bottom +
                            AppSpacing.md,
                        child: Center(
                          // The system size (32 pt), which Apple HIG allows for controls (at
                          // least 28 pt); stretching segments to 44 pt made it a bulky box.
                          child: CupertinoSlidingSegmentedControl<Sorting>(
                            backgroundColor: AppColors.header,
                            thumbColor: AppColors.headerFill,
                            groupValue: _sorting,
                            onValueChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sorting = value;
                                });

                                if (value == Sorting.buy) {
                                  _toggleByBestBuy();
                                } else {
                                  _toggleByBestSell();
                                }
                              }
                            },
                            children: {
                              Sorting.buy: _sortingLabel('Покупка'),
                              Sorting.sell: _sortingLabel('Продажа'),
                            },
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  // The control sets the font: 13 pt, semibold when selected.
  Widget _sortingLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    child: Text(text, style: const TextStyle(color: AppColors.onHeader)),
  );
}
