import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/features/exchange_points/data/providers/cities_provider.dart';
import 'package:prokurs/features/exchange_points/data/services/exchange_points_service.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/exchange_points/presentation/forms/exchange_point_form.dart';
import 'package:prokurs/features/exchange_points/presentation/forms/form_inputs.dart';
import 'package:provider/provider.dart';

class AddExchangePointPage extends StatefulWidget {
  static const routeName = '/add-exchange-point';

  final ExchangePoint? exchangePoint;

  const AddExchangePointPage({
    super.key,
    this.exchangePoint,
  });

  @override
  _AddExchangePointPageState createState() => _AddExchangePointPageState();
}

class _AddExchangePointPageState extends State<AddExchangePointPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<City> _cities = [];
  ExchangePointForm _form = ExchangePointForm();
  final ExchangePointsService _exchangePointsService = ExchangePointsService();

  static const EdgeInsetsDirectional _formFieldPadding = EdgeInsetsDirectional.fromSTEB(28.0, 6.0, 6.0, 6.0);

  // Currency controllers
  final _buyUSDController = TextEditingController();
  final _sellUSDController = TextEditingController();
  final _buyEURController = TextEditingController();
  final _sellEURController = TextEditingController();
  final _buyRUBController = TextEditingController();
  final _sellRUBController = TextEditingController();
  final _buyCNYController = TextEditingController();
  final _sellCNYController = TextEditingController();
  final _buyGBPController = TextEditingController();
  final _sellGBPController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    // Dispose currency controllers
    _buyUSDController.dispose();
    _sellUSDController.dispose();
    _buyEURController.dispose();
    _sellEURController.dispose();
    _buyRUBController.dispose();
    _sellRUBController.dispose();
    _buyCNYController.dispose();
    _sellCNYController.dispose();
    _buyGBPController.dispose();
    _sellGBPController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final citiesProvider = context.read<CitiesProvider>();
      final cities = await citiesProvider.fetchCities();

      setState(() {
        _cities = cities;

        if (_cities.isNotEmpty) {
          // For a new exchange point, set the first city as default
          if (widget.exchangePoint == null) {
            _form = _form.copyWith(
              city: CityInput.dirty(_cities.first.id),
            );
          } else {
            // For editing, populate the form with exchange point data
            _populateFormFields();
          }
        }
      });
    } catch (e) {
      debugPrint("Error loading cities: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFormFields() {
    final point = widget.exchangePoint!;
    debugPrint('===== Exchange point data =====');
    debugPrint('Name: ${point.name}');
    debugPrint('City ID: ${point.city_id}');
    debugPrint('Info: ${point.info}');
    debugPrint('Phones: ${point.phones}');
    debugPrint('Gross: ${point.gross}');
    debugPrint('USD: Buy=${point.buyUSD}, Sell=${point.sellUSD}');
    debugPrint('EUR: Buy=${point.buyEUR}, Sell=${point.sellEUR}');
    debugPrint('RUB: Buy=${point.buyRUB}, Sell=${point.sellRUB}');
    debugPrint('CNY: Buy=${point.buyCNY}, Sell=${point.sellCNY}');
    debugPrint('GBP: Buy=${point.buyGBP}, Sell=${point.sellGBP}');
    debugPrint('===============================');

    setState(() {
      // Initialize form with exchange point data
      _form = ExchangePointForm.fromExchangePoint(point);

      // Update currency controllers
      _buyUSDController.text = point.buyUSD != 0 ? point.buyUSD.toString() : '';
      _sellUSDController.text =
          point.sellUSD != 0 ? point.sellUSD.toString() : '';
      _buyEURController.text = point.buyEUR != 0 ? point.buyEUR.toString() : '';
      _sellEURController.text =
          point.sellEUR != 0 ? point.sellEUR.toString() : '';
      _buyRUBController.text = point.buyRUB != 0 ? point.buyRUB.toString() : '';
      _sellRUBController.text =
          point.sellRUB != 0 ? point.sellRUB.toString() : '';
      _buyCNYController.text = point.buyCNY != 0 ? point.buyCNY.toString() : '';
      _sellCNYController.text =
          point.sellCNY != 0 ? point.sellCNY.toString() : '';
      _buyGBPController.text = point.buyGBP != 0 ? point.buyGBP.toString() : '';
      _sellGBPController.text =
          point.sellGBP != 0 ? point.sellGBP.toString() : '';
    });

    // Debug log the form data after setting it
    debugPrint('===== Form data after setting =====');
    debugPrint('Name: ${_form.name.value}');
    debugPrint('City: ${_form.city.value}');
    debugPrint('Info: ${_form.info.value}');
    debugPrint('Phones: ${_form.phones.value}');
    debugPrint('Gross: ${_form.gross}');
    debugPrint('USD: Buy=${_form.buyUSD}, Sell=${_form.sellUSD}');
    debugPrint('EUR: Buy=${_form.buyEUR}, Sell=${_form.sellEUR}');
    debugPrint('RUB: Buy=${_form.buyRUB}, Sell=${_form.sellRUB}');
    debugPrint('CNY: Buy=${_form.buyCNY}, Sell=${_form.sellCNY}');
    debugPrint('GBP: Buy=${_form.buyGBP}, Sell=${_form.sellGBP}');
    debugPrint('==================================');
  }

  void _onNameChanged(String value) {
    setState(() {
      _form = _form.copyWith(name: NameInput.dirty(value));
    });
  }

  void _onAddressChanged(String value) {
    setState(() {
      _form = _form.copyWith(info: InfoInput.dirty(value));
    });
  }

  void _onPhoneChanged(String value) {
    setState(() {
      _form = _form.copyWith(phones: PhonesInput.dirty(value));
    });
  }

  void _onRateChanged(String value,
      {required String currency, required bool isBuy}) {
    setState(() {
      final sanitizedValue = value.isEmpty ? value : value.replaceAll(',', '.');
      switch (currency) {
        case 'USD':
          if (isBuy) {
            _form = _form.copyWith(buyUSD: sanitizedValue);
          } else {
            _form = _form.copyWith(sellUSD: sanitizedValue);
          }
          break;
        case 'EUR':
          if (isBuy) {
            _form = _form.copyWith(buyEUR: sanitizedValue);
          } else {
            _form = _form.copyWith(sellEUR: sanitizedValue);
          }
          break;
        case 'RUB':
          if (isBuy) {
            _form = _form.copyWith(buyRUB: sanitizedValue);
          } else {
            _form = _form.copyWith(sellRUB: sanitizedValue);
          }
          break;
        case 'CNY':
          if (isBuy) {
            _form = _form.copyWith(buyCNY: sanitizedValue);
          } else {
            _form = _form.copyWith(sellCNY: sanitizedValue);
          }
          break;
        case 'GBP':
          if (isBuy) {
            _form = _form.copyWith(buyGBP: sanitizedValue);
          } else {
            _form = _form.copyWith(sellGBP: sanitizedValue);
          }
          break;
      }
    });
  }

  // Toggle between retail and wholesale
  void _toggleRetailWholesale(bool value) {
    setState(() {
      // Update form if needed
      _form = _form.copyWith(
        gross: value ? 1 : 0,
      );
    });
  }

  Future<void> _submitForm() async {
    final updatedForm = ExchangePointFormValidation.touchRequiredFields(_form).markSubmitted();

    setState(() {
      _form = updatedForm;
    });

    final formValid = _formKey.currentState?.validate() ?? false;
    debugPrint('form validation: ${updatedForm.isValid}');

    if (!formValid || !updatedForm.isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final exchangePointData = _form.toJson();
      if (widget.exchangePoint?.id != null) {
        await _exchangePointsService.updateExchangePoint(
            widget.exchangePoint!.id, exchangePointData);
      } else {
        await _exchangePointsService.createExchangePoint(exchangePointData);
      }

      if (mounted) {
        Navigator.of(context).pop(exchangePointData);
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Ошибка'),
            content: Text('Не удалось сохранить обменный пункт: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCityPicker(BuildContext context) {
    int selectedIndex = 0;
    if (_form.city.value != null) {
      selectedIndex = _cities.indexWhere((city) => city.id == _form.city.value);
      if (selectedIndex < 0) selectedIndex = 0;
    }

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: DarkTheme.lightBg,
          child: SafeArea(
            top: false,
            child: CupertinoPicker(
              magnification: 1.22,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 30,
              scrollController: FixedExtentScrollController(
                initialItem: selectedIndex,
              ),
              onSelectedItemChanged: (int index) {
                selectedIndex = index;
                setState(() {
                  _form =
                      _form.copyWith(city: CityInput.dirty(_cities[index].id));
                });
              },
              children: _cities.map((City city) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      city.title,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exchangePoint != null;

    // Find the currently selected city to display in the UI
    String cityTitle = "Выберите город";
    if (_form.city.value != null) {
      final cityIndex =
          _cities.indexWhere((city) => city.id == _form.city.value);
      if (cityIndex >= 0) {
        cityTitle = _cities[cityIndex].title;
      }
    }

    return CupertinoPageScaffold(
      backgroundColor: DarkTheme.lightBg,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          isEditing
              ? "Редактировать обменный пункт"
              : "Добавить обменный пункт",
          style: Typography.heading2,
        ),
        leading: GestureDetector(
          child: const Icon(
            CupertinoIcons.back,
            color: DarkTheme.generalBlack,
            size: 24.0,
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : Form(
                key: _formKey,
                autovalidateMode: _form.isSubmitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: ListView(
                  children: [
                    const SizedBox(height: 16),
                    // Basic Info Section
                    CupertinoFormSection.insetGrouped(
                      backgroundColor: DarkTheme.lightBg,
                      header: const Text('ОСНОВНАЯ ИНФОРМАЦИЯ', style: Typography.heading2),
                      children: [
                        // City Selection
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 10),
                                child: Text('Город', style: Typography.body2),
                                ),
                                const Spacer(),
                              GestureDetector(
                                onTap: () => _showCityPicker(context),
                                child: Row(
                                  children: [
                                    Text(
                                      cityTitle,
                                      style: _form.city.value == null
                                          ? Typography.body2.copyWith(color: DarkTheme.darkSecondary)
                                          : Typography.body2,
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(CupertinoIcons.chevron_right, color: DarkTheme.darkSecondary, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Name Field
                        CupertinoTextFormFieldRow(
                          padding: _formFieldPadding,
                          validator: (_) => ExchangePointFormValidation.nameError(_form),
                          prefix: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Text(
                                      'Название',
                                      style: Typography.body2,
                                    ))
                              ]),
                          placeholder: "Введите название",
                          placeholderStyle: Typography.body2.copyWith(
                            color: DarkTheme.lightSecondary,
                          ),
                          style: Typography.body2,
                          onChanged: _onNameChanged,
                          initialValue: _form.name.value,
                          cursorColor: DarkTheme.darkSecondary,
                          maxLines: null,
                        ),

                        // Address Field
                        CupertinoTextFormFieldRow(
                          padding: _formFieldPadding,
                          validator: (_) => ExchangePointFormValidation.addressError(_form),
                          prefix: Padding(
                            padding: EdgeInsets.only(right: 32),
                            child: Text(
                              'Адрес',
                              style: Typography.body2,
                            ),
                          ),
                          placeholder: "Введите адрес",
                          placeholderStyle: Typography.body2.copyWith(
                            color: DarkTheme.lightSecondary,
                          ),
                          style: Typography.body2,
                          maxLines: null,
                          onChanged: _onAddressChanged,
                          initialValue: _form.info.value,
                          cursorColor: DarkTheme.darkSecondary,
                        ),

                        // Phone Field
                        CupertinoTextFormFieldRow(
                          padding: _formFieldPadding,
                          validator: (_) => ExchangePointFormValidation.phonesError(_form),
                          prefix: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Text(
                              'Телефон',
                              style: Typography.body2,
                            ),
                          ),
                          placeholder: "Номера телефонов через запятую",
                          placeholderStyle: Typography.body2.copyWith(
                            color: DarkTheme.lightSecondary,
                          ),
                          maxLines: null,
                          style: Typography.body2,
                          onChanged: _onPhoneChanged,
                          initialValue: _form.phones.value,
                          cursorColor: DarkTheme.darkSecondary,
                        ),
                      ],
                    ),
                    CupertinoFormSection.insetGrouped(
                        backgroundColor: DarkTheme.lightBg,
                      header: Text('ТИП ОБМЕНА', style: Typography.heading2),
                        children: [
                          Row(children: [
                            Expanded(
                              child: CupertinoSlidingSegmentedControl<bool>(
                                // backgroundColor: CupertinoColors.black,
                                thumbColor: DarkTheme.generalWhite,
                                groupValue: _form.gross > 0,
                                onValueChanged: (bool? value) {
                                  if (value != null) {
                                    _toggleRetailWholesale(value);
                                  }
                                },
                                children: const {
                                  false: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text('Розница'),
                                  ),
                                  true: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text('Опт'),
                                  ),
                                },
                              ),
                            ),
                          ]),
                        ]),
                    // Currency Rates Section
                    CupertinoFormSection.insetGrouped(
                      backgroundColor: DarkTheme.lightBg,
                      header: const Text('КУРСЫ ВАЛЮТ', style: Typography.heading2),
                      children: [
                        _buildStyledCurrencyRow(
                            USD, _form.buyUSD, _form.sellUSD),
                        _buildStyledCurrencyRow(
                            EUR, _form.buyEUR, _form.sellEUR),
                        _buildStyledCurrencyRow(
                            RUR, _form.buyRUB, _form.sellRUB),
                        _buildStyledCurrencyRow(
                            CNY, _form.buyCNY, _form.sellCNY),
                        _buildStyledCurrencyRow(
                            GBP, _form.buyGBP, _form.sellGBP),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Save button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CupertinoButton(
                        onPressed: _submitForm,
                        color: DarkTheme.generalBlack,
                        child: Text(
                          isEditing ? "Сохранить" : "Добавить",
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  // Enhanced currency row with modern styling
  Widget _buildStyledCurrencyRow(
      CurrencyItem currency, String buyValue, String sellValue) {
    // Get the appropriate controllers based on currency
    TextEditingController buyController;
    TextEditingController sellController;

    switch (currency.id) {
      case 'USD':
        buyController = _buyUSDController;
        sellController = _sellUSDController;
        break;
      case 'EUR':
        buyController = _buyEURController;
        sellController = _sellEURController;
        break;
      case 'RUB':
        buyController = _buyRUBController;
        sellController = _sellRUBController;
        break;
      case 'CNY':
        buyController = _buyCNYController;
        sellController = _sellCNYController;
        break;
      case 'GBP':
        buyController = _buyGBPController;
        sellController = _sellGBPController;
        break;
      default:
        buyController = TextEditingController(text: buyValue);
        sellController = TextEditingController(text: sellValue);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      child: Row(
        children: [
          // Currency icon
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              currency.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),

          // Currency code/name
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                currency.id,
                style: Typography.body2,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Buy field with improved styling
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                  width: 0.8,
                ),
                borderRadius: BorderRadius.circular(8),
                color: CupertinoColors.systemBackground,
              ),
              child: Row(
                children: [
                  // Buy indicator
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.generalGreen, // Green for buy
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(7),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      placeholder: "Покупка",
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      style: Typography.body2,
                      onChanged: (value) => _onRateChanged(value,
                          currency: currency.id, isBuy: true),
                      decoration:
                          null, // No decoration as we're using the parent container
                      cursorColor: DarkTheme.darkSecondary,
                      controller: buyController,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Sell field with improved styling
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                  width: 0.8,
                ),
                borderRadius: BorderRadius.circular(8),
                color: CupertinoColors.systemBackground,
              ),
              child: Row(
                children: [
                  // Sell indicator
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.generalRed, // Red for sell
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(7),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoTextField(
                      placeholder: "Продажа",
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      style: Typography.body2,
                      onChanged: (value) => _onRateChanged(value,
                          currency: currency.id, isBuy: false),
                      decoration:
                          null, // No decoration as we're using the parent container
                      cursorColor: DarkTheme.darkSecondary,
                      controller: sellController,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
