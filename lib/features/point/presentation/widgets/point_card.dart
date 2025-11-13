import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/exchange_point/domain/models/exchange_point.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

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

  getCurrencyRows() {
    List<Widget> rows = [];

    for (var i = 0; i < CURRENCY_LIST.length; i++) {
      var currency = CURRENCY_LIST[i];
      if (canRenderCurrencyRow(getPointCurrencyBuyValue(currency.id),
          getPointCurrencySellValue(currency.id))) {
        rows.add(Container(
          decoration: BoxDecoration(
            border: i != CURRENCY_LIST.length - 1
                ? const Border(
                    bottom: BorderSide(
                      width: 1,
                      color: DarkTheme.lightDivider,
                    ),
                  )
                : const Border(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Flexible(
                flex: 1,
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
                flex: 1,
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
                                    style: Typography.body3),
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
                                    style: Typography.body3),
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
        widget.point.latitude != null && widget.point.latitude != null;

    if (_isLoading) {
      return const Center(
        child: Stack(
          children: [
            Positioned(
              top: 15.0,
              bottom: 15.0,
              left: 0.0,
              right: 0.0,
              child: CupertinoActivityIndicator(
                color: DarkTheme.mainBlack,
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
                child: YandexMap(
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  onMapCreated:
                      (YandexMapController yandexMapController) async {
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
                              : BitmapDescriptor.fromAssetImage(
                                  'assets/images/pin.png',
                                ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
            Container(
              color: DarkTheme.lightBg,
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
                          color: DarkTheme.lightSecondary,
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
                                  color: DarkTheme.generalWhite,
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
                                    color: DarkTheme.generalBlack,
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
                          flex: 5,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Валюта',
                              style: Typography.body3,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: const Text(
                                    'Покупка',
                                    style: Typography.body3,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: const Text(
                                    'Продажа',
                                    style: Typography.body3,
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
                        ...getCurrencyRows(),
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
