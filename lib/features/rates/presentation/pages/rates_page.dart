import 'dart:core';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Typography;
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prokurs/features/about/presentation/pages/about_page.dart';
import 'package:prokurs/features/point/presentation/navigation/point_screen_arguments.dart';
import 'package:prokurs/features/point/presentation/pages/point_page.dart';
import 'package:prokurs/features/exchange_points/data/providers/cities_provider.dart';
import 'package:prokurs/features/rates/presentation/state/exchange_rates_provider.dart';
import 'package:prokurs/features/rates/presentation/widgets/my_sliver_pinned_persistent_header_delegate.dart';
import 'package:prokurs/features/rates/presentation/widgets/rates_table.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prokurs/core/constants/app_constants.dart';
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

  bool _isInitializationNeeded = true;
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
  }

  void onCurrencySelect(CurrencyItem currency) {
    context
        .read<ExchangeRatesProvider>()
        .changeSelectedCurrency(currency: currency.id);
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
      await context
          .read<ExchangeRatesProvider>()
          .fetchAndSetExchangeRates(cityId: _selectedCity.id);
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

    await context
        .read<ExchangeRatesProvider>()
        .fetchAndSetExchangeRates(cityId: cityId);
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

  @override
  void didChangeDependencies() async {
    debugPrint('pages -> rates -> didChangeDependencies');
    if (_isInitializationNeeded) {
      setState(() {
        _isLoading = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        if (mounted) {
          await context.read<CitiesProvider>().fetchCities();

          cities = context.read<CitiesProvider>().cities;
          popularCities = context.read<CitiesProvider>().popularCities;
          unpopularCities = context.read<CitiesProvider>().unpopularCities;

          final cityId = prefs.getInt('cityId')!;
          await onCitySelect(cities.any((city) => city.id == cityId)
              ? cityId
              : cities.first.id);
        }
      } catch (err) {
        debugPrint(
            'pages -> rates -> didChangeDependencies -> catch error in fetchAndSetExchangeRates: $err');
      } finally {
        _isInitializationNeeded = false;
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _isLoading = false;
          });
        });
      }
    }

    super.didChangeDependencies();
  }

  buildCityList(List<City> cities) {
    return ListView.separated(
        scrollDirection: Axis.vertical,
        itemCount: cities.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(
              color: DarkTheme.lightDivider,
              height: 20,
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
              await onCitySelect(city.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    void onPointClick(rate) {
      Navigator.of(context).pushNamed(PointPage.routeName,
          arguments: PointScreenArguments(rate));
    }

    final exchangeRates = context.watch<ExchangeRatesProvider>().items;
    final bestRetailRates = context.watch<ExchangeRatesProvider>().bestRetailRates;
    final bestGrossRates = context.watch<ExchangeRatesProvider>().bestGrossRates;
    final ratesUpdateTime = context.watch<ExchangeRatesProvider>().ratesUpdateTime;
    final selectedCurrency = context.watch<ExchangeRatesProvider>().selectedCurrency;

final theme = CupertinoTheme.of(context);
    final Color themePrimaryContrastingColor = CupertinoDynamicColor.resolve(theme.primaryContrastingColor, context);
    final Color themePrimaryColor = CupertinoDynamicColor.resolve(theme.primaryColor, context);
    final Color themeScaffoldBackgroundColor = CupertinoDynamicColor.resolve(theme.scaffoldBackgroundColor, context);
    final Color themeBarBackgroundColor = CupertinoDynamicColor.resolve(theme.barBackgroundColor, context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: themeScaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: themePrimaryContrastingColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isLoading) ...[
                      const Center(child: CupertinoActivityIndicator(color: DarkTheme.mainBlack, radius: 15)),
                    ] else ...[
                      CustomScrollView(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverPinnedPersistentHeader(
                            delegate: MySliverPinnedPersistentHeaderDelegate(
                              maxExtentProtoType: Container(
                                color: themeBarBackgroundColor,
                                child: SafeArea(
                                  bottom: false,
                                  child: SingleChildScrollView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 0, 16, 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 8, 0, 4),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                          showCupertinoModalBottomSheet(
                                                            backgroundColor:
                                                                themeScaffoldBackgroundColor,
                                                          context: context,
                                                          builder: (context) =>
                                                              Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(0,
                                                                    32, 0, 32),
                                                            // height: 400,
                                                              color: themeScaffoldBackgroundColor,
                                                            child:
                                                                SingleChildScrollView(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                children: [
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            24),
                                                                    child:
                                                                        const Text(
                                                                      "Выберите город",
                                                                      style: Typography
                                                                          .heading,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  if (popularCities
                                                                      .isNotEmpty) ...[
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                          color: themePrimaryContrastingColor,
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                      ),
                                                                      //padding: EdgeInsets.symmetric(horizontal: 15),
                                                                      child: buildCityList(
                                                                          popularCities),
                                                                    ),
                                                                  ],
                                                                  if (unpopularCities
                                                                      .isNotEmpty) ...[
                                                                    const SizedBox(
                                                                      height:
                                                                          40,
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              15),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                          color: themePrimaryContrastingColor,
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                      ),
                                                                      //padding: EdgeInsets.symmetric(horizontal: 15),
                                                                      child: buildCityList(
                                                                          unpopularCities),
                                                                    )
                                                                  ]
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            _selectedCity.title,
                                                            style: Typography
                                                                .heading,
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 4),
                                                              child: Icon(
                                                                Icons.keyboard_arrow_down,
                                                                color: AppColors.generalWhite,
                                                              ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      child: const Icon(
                                                          CupertinoIcons
                                                              .info_circle,
                                                          color: AppColors.generalWhite,
                                                        ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pushNamed(AboutPage
                                                                .routeName);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "Обновлено в $ratesUpdateTime",
                                                style: Typography.body2
                                                    .merge(const TextStyle(
                                                  color:
                                                      DarkTheme.darkSecondary,
                                                )),
                                                textAlign: TextAlign.left,
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 24),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  for (var i = 0;
                                                      i < CURRENCY_LIST.length;
                                                      i++) ...[
                                                    Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              i == 0 ? 16 : 0,
                                                              0,
                                                              8,
                                                              0),
                                                      child: ActionChip(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 0,
                                                                horizontal: 5),
                                                        side: const BorderSide(
                                                          color: DarkTheme
                                                              .darkSecondary,
                                                          width: 0.5,
                                                        ),
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                        label: Row(
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right: 8),
                                                              child: Text(
                                                                CURRENCY_LIST[i]
                                                                    .unicode,
                                                                style: Typography.body2.merge(TextStyle(
                                                                    color: selectedCurrency ==
                                                                            CURRENCY_LIST[i]
                                                                                .id
                                                                        ? DarkTheme
                                                                            .mainBlack
                                                                        : DarkTheme
                                                                            .generalWhite)),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Container(
                                                              child: Text(
                                                                CURRENCY_LIST[i]
                                                                    .label,
                                                                style: Typography.body2.merge(TextStyle(
                                                                    color: selectedCurrency ==
                                                                            CURRENCY_LIST[i]
                                                                                .id
                                                                        ? DarkTheme
                                                                            .mainBlack
                                                                        : DarkTheme
                                                                            .generalWhite)),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        backgroundColor:
                                                            selectedCurrency ==
                                                                    CURRENCY_LIST[
                                                                            i]
                                                                        .id
                                                                ? DarkTheme
                                                                    .generalWhite
                                                                : DarkTheme
                                                                    .mainGrey,
                                                        onPressed: () {
                                                          onCurrencySelect(
                                                              CURRENCY_LIST[i]);
                                                        },
                                                      ),
                                                    )
                                                  ]
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            minExtentProtoType: Container(
                                color: themeBarBackgroundColor,
                              child: SafeArea(
                                bottom: false,
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            Text(
                                              _selectedCity.title,
                                              style: Typography.body2,
                                              textAlign: TextAlign.left,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: const Text(
                                                "•",
                                                style: Typography.body2,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                  showCupertinoModalBottomSheet(
                                                    backgroundColor:
                                                        themeScaffoldBackgroundColor,
                                                  context: context,
                                                  builder: (context) =>
                                                      Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        16, 32, 16, 16),
                                                    // height: 256,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 24),
                                                          child: const Text(
                                                            "Выберите валюту",
                                                            style: Typography
                                                                .heading,
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Wrap(
                                                          direction:
                                                              Axis.horizontal,
                                                          spacing: 8,
                                                          runSpacing: 8,
                                                          children: [
                                                            ...CURRENCY_LIST.map(
                                                                (currency) =>
                                                                    SizedBox(
                                                                      width:
                                                                          160,
                                                                      child:
                                                                          CupertinoButton(
                                                                        color: selectedCurrency ==
                                                                                currency.id
                                                                            ? DarkTheme.generalBlack
                                                                            : DarkTheme.lightBg,
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                8,
                                                                            horizontal:
                                                                                16,
                                                                    ),
                                                                        child:
                                                                            Text(
                                                                          currency
                                                                              .label,
                                                                          style: Typography
                                                                              .body
                                                                              .merge(TextStyle(
                                                                            color: selectedCurrency == currency.id
                                                                                ? DarkTheme.generalWhite
                                                                                : DarkTheme.generalBlack,
                                                                          )),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          onCurrencySelect(
                                                                              currency);
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                    )),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    selectedCurrency,
                                                    style: Typography.body2,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                    SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child: Icon(Icons
                                                        .keyboard_arrow_down,
                                                        color: AppColors.generalWhite,
                                                      ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "Обновлено в $ratesUpdateTime",
                                        style: Typography.body3
                                            .merge(const TextStyle(
                                          color: DarkTheme.darkSecondary,
                                        )),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        CupertinoSliverRefreshControl(
                          onRefresh: () async {
                            await _onRatesRefresh();
                          },
                          builder: (
                            BuildContext context,
                            RefreshIndicatorMode refreshState,
                            double pulledExtent,
                            double refreshTriggerPullDistance,
                            double refreshIndicatorExtent,
                          ) {
                                  return Center(
                                child: Stack(
                              children: [
                                Positioned(
                                  top: 15.0,
                                  bottom: 15.0,
                                  left: 0.0,
                                  right: 0.0,
                                  child: CupertinoActivityIndicator(
                                            color: themePrimaryColor,
                                    radius: 14.0,
                                  ),
                                )
                              ],
                            ));
                          },
                        ),
                        if (exchangeRates.isEmpty) ...[
                          SliverFillRemaining(
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(16),
                                color: themeScaffoldBackgroundColor,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'К сожалению, на данный момент нет информации по актуальному курсу ${_sorting == Sorting.buy ? 'покупки' : 'продажи'} $selectedCurrency в городе ${_selectedCity.title}',
                                      textAlign: TextAlign.center,
                                      style: Typography.body2,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          RatesTable(
                            exchangeRates: exchangeRates,
                            selectedCurrency: selectedCurrency,
                            bestGrossRates: bestGrossRates,
                            bestRetailRates: bestRetailRates,
                            onPointClick: onPointClick,
                          ),
                        ],
                      ],
                    ),
                    if (exchangeRates.isNotEmpty &&
                        (_showSorting || exchangeRates.length <= 4)) ...[
                      Positioned.fill(
                        bottom: 38,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: CupertinoSlidingSegmentedControl(
                                padding: const EdgeInsets.all(4),
                                backgroundColor: DarkTheme.mainGrey,
                                thumbColor: DarkTheme.mainBlack,
                                // This represents the currently selected segmented control.
                                groupValue: _sorting,
                                // Callback that sets the selected segmented control.
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
                                  Sorting.buy: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      'Покупка',
                                      style: Typography.body3
                                          .merge(const TextStyle(
                                        color: CupertinoColors.white,
                                      )),
                                    ),
                                  ),
                                  Sorting.sell: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      'Продажа',
                                      style: Typography.body3
                                          .merge(const TextStyle(
                                        color: CupertinoColors.white,
                                      )),
                                    ),
                                  ),
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
