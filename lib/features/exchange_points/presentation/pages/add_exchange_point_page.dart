import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/constants/app_constants.dart';
import 'package:prokurs/core/theme/app_theme.dart';
import 'package:prokurs/core/exceptions/api_exception.dart';
import 'package:prokurs/core/exceptions/session_expired_exception.dart';
import 'package:prokurs/core/widgets/inline_notice.dart';
import 'package:prokurs/core/widgets/list_tile_value.dart';
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
  bool _isLoading = false;
  List<City> _cities = [];
  ExchangePointForm _form = ExchangePointForm();

  /// The edited point as the server has it now; null when adding a new point.
  ExchangePoint? _original;

  /// Why the last save didn't go through, shown above the save button.
  String? _saveError;
  final ExchangePointsService _exchangePointsService = ExchangePointsService();

  // Field labels share one column, so the fields line up.
  static const _labelWidth = 96.0;
  static const _currencyCodeWidth = 48.0;

  // A text field 44 pt tall at the default text size, like a list row: the body line is 22 pt.
  static const _fieldVerticalPadding = (kMinInteractiveDimensionCupertino - 22) / 2;

  // UIPickerView's row height.
  static const _pickerItemExtent = 32.0;

  final _nameController = TextEditingController();
  final _infoController = TextEditingController();

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
    _nameController.dispose();
    _infoController.dispose();
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
      _nameController.text = _form.name.value;
      _infoController.text = _form.info.value;

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

    if (!updatedForm.isValid) {
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
          padding: const EdgeInsets.only(top: AppSpacing.xs),
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
              itemExtent: MediaQuery.textScalerOf(context).scale(_pickerItemExtent),
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
        middle: Text(isEditing ? "Редактирование" : "Новый пункт"),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                children: [
                  CupertinoFormSection.insetGrouped(
                    margin: sectionMargin,
                    header: Text('ОСНОВНАЯ ИНФОРМАЦИЯ', style: sectionHeaderStyle),
                    children: [
                      CupertinoListTile(
                        title: const Text('Город'),
                        additionalInfo: ListTileValue(cityTitle),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () => _showCityPicker(context),
                      ),
                      _fieldRow(
                        label: 'Название',
                        error: ExchangePointFormValidation.nameError(_form),
                        field: _textField(
                          controller: _nameController,
                          placeholder: "Введите название",
                          onChanged: _onNameChanged,
                          maxLines: null,
                        ),
                      ),
                      _fieldRow(
                        label: 'Адрес',
                        error: ExchangePointFormValidation.addressError(_form),
                        field: _textField(
                          controller: _infoController,
                          placeholder: "Введите адрес",
                          onChanged: _onAddressChanged,
                          maxLines: null,
                        ),
                      ),

                      // Phone Fields: one per number
                      for (var i = 0; i < _phoneControllers.length; i++)
                        _buildPhoneRow(i),

                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.add_circled),
                        title: const Text('Добавить номер'),
                        onTap: _addPhone,
                      ),
                    ],
                  ),
                  CupertinoFormSection.insetGrouped(
                    margin: sectionMargin,
                    header: Text('ТИП ОБМЕНА', style: sectionHeaderStyle),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<bool>(
                            groupValue: _form.gross > 0,
                            onValueChanged: (bool? value) {
                              if (value != null) {
                                _toggleRetailWholesale(value);
                              }
                            },
                            children: const {
                              false: Text('Розница'),
                              true: Text('Опт'),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  CupertinoFormSection.insetGrouped(
                    margin: sectionMargin,
                    header: Text('КУРСЫ ВАЛЮТ', style: sectionHeaderStyle),
                    children: [
                      _buildStyledCurrencyRow(USD, _form.buyUSD, _form.sellUSD),
                      _buildStyledCurrencyRow(EUR, _form.buyEUR, _form.sellEUR),
                      _buildStyledCurrencyRow(RUR, _form.buyRUB, _form.sellRUB),
                      _buildStyledCurrencyRow(CNY, _form.buyCNY, _form.sellCNY),
                      _buildStyledCurrencyRow(GBP, _form.buyGBP, _form.sellGBP),
                    ],
                  ),

                  // Why the last save failed: next to the button the user just pressed.
                  if (_saveError != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                      child: InlineNotice(text: _saveError!),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: CupertinoButton.filled(
                      borderRadius: AppRadius.card,
                      onPressed: _submitForm,
                      child: Text(
                        isEditing ? "Сохранить" : "Добавить",
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// A labelled field in a form section; the error, if any, below it.
  Widget _fieldRow({required String label, String? error, required Widget field}) {
    return CupertinoFormRow(
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg, end: AppSpacing.xs),
      prefix: SizedBox(width: _labelWidth, child: Text(label)),
      error: error == null
          ? null
          : Text(
              error,
              style: AppTypography.footnote.copyWith(
                color: AppColors.error.resolveFrom(context),
              ),
            ),
      child: field,
    );
  }

  CupertinoTextField _textField({
    required TextEditingController controller,
    required String placeholder,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return CupertinoTextField.borderless(
      controller: controller,
      placeholder: placeholder,
      placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
      padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.xs, vertical: _fieldVerticalPadding),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  Widget _buildPhoneRow(int index) {
    return Row(
      // Keeps each field's state with its controller when a row above is removed
      key: ObjectKey(_phoneControllers[index]),
      children: [
        Expanded(
          child: _fieldRow(
            label: 'Телефон',
            error: ExchangePointFormValidation.phoneError(_form, index),
            field: _textField(
              controller: _phoneControllers[index],
              placeholder: "+7 701 123 4567",
              keyboardType: TextInputType.phone,
              onChanged: _onPhoneChanged,
            ),
          ),
        ),
        if (_phoneControllers.length > 1)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            onPressed: () => _removePhone(index),
            child: Icon(
              CupertinoIcons.minus_circle,
              color: AppColors.destructive.resolveFrom(context),
              size: AppIconSize.small,
              semanticLabel: 'Удалить номер',
            ),
          ),
      ],
    );
  }

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
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          child: Row(
            children: [
              Text(currency.icon, style: AppTypography.title2),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: _currencyCodeWidth,
                child: Text(currency.id),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _rateField(
                  placeholder: "Покупка",
                  indicator: AppColors.buy,
                  hasError: buyError != null,
                  controller: buyController,
                  onChanged: (value) =>
                      _onRateChanged(value, currency: currency.id, isBuy: true),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _rateField(
                  placeholder: "Продажа",
                  indicator: AppColors.sell,
                  hasError: sellError != null,
                  controller: sellController,
                  onChanged: (value) =>
                      _onRateChanged(value, currency: currency.id, isBuy: false),
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
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xs),
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

  /// A rate field with a stripe in the buy/sell color on its leading edge.
  Widget _rateField({
    required String placeholder,
    required CupertinoDynamicColor indicator,
    required bool hasError,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background.resolveFrom(context),
        borderRadius: AppRadius.control,
        border: Border.all(
          color: (hasError ? AppColors.error : AppColors.inputBorder).resolveFrom(context),
          width: AppStroke.hairline,
        ),
      ),
      child: Stack(
        children: [
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            placeholderStyle: const TextStyle(color: AppColors.secondaryLabel),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [rateInputFormatter],
            textAlign: TextAlign.center,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs, vertical: _fieldVerticalPadding),
            decoration: null, // The container draws the border.
            onChanged: onChanged,
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: AppSpacing.xxs,
            child: ColoredBox(color: indicator.resolveFrom(context)),
          ),
        ],
      ),
    );
  }
}
