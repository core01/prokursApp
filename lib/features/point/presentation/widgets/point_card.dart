import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/utils/utils.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/rates/presentation/widgets/wholesale_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

// Not the API client: the logo is on a foreign host and must not get the API's bearer token.
final _logoDio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  responseType: ResponseType.bytes,
));

Future<BitmapDescriptor> getBitmapDescriptorFromUrl(String imageUrl) async {
  final response = await _logoDio.get<List<int>>(imageUrl);
  final Uint8List bytes = Uint8List.fromList(response.data!);

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
  // Maps the app can hand a point over to. Keep in sync with
  // LSApplicationQueriesSchemes (Info.plist) and <queries> (AndroidManifest.xml);
  // only the maps listed here are compiled into the binary.
  static const List<MapApp> _supportedMaps = [
    MapApp.apple,
    MapApp.google,
    MapApp.yandexMaps,
    MapApp.yandexNavi,
    MapApp.doubleGis,
  ];

  bool _isLoading = true;
  List phoneNumbers = [];
  BitmapDescriptor? bitmapDescriptor;

  // Close enough to see the streets around the point.
  static const _mapZoom = 16.0;

  // toDouble: the API sends a whole coordinate as an int, which `as double` would reject.
  Point get _location => Point(
        latitude: widget.point.latitude!.toDouble(),
        longitude: widget.point.longitude!.toDouble(),
      );

  /// Points the map at the exchange point. The plugin calls onMapCreated once the map's view
  /// has a size, but MapKit gets its drawing surface a moment later and rejects camera moves
  /// until then (moveCamera returns false). So the move is repeated each frame until the map
  /// accepts it.
  Future<void> _showPoint(YandexMapController map) async {
    final camera = CameraUpdate.newCameraPosition(
      CameraPosition(target: _location, zoom: _mapZoom),
    );
    while (mounted && !await map.moveCamera(camera)) {
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  // Once: didChangeDependencies runs again on every theme or text size change, which added
  // the phones over and over and downloaded the logo again.
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.point.hasLogo) {
      try {
        bitmapDescriptor = await getBitmapDescriptorFromUrl(widget.point.logo!);
      } catch (e) {
        // The card is shown without the logo.
        debugPrint('Error loading logo: $e');
      }
    }

    for (var phone in widget.point.phones) {
      phoneNumbers.add(phone);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool hasPointCurrencyBuyValue(String currencyId) {
    return widget.point.get('$buyPrefix$currencyId') != 0;
  }

  bool hasPointCurrencySellValue(String currencyId) {
    return widget.point.get('$sellPrefix$currencyId') != 0;
  }

  String getPointCurrencyBuyValue(String currencyId) {
    return getPointCurrencyRateStringFormatted(
        widget.point, '$buyPrefix$currencyId');
  }

  String getPointCurrencySellValue(String currencyId) {
    return getPointCurrencyRateStringFormatted(
        widget.point, '$sellPrefix$currencyId');
  }

  void _launchPhone(String phone) async {
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

    final MarkerRequest marker = MapLauncher.marker(
      LocationCoords(latitude, longitude, title: widget.point.name),
    );
    List<SupportedMap> installedMaps = const [];

    try {
      final List<SupportedMap> supportedMaps = await marker.getSupportedMaps(_supportedMaps);
      installedMaps = supportedMaps.where((map) => map.isInstalled).toList();
    } catch (error) {
      debugPrint('Error fetching installed maps: $error');
    }

    final List<({String name, Future<void> Function() open})> mapOptions = [
      for (final map in installedMaps)
        (
          name: map.name,
          open: () async {
            try {
              await map.show();
            } catch (error) {
              debugPrint('Failed to open ${map.name}: $error');
            }
          },
        ),
    ];

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

  List<Widget> getCurrencyRows(BuildContext context) {
    List<Widget> rows = [];

    for (var i = 0; i < currencyList.length; i++) {
      var currency = currencyList[i];
      if (canRenderCurrencyRow(getPointCurrencyBuyValue(currency.id),
          getPointCurrencySellValue(currency.id))) {
        rows.add(Container(
          decoration: BoxDecoration(
            border: i != currencyList.length - 1
                  ? Border(top: BorderSide(
                      width: AppStroke.hairline,
                      color: AppColors.separator.resolveFrom(context),
                    ),
                  )
                  : Border(),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Flexible(
                  flex: 4,
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Text(
                    "${currency.icon} ${currency.unicode} ${currency.label}",
                    style: AppTypography.body,
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
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        // A number can't wrap: with large Dynamic Type it shrinks instead.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getPointCurrencyBuyValue(currency.id),
                                style: AppTypography.body,
                                softWrap: false,
                              ),
                              if (hasPointCurrencyBuyValue(currency.id)) ...[
                                // Tenge sign
                                const Text('\u{20B8}',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.body),
                              ]
                            ]),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(left: AppSpacing.xs),
                        // A number can't wrap: with large Dynamic Type it shrinks instead.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getPointCurrencySellValue(currency.id),
                                style: AppTypography.body,
                                softWrap: false,
                              ),
                              if (hasPointCurrencySellValue(currency.id)) ...[
                                // Tenge sign
                                const Text('\u{20B8}',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.body),
                              ]
                            ]),
                        ),
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

    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
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
                      // A still preview: no gesture moves the camera.
                      child: YandexMap(
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        onMapCreated: _showPoint,
                        mapObjects: [
                          PlacemarkMapObject(
                            mapId: mapObjectId,
                            point: _location,
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
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        borderRadius: AppRadius.card,
                        onPressed: _openInMaps,
                        child: const Text(
                          'Открыть в картах',
                          style: AppTypography.subheadline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              color: AppColors.background.resolveFrom(context),
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.point.info != null) ...[
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
                        child: Text(
                          widget.point.info as String,
                          style: AppTypography.body,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                    if (widget.point.gross > 0)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          widget.point.info == null ? AppSpacing.md : 0,
                          AppSpacing.md,
                          AppSpacing.sm,
                        ),
                        child: WholesaleNotice(note: widget.point.wholesaleNote),
                      ),
                    Container(
                      padding: const EdgeInsets.only(left: AppSpacing.md),
                      child: Text(
                        "Телефоны:",
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondaryLabel.resolveFrom(context),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Row(
                        children: [
                          for (final phone in phoneNumbers)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                              // A pill, with the full 44-pt touch target around it.
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => _launchPhone(phone),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: AppRadius.capsule,
                                    color: AppColors.surface.resolveFrom(context),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.xxs,
                                      horizontal: AppSpacing.md,
                                    ),
                                    child: Text(phone),
                                  ),
                                ),
                              ),
                            ),
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
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 4,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Валюта',
                              style: AppTypography.body,
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
                                  margin: const EdgeInsets.only(right: AppSpacing.xs),
                                  child: const Text(
                                    'Покупка',
                                    style: AppTypography.body,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: const Text(
                                    'Продажа',
                                    style: AppTypography.body,
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
