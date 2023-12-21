import 'dart:core';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Typography;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prokurs/models/arguments/point_screen_arguments.dart';
import 'package:prokurs/models/city_list.dart';
import 'package:prokurs/pages/about.dart';
import 'package:prokurs/pages/point.dart';
import 'package:prokurs/providers/exchange_points.dart';
import 'package:prokurs/widgets/MySliverPinnedPersistentHeaderDelegate.dart';
import 'package:prokurs/widgets/rates_table.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/city.dart';

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

  List<City> get cities => CityList().items;

  void onCurrencySelect(CurrencyItem currency) {
    context
        .read<ExchangePoints>()
        .changeSelectedCurrency(currency: currency.id);
  }

  void _toggleByBestBuy() {
    debugPrint('RatesPage -> _toggleByBestBuy');
    context.read<ExchangePoints>().sortByBestBuy();
  }

  void _toggleByBestSell() {
    debugPrint('RatesPage -> _toggleByBestSell');
    context.read<ExchangePoints>().sortByBestSell();
  }

  Future<void> _onRatesRefresh() async {
    try {
      await context
          .read<ExchangePoints>()
          .fetchAndSetExchangeRates(cityId: _selectedCity.id);
    } catch (err) {
      debugPrint('RatesPage -> _onRatesRefresh: catch error $err');
    }
  }

  onCitySelect(int cityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      prefs.setInt('cityId', cityId);
    } catch (err) {}

    setState(() {
      _selectedCity = CityList().findById(cityId);
    });

    if (!context.mounted) {
      return;
    }

    await context
        .read<ExchangePoints>()
        .fetchAndSetExchangeRates(cityId: cityId);
  }

  @override
  dispose() {
    debugPrint('111 dispose');
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
  void initState() {
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    debugPrint('5555 didChangeDependencies');
    if (_isInitializationNeeded) {
      setState(() {
        _isLoading = true;
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        final cityId = prefs.getInt('cityId') ?? CityList.ASTANA.id;
        await onCitySelect(cityId);
      } catch (err) {
        debugPrint(
            'Rates -> didChangeDependencies -> catch error in fetchAndSetExchangeRates: $err');
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

  @override
  Widget build(BuildContext context) {
    void onPointClick(rate) {
      Navigator.of(context).pushNamed(PointPage.routeName,
          arguments: PointScreenArguments(rate));
    }

    final exchangeRates = context.watch<ExchangePoints>().items;
    final bestRetailRates = context.watch<ExchangePoints>().bestRetailRates;
    final bestGrossRates = context.watch<ExchangePoints>().bestGrossRates;
    final ratesUpdateTime = context.watch<ExchangePoints>().ratesUpdateTime;
    final selectedCurrency = context.watch<ExchangePoints>().selectedCurrency;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.darkTheme.generalWhite,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isLoading) ...[
            Center(
              child: CupertinoActivityIndicator(
                color: AppColors.darkTheme.mainBlack,
                radius: 15,
              ),
            ),
          ] else ...[
            CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverPinnedPersistentHeader(
                  delegate: MySliverPinnedPersistentHeaderDelegate(
                    maxExtentProtoType: Container(
                      color: AppColors.darkTheme.mainBlack,
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
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 8, 0, 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showCupertinoModalBottomSheet(
                                                  backgroundColor: AppColors
                                                      .darkTheme.generalWhite,
                                                  context: context,
                                                  builder: (context) =>
                                                      Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        16, 32, 16, 16),
                                                    // height: 400,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 24),
                                                            child: const Text(
                                                              "Выберите город",
                                                              style: Typography
                                                                  .heading,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          ...cities
                                                              .map(
                                                                  (city) =>
                                                                      Container(
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                8),
                                                                        child:
                                                                            CupertinoButton(
                                                                          color: _selectedCity.id == city.id
                                                                              ? AppColors.darkTheme.generalBlack
                                                                              : AppColors.darkTheme.lightBg,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 8,
                                                                              horizontal: 16),

                                                                          // @todo rethink logic to add padding to all items but last
                                                                          child:
                                                                              Text(
                                                                            city.title,
                                                                            style:
                                                                                Typography.body.merge(TextStyle(
                                                                              color: _selectedCity.id == city.id ? AppColors.darkTheme.generalWhite : AppColors.darkTheme.generalBlack,
                                                                            )),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            await onCitySelect(city.id);
                                                                            if (context.mounted) {
                                                                              Navigator.of(context).pop();
                                                                            }
                                                                          },
                                                                        ),
                                                                      )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _selectedCity.title,
                                                    style: Typography.heading,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 4),
                                                    child: const Icon(Icons
                                                        .keyboard_arrow_down),
                                                  )
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              child: const Icon(
                                                  CupertinoIcons.info_circle),
                                              onTap: () {
                                                Navigator.of(context).pushNamed(
                                                    AboutPage.routeName);
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "Обновлено в $ratesUpdateTime",
                                        style: Typography.body2.merge(TextStyle(
                                          color:
                                              AppColors.darkTheme.darkSecondary,
                                        )),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 24),
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
                                              margin: EdgeInsets.fromLTRB(
                                                  i == 0 ? 16 : 0, 0, 8, 0),
                                              child: ActionChip(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 0,
                                                        horizontal: 5),
                                                side: BorderSide(
                                                  color: AppColors
                                                      .darkTheme.darkSecondary,
                                                  width: 0.5,
                                                ),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8))),
                                                label: Row(
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 8),
                                                      child: Text(
                                                        CURRENCY_LIST[i]
                                                            .unicode,
                                                        style: Typography.body2.merge(TextStyle(
                                                            color: selectedCurrency ==
                                                                    CURRENCY_LIST[
                                                                            i]
                                                                        .id
                                                                ? AppColors
                                                                    .darkTheme
                                                                    .mainBlack
                                                                : AppColors
                                                                    .darkTheme
                                                                    .generalWhite)),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        CURRENCY_LIST[i].label,
                                                        style: Typography.body2.merge(TextStyle(
                                                            color: selectedCurrency ==
                                                                    CURRENCY_LIST[
                                                                            i]
                                                                        .id
                                                                ? AppColors
                                                                    .darkTheme
                                                                    .mainBlack
                                                                : AppColors
                                                                    .darkTheme
                                                                    .generalWhite)),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor:
                                                    selectedCurrency ==
                                                            CURRENCY_LIST[i].id
                                                        ? AppColors.darkTheme
                                                            .generalWhite
                                                        : AppColors
                                                            .darkTheme.mainGrey,
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
                      color: AppColors.darkTheme.mainBlack,
                      child: SafeArea(
                        bottom: false,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedCity.title,
                                      style: Typography.body2,
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
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
                                              AppColors.darkTheme.generalWhite,
                                          context: context,
                                          builder: (context) => Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 32, 16, 16),
                                            // height: 256,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 24),
                                                  child: const Text(
                                                    "Выберите валюту",
                                                    style: Typography.heading,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Wrap(
                                                  direction: Axis.horizontal,
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    ...CURRENCY_LIST.map(
                                                        (currency) => SizedBox(
                                                              width: 160,
                                                              child:
                                                                  CupertinoButton(
                                                                color: selectedCurrency ==
                                                                        currency
                                                                            .id
                                                                    ? AppColors
                                                                        .darkTheme
                                                                        .generalBlack
                                                                    : AppColors
                                                                        .darkTheme
                                                                        .lightBg,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        16),

                                                                // @todo rethink logic to add padding to all items but last
                                                                child: Text(
                                                                  currency
                                                                      .label,
                                                                  style: Typography
                                                                      .body
                                                                      .merge(
                                                                          TextStyle(
                                                                    color: selectedCurrency ==
                                                                            currency
                                                                                .id
                                                                        ? AppColors
                                                                            .darkTheme
                                                                            .generalWhite
                                                                        : AppColors
                                                                            .darkTheme
                                                                            .generalBlack,
                                                                  )),
                                                                ),
                                                                onPressed: () {
                                                                  onCurrencySelect(
                                                                      currency);
                                                                  Navigator.of(
                                                                          context)
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
                                          const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child:
                                                Icon(Icons.keyboard_arrow_down),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "Обновлено в $ratesUpdateTime",
                                style: Typography.body3.merge(TextStyle(
                                  color: AppColors.darkTheme.darkSecondary,
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
                            color: AppColors.darkTheme.mainBlack,
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
                      color: AppColors.darkTheme.generalWhite,
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
                        backgroundColor: AppColors.darkTheme.mainGrey,
                        thumbColor: AppColors.darkTheme.mainBlack,
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
                              style: Typography.body3.merge(const TextStyle(
                                color: CupertinoColors.white,
                              )),
                            ),
                          ),
                          Sorting.sell: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Продажа',
                              style: Typography.body3.merge(const TextStyle(
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
    );
  }
}
