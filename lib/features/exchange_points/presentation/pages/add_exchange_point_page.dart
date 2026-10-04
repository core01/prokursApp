import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/exceptions/api_exception.dart';
import 'package:prokurs/core/exceptions/session_expired_exception.dart';
import 'package:prokurs/core/widgets/inline_notice.dart';
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

  /// The edited point as the server has it now; null when adding a new point.
  ExchangePoint? _original;

  /// Why the last save didn't go through, shown above the save button.
  String? _saveError;
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

  // One controller per phone field
  final List<TextEditingController> _phoneControllers = [
    TextEditingController()
  ];

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
    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final citiesProvider = context.read<CitiesProvider>();
      final cities = await citiesProvider.fetchCities();

      // PUT replaces every field, so editing must start from the server's current copy, not
      // from the list loaded earlier: stale values would overwrite changes made on the website.
      final editedPoint = widget.exchangePoint;
      final original = editedPoint == null
          ? null
          : await _exchangePointsService.getMyExchangePoint(editedPoint.id);

      setState(() {
        _cities = cities;
        _original = original;

        if (_cities.isNotEmpty) {
          // For a new exchange point, set the first city as default
          if (widget.exchangePoint == null) {
            _form = _form.copyWith(
              city: CityInput.dirty(_cities.first.id),
            );
          } else {
            // For editing, populate the form with exchange point data
            _populateFormFields(original!);
          }
        }
      });
    } on SessionExpiredException {
      // The app is on its way to the sign-in screen, which explains it.
    } catch (e) {
      debugPrint("Error loading exchange point form: $e");
      if (widget.exchangePoint != null && mounted) {
        await _showLoadErrorAndClose();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showLoadErrorAndClose() async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Ошибка'),
        content: const Text('Не удалось загрузить обменный пункт'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _populateFormFields(ExchangePoint point) {
    setState(() {
      // Initialize form with exchange point data
      _form = ExchangePointForm.fromExchangePoint(point);

      for (final controller in _phoneControllers) {
        controller.dispose();
      }
      _phoneControllers
        ..clear()
        ..addAll(_form.phones.value
            .map((phone) => TextEditingController(text: phone)));

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

  // The phone fields own their text; the form mirrors it.
  void _syncPhones() {
    _form = _form.copyWith(
      phones: PhonesInput.dirty(
          _phoneControllers.map((controller) => controller.text).toList()),
    );
  }

  void _onPhoneChanged(String _) => setState(_syncPhones);

  void _addPhone() {
    setState(() {
      _phoneControllers.add(TextEditingController());
      _syncPhones();
    });
  }

  void _removePhone(int index) {
    setState(() {
      _phoneControllers.removeAt(index).dispose();
      _syncPhones();
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
      _saveError = null;
    });

    final formValid = _formKey.currentState?.validate() ?? false;

    if (!formValid || !updatedForm.isValid) {
      final summary = updatedForm.errorSummary();
      setState(() {
        _saveError = summary.isEmpty
            ? 'Проверьте заполнение формы'
            : 'Исправьте:\n${summary.join('\n')}';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.exchangePoint != null) {
        final original = _original!;
        await _exchangePointsService.updateExchangePoint(
            original.id, _form.toReplaceInput(original));
      } else {
        await _exchangePointsService
            .createExchangePoint(_form.toCreateInput());
      }

      if (mounted) {
        // Any non-null result tells the list page to reload.
        Navigator.of(context).pop(true);
      }
    } on SessionExpiredException {
      // The app is on its way to the sign-in screen, which explains it.
    } catch (e) {
      if (mounted) {
        setState(() {
          // ApiException texts are localized; anything else is not meant for the user.
          _saveError =
              e is ApiException ? e.toString() : 'Не удалось сохранить обменный пункт';
        });
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
          color: AppColors.background.resolveFrom(context),
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
                      style: AppTypography.body,
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
    final secondaryLabel = AppColors.secondaryLabel.resolveFrom(context);
    final sectionHeaderStyle = AppTypography.footnote.copyWith(color: secondaryLabel);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        middle: Text(
          isEditing
              ? "Редактирование обменного пункта"
              : "Добавить обменный пункт",
          style: AppTypography.headline,
        ),
        leading: GestureDetector(
          child: Icon(
            CupertinoIcons.back,
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
                      header: Text('ОСНОВНАЯ ИНФОРМАЦИЯ', style: sectionHeaderStyle),
                      children: [
                        // City Selection
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 10),
                                child: Text('Город', style: AppTypography.body),
                                ),
                                const Spacer(),
                              GestureDetector(
                                onTap: () => _showCityPicker(context),
                                child: Row(
                                  children: [
                                    Text(
                                      cityTitle,
                                      style: _form.city.value == null
                                          ? AppTypography.body.copyWith(color: secondaryLabel)
                                          : AppTypography.body,
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(CupertinoIcons.chevron_right, color: secondaryLabel, size: 18),
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
                                      style: AppTypography.body,
                                    ))
                              ]),
                          placeholder: "Введите название",
                          placeholderStyle: AppTypography.body.copyWith(
                            color: AppColors.secondaryLabel,
                          ),
                          style: AppTypography.body,
                          onChanged: _onNameChanged,
                          initialValue: _form.name.value,
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
                              style: AppTypography.body,
                            ),
                          ),
                          placeholder: "Введите адрес",
                          placeholderStyle: AppTypography.body.copyWith(
                            color: AppColors.secondaryLabel,
                          ),
                          style: AppTypography.body,
                          maxLines: null,
                          onChanged: _onAddressChanged,
                          initialValue: _form.info.value,
                        ),

                        // Phone Fields: one per number
                        for (var i = 0; i < _phoneControllers.length; i++)
                          _buildPhoneRow(i),

                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          alignment: Alignment.centerLeft,
                          onPressed: _addPhone,
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.add_circled, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Добавить номер',
                                style: AppTypography.body,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    CupertinoFormSection.insetGrouped(
                      header: Text('ТИП ОБМЕНА', style: sectionHeaderStyle),
                        children: [
                          Row(children: [
                            Expanded(
                              child: CupertinoSlidingSegmentedControl<bool>(
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
                      header: Text('КУРСЫ ВАЛЮТ', style: sectionHeaderStyle),
                      children: [
                        _buildStyledCurrencyRow(
                          USD,
                          _form.buyUSD,
                          _form.sellUSD,
                        ),
                        _buildStyledCurrencyRow(
                          EUR,
                          _form.buyEUR,
                          _form.sellEUR,
                        ),
                        _buildStyledCurrencyRow(
                          RUR,
                          _form.buyRUB,
                          _form.sellRUB,
                        ),
                        _buildStyledCurrencyRow(
                          CNY,
                          _form.buyCNY,
                          _form.sellCNY,
                        ),
                        _buildStyledCurrencyRow(
                          GBP,
                          _form.buyGBP,
                          _form.sellGBP,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Why the last save failed: next to the button the user just pressed.
                    if (_saveError != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: InlineNotice(text: _saveError!),
                      ),

                    // Save button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CupertinoButton.filled(
                        onPressed: _submitForm,
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

  Widget _buildPhoneRow(int index) {
    return Row(
      // Keeps each field's state with its controller when a row above is removed
      key: ObjectKey(_phoneControllers[index]),
      children: [
        Expanded(
          child: CupertinoTextFormFieldRow(
            padding: _formFieldPadding,
            validator: (_) => ExchangePointFormValidation.phoneError(_form, index),
            prefix: Padding(
              padding: EdgeInsets.only(right: 12),
              child: Text(
                'Телефон',
                style: AppTypography.body,
              ),
            ),
            placeholder: "+7 701 123 4567",
            placeholderStyle: AppTypography.body.copyWith(
              color: AppColors.secondaryLabel,
            ),
            keyboardType: TextInputType.phone,
            style: AppTypography.body,
            onChanged: _onPhoneChanged,
            controller: _phoneControllers[index],
          ),
        ),
        if (_phoneControllers.length > 1)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            onPressed: () => _removePhone(index),
            child: Icon(
              CupertinoIcons.minus_circle,
              color: AppColors.destructive.resolveFrom(context),
              size: 20,
            ),
          ),
      ],
    );
  }

  // Enhanced currency row with modern styling
  Widget _buildStyledCurrencyRow(
    CurrencyItem currency,
    String buyValue,
    String sellValue,
  ) {
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

    // Invalid values can only come from the server (rateInputFormatter stops typing them), so
    // they are pointed out as soon as the form opens, not only after "Сохранить".
    final buyError = ExchangePointFormValidation.rateError(buyValue);
    final sellError = ExchangePointFormValidation.rateError(sellValue);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          child: Row(
            children: [
              // Currency icon
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  currency.icon,
                  style: AppTypography.title2,
                ),
              ),

              // Currency code/name
              SizedBox(
                width: 60,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    currency.id,
                    style: AppTypography.body,
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
                      color: (buyError == null ? AppColors.inputBorder : AppColors.error)
                          .resolveFrom(context),
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.background.resolveFrom(context),
                  ),
                  child: Row(
                    children: [
                      // Buy indicator
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: AppColors.buy.resolveFrom(context),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(7),
                            bottomLeft: Radius.circular(7),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          placeholder: "Покупка",
                          placeholderStyle: AppTypography.body.copyWith(color: AppColors.secondaryLabel),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [rateInputFormatter],
                          textAlign: TextAlign.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          style: AppTypography.body,
                          onChanged: (value) => _onRateChanged(value,
                              currency: currency.id, isBuy: true),
                          decoration:
                              null, // No decoration as we're using the parent container
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
                      color: (sellError == null ? AppColors.inputBorder : AppColors.error)
                          .resolveFrom(context),
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.background.resolveFrom(context),
                  ),
                  child: Row(
                    children: [
                      // Sell indicator
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: AppColors.sell.resolveFrom(context),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(7),
                            bottomLeft: Radius.circular(7),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          placeholder: "Продажа",
                          placeholderStyle: AppTypography.body.copyWith(color: AppColors.secondaryLabel),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [rateInputFormatter],
                          textAlign: TextAlign.center,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          style: AppTypography.body,
                          onChanged: (value) => _onRateChanged(value,
                              currency: currency.id, isBuy: false),
                          decoration:
                              null, // No decoration as we're using the parent container
                          controller: sellController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final error in [
          if (buyError != null) 'Покупка: $buyError',
          if (sellError != null) 'Продажа: $sellError',
        ])
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 20, 8),
            child: Text(
              error,
              style: AppTypography.footnote.copyWith(
                color: AppColors.error.resolveFrom(context),
              ),
            ),
          ),
      ],
    );
  }
}
