import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' hide MapType;

Future<BitmapDescriptor> getBitmapDescriptorFromUrl(String imageUrl) async {
  final http.Response response = await http.get(Uri.parse(imageUrl));
  final Uint8List bytes = response.bodyBytes;

  // Create a BitmapDescriptor from the downloaded bytes
  BitmapDescriptor bitmapDescriptor = BitmapDescriptor.fromBytes(bytes);

  return bitmapDescriptor;
}

class PointCard extends StatefulWidget {
  final ExchangePoint point;

  const PointCard({super.key, required this.point});

  @override
  PointCardState createState() => PointCardState();
}

class PointCardState extends State<PointCard> {
  bool _isLoading = true;
  List phoneNumbers = [];
  BitmapDescriptor? bitmapDescriptor;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (widget.point.hasLogo) {
      bitmapDescriptor = await getBitmapDescriptorFromUrl(widget.point.logo!);
    }

    for (var phone in widget.point.phones) {
      phoneNumbers.add(phone);
    }

    setState(() {
      _isLoading = false;
    });
  }

  bool hasPointCurrencyBuyValue(String currencyId) {
    return widget.point.get('$BUY_KEY$currencyId') != 0;
  }

  bool hasPointCurrencySellValue(String currencyId) {
    return widget.point.get('$SELL_KEY$currencyId') != 0;
  }

  String getPointCurrencyBuyValue(String currencyId) {
    return getPointCurrencyRateStringFormatted(
        widget.point, '$BUY_KEY$currencyId');
  }

  String getPointCurrencySellValue(String currencyId) {
    return getPointCurrencyRateStringFormatted(
        widget.point, '$SELL_KEY$currencyId');
  }

  void _launchPhone(phone) async {
    final Uri phoneLink =
        Uri.parse('tel://${phone.replaceAll(RegExp("[^\\d+]"), "")}');

    if (await canLaunchUrl(phoneLink)) {
      await launchUrl(phoneLink);
    } else {
      debugPrint('Can\'t launch $phoneLink');
    }
  }

  Future<void> _openInMaps() async {
    final double? latitude = widget.point.latitude?.toDouble();
    final double? longitude = widget.point.longitude?.toDouble();

    if (latitude == null || longitude == null) {
      debugPrint('Missing coordinates for map preview');
      return;
    }

    final Coords coords = Coords(latitude, longitude);
    List<AvailableMap> installedMaps = [];

    try {
      installedMaps = await MapLauncher.installedMaps;
    } catch (error) {
      debugPrint('Error fetching installed maps: $error');
    }

    final Set<MapType> handledTypes = installedMaps.map((map) => map.mapType).toSet();
    final List<({String name, Future<void> Function() open})> mapOptions = [
      for (final map in installedMaps)
        (
          name: map.mapName,
          open: () async {
            try {
              await map.showMarker(coords: coords, title: widget.point.name, description: widget.point.info);
            } catch (error) {
              debugPrint('Failed to open ${map.mapName}: $error');
            }
          },
        ),
    ];

    Future<void> addMapType(MapType type, String displayName) async {
      if (handledTypes.contains(type)) return;
      final bool isAvailable = (await MapLauncher.isMapAvailable(type)) ?? false;
      if (!isAvailable) return;
      handledTypes.add(type);
      mapOptions.add((
        name: displayName,
        open: () async {
          try {
            await MapLauncher.showMarker(
              mapType: type,
              coords: coords,
              title: widget.point.name,
              description: widget.point.info,
            );
          } catch (error) {
            debugPrint('Failed to open $displayName: $error');
          }
        },
      ));
    }

    await addMapType(MapType.apple, 'Apple Maps');
    await addMapType(MapType.google, 'Google Maps');
    await addMapType(MapType.yandexMaps, 'Яндекс.Карты');

    if (mapOptions.isEmpty) {
      final String lonLatPair = '$longitude,$latitude';
      final Uri fallbackUri = Uri.parse('https://yandex.ru/maps/?ll=$lonLatPair&z=16&pt=$lonLatPair');

      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Unable to open any map application for point preview');
      }
      return;
    }

    if (!mounted) return;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return CupertinoActionSheet(
          title: const Text('Открыть в приложении'),
          actions: mapOptions
              .map(
                (option) => CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.of(modalContext).pop();
                    await option.open();
                  },
                  child: Text(option.name),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(modalContext).pop(),
            child: const Text('Отмена'),
          ),
        );
      },
    );
  }

  getCurrencyRows(BuildContext context) {
    List<Widget> rows = [];

    for (var i = 0; i < CURRENCY_LIST.length; i++) {
      var currency = CURRENCY_LIST[i];
      if (canRenderCurrencyRow(getPointCurrencyBuyValue(currency.id),
          getPointCurrencySellValue(currency.id))) {
        rows.add(Container(
          decoration: BoxDecoration(
            border: i != CURRENCY_LIST.length - 1
                  ? Border(top: BorderSide(
                      width: 1,
                      color: CupertinoDynamicColor.resolve(AppColors.divider, context),
                    ),
                  )
                  : Border(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Flexible(
                  flex: 4,
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 8),
                  child: Text(
                    "${currency.icon} ${currency.unicode} ${currency.label}",
                    style: Typography.body2,
                  ),
                ),
              ),
              Expanded(
                  flex: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                getPointCurrencyBuyValue(currency.id),
                                style: Typography.body2,
                                softWrap: false,
                              ),
                              if (hasPointCurrencyBuyValue(currency.id)) ...[
                                // Tenge sign
                                const Text('\u{20B8}',
                                    textAlign: TextAlign.center,
                                    style: Typography.body2),
                              ]
                            ]),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(
                          left: 8,
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                getPointCurrencySellValue(currency.id),
                                style: Typography.body2,
                                softWrap: false,
                              ),
                              if (hasPointCurrencySellValue(currency.id)) ...[
                                // Tenge sign
                                const Text('\u{20B8}',
                                    textAlign: TextAlign.center,
                                    style: Typography.body2),
                              ]
                            ]),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
      }
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    const MapObjectId mapObjectId = MapObjectId('normal_icon_placemark');

    bool hasMapCoordinates =
        widget.point.latitude != null &&
        widget.point.longitude != null &&
        widget.point.latitude != 0 &&
        widget.point.longitude != 0;

final theme = CupertinoTheme.of(context);
    final Color themePrimaryContrastingColor = CupertinoDynamicColor.resolve(theme.primaryContrastingColor, context);
    final Color themePrimaryColor = CupertinoDynamicColor.resolve(theme.primaryColor, context);
    final Color themeScaffoldBackgroundColor = CupertinoDynamicColor.resolve(theme.scaffoldBackgroundColor, context);
    final Color themeBarBackgroundColor = CupertinoDynamicColor.resolve(theme.barBackgroundColor, context);
    if (_isLoading) {
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
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasMapCoordinates) ...[
              SizedBox(
                height: 280,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: YandexMap(
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        onMapCreated: (YandexMapController yandexMapController) async {
                          yandexMapController.moveCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: Point(
                                  latitude: widget.point.latitude as double,
                                  longitude: widget.point.longitude as double,
                                ),
                                zoom: 16,
                              ),
                            ),
                          );
                        },
                        mapObjects: [
                          PlacemarkMapObject(
                            mapId: mapObjectId,
                            point: Point(
                              latitude: widget.point.latitude as double,
                              longitude: widget.point.longitude as double,
                            ),
                            opacity: bitmapDescriptor != null ? 1 : 0.8,
                            icon: PlacemarkIcon.single(
                              PlacemarkIconStyle(
                                anchor: const Offset(0.7, 1.0),
                                // bitmapDescriptor has 250x250 size
                                scale: bitmapDescriptor != null ? 0.4 : 1.2,
                                image: bitmapDescriptor != null
                                    ? bitmapDescriptor!
                                    : BitmapDescriptor.fromAssetImage('assets/images/pin.png'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        borderRadius: BorderRadius.circular(16),
                        color: themePrimaryColor,
                        onPressed: _openInMaps,
                        child: Text(
                          'Открыть в картах',
                          style: Typography.body3.copyWith(color: themePrimaryContrastingColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              color: themeScaffoldBackgroundColor,
              padding: const EdgeInsets.only(bottom: 16),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.point.info != null) ...[
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          widget.point.info as String,
                          style: Typography.body2,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 4),
                      child: Text(
                        "Телефоны:",
                        style: Typography.body2.merge(const TextStyle(
                          color: AppColors.darkSecondary,
                        )),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < phoneNumbers.length; i++) ...[
                            GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: AppColors.generalWhite,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 16,
                                ),
                                margin: i == 0
                                    ? const EdgeInsets.fromLTRB(16, 0, 4, 0)
                                    : const EdgeInsets.only(right: 4),
                                child: Text(
                                  phoneNumbers[i],
                                  style: Typography.body2.merge(const TextStyle(
                                    color: AppColors.generalBlack,
                                  )),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onTap: () => _launchPhone(phoneNumbers[i]),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 4,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Валюта',
                              style: Typography.body2,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: const Text(
                                    'Покупка',
                                    style: Typography.body2,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: const Text(
                                    'Продажа',
                                    style: Typography.body2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ...getCurrencyRows(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
