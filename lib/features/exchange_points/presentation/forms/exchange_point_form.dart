import 'package:formz/formz.dart';
import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/exchange_points/presentation/forms/form_inputs.dart';

class ExchangePointForm {
  final NameInput name;
  final InfoInput info;
  final PhonesInput phones;
  final CityInput city;
  final num gross;

  /// The wholesale conditions; the API shows them only while [gross] is on, so they are kept
  /// when it's switched off.
  final String wholesaleNote;
  final bool isSubmitted;

  // Currency rates
  final String buyUSD;
  final String sellUSD;
  final String buyEUR;
  final String sellEUR;
  final String buyRUB;
  final String sellRUB;
  final String buyCNY;
  final String sellCNY;
  final String buyGBP;
  final String sellGBP;

  const ExchangePointForm({
    this.name = const NameInput.pure(),
    this.info = const InfoInput.pure(),
    this.phones = const PhonesInput.pure(),
    this.city = const CityInput.pure(),
    this.gross = 0,
    this.wholesaleNote = '',
    this.isSubmitted = false,
    this.buyUSD = '',
    this.sellUSD = '',
    this.buyEUR = '',
    this.sellEUR = '',
    this.buyRUB = '',
    this.sellRUB = '',
    this.buyCNY = '',
    this.sellCNY = '',
    this.buyGBP = '',
    this.sellGBP = '',
  });

  ExchangePointForm copyWith({
    NameInput? name,
    InfoInput? info,
    PhonesInput? phones,
    CityInput? city,
    num? gross,
    String? wholesaleNote,
    bool? isSubmitted,
    String? buyUSD,
    String? sellUSD,
    String? buyEUR,
    String? sellEUR,
    String? buyRUB,
    String? sellRUB,
    String? buyCNY,
    String? sellCNY,
    String? buyGBP,
    String? sellGBP,
  }) {
    return ExchangePointForm(
      name: name ?? this.name,
      info: info ?? this.info,
      phones: phones ?? this.phones,
      city: city ?? this.city,
      gross: gross ?? this.gross,
      wholesaleNote: wholesaleNote ?? this.wholesaleNote,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      buyUSD: buyUSD ?? this.buyUSD,
      sellUSD: sellUSD ?? this.sellUSD,
      buyEUR: buyEUR ?? this.buyEUR,
      sellEUR: sellEUR ?? this.sellEUR,
      buyRUB: buyRUB ?? this.buyRUB,
      sellRUB: sellRUB ?? this.sellRUB,
      buyCNY: buyCNY ?? this.buyCNY,
      sellCNY: sellCNY ?? this.sellCNY,
      buyGBP: buyGBP ?? this.buyGBP,
      sellGBP: sellGBP ?? this.sellGBP,
    );
  }

  ExchangePointForm markSubmitted() {
    if (isSubmitted) return this;
    return copyWith(isSubmitted: true);
  }

  /// The rate fields by the label error texts use.
  Map<String, String> get _rates => {
        'Покупка USD': buyUSD,
        'Продажа USD': sellUSD,
        'Покупка EUR': buyEUR,
        'Продажа EUR': sellEUR,
        'Покупка RUB': buyRUB,
        'Продажа RUB': sellRUB,
        'Покупка CNY': buyCNY,
        'Продажа CNY': sellCNY,
        'Покупка GBP': buyGBP,
        'Продажа GBP': sellGBP,
      };

  bool get isValid =>
      Formz.validate([name, info, phones, city]) &&
      _rates.values.every((rate) => ExchangePointFormValidation.rateError(rate) == null);

  /// What to fix, one line per field: "Покупка USD — не может быть отрицательным".
  List<String> errorSummary() => [
        if (city.isNotValid) 'Город — не выбран',
        if (name.isNotValid) 'Название — не заполнено',
        if (info.isNotValid) 'Адрес — не заполнен',
        if (phones.error == PhoneValidationError.empty) 'Телефон — не заполнен',
        if (phones.error == PhoneValidationError.invalid)
          'Телефон — формат +7 701 123 4567 или 4 цифры',
        for (final MapEntry(key: label, value: rate) in _rates.entries)
          if (ExchangePointFormValidation.rateError(rate) case final error?) '$label — $error',
      ];

  String? get _wholesaleNote {
    final note = wholesaleNote.trim();
    return note.isEmpty ? null : note;
  }

  double _parseRate(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }

  /// Call only on a valid form: the city must be selected.
  CreatePointV2Input toCreateInput() {
    return CreatePointV2Input(
      name: name.value,
      info: info.value,
      phoneNumbers: phones.numbers,
      cityId: city.value!,
      gross: gross.toInt(),
      wholesaleNote: _wholesaleNote,
      buyUsd: _parseRate(buyUSD),
      sellUsd: _parseRate(sellUSD),
      buyEur: _parseRate(buyEUR),
      sellEur: _parseRate(sellEUR),
      buyRub: _parseRate(buyRUB),
      sellRub: _parseRate(sellRUB),
      buyCny: _parseRate(buyCNY),
      sellCny: _parseRate(sellCNY),
      buyGbp: _parseRate(buyGBP),
      sellGbp: _parseRate(sellGBP),
    );
  }

  /// Call only on a valid form: the city must be selected.
  ///
  /// The API replaces the whole point, so the fields this form doesn't edit are sent back
  /// as they are in [original].
  ReplacePointV2Input toReplaceInput(ExchangePoint original) {
    return ReplacePointV2Input(
      name: name.value,
      info: info.value,
      phoneNumbers: phones.numbers,
      cityId: city.value!,
      gross: gross.toInt(),
      wholesaleNote: _wholesaleNote,
      buyUsd: _parseRate(buyUSD),
      sellUsd: _parseRate(sellUSD),
      buyEur: _parseRate(buyEUR),
      sellEur: _parseRate(sellEUR),
      buyRub: _parseRate(buyRUB),
      sellRub: _parseRate(sellRUB),
      buyCny: _parseRate(buyCNY),
      sellCny: _parseRate(sellCNY),
      buyGbp: _parseRate(buyGBP),
      sellGbp: _parseRate(sellGBP),
      dayAndNight: original.dayAndNight.toInt(),
      longitude: original.longitude,
      latitude: original.latitude,
      workModes: original.workModes,
      description: original.description,
    );
  }

  static ExchangePointForm fromExchangePoint(ExchangePoint point) {
    return ExchangePointForm(
      name: NameInput.dirty(point.name),
      info: InfoInput.dirty(point.info ?? ''),
      phones: PhonesInput.dirty(
          point.phones.isEmpty ? const [''] : point.phones),
      city: CityInput.dirty(point.cityId.toInt()),
      gross: point.gross,
      wholesaleNote: point.wholesaleNote ?? '',
      buyUSD: point.buyUSD != 0 ? point.buyUSD.toString() : '',
      sellUSD: point.sellUSD != 0 ? point.sellUSD.toString() : '',
      buyEUR: point.buyEUR != 0 ? point.buyEUR.toString() : '',
      sellEUR: point.sellEUR != 0 ? point.sellEUR.toString() : '',
      buyRUB: point.buyRUB != 0 ? point.buyRUB.toString() : '',
      sellRUB: point.sellRUB != 0 ? point.sellRUB.toString() : '',
      buyCNY: point.buyCNY != 0 ? point.buyCNY.toString() : '',
      sellCNY: point.sellCNY != 0 ? point.sellCNY.toString() : '',
      buyGBP: point.buyGBP != 0 ? point.buyGBP.toString() : '',
      sellGBP: point.sellGBP != 0 ? point.sellGBP.toString() : '',
    );
  }
}

class ExchangePointFormValidation {
  // Make this class to be used as a static class
  const ExchangePointFormValidation._();

  static ExchangePointForm touchRequiredFields(ExchangePointForm form) {
    return form.copyWith(
      name: NameInput.dirty(form.name.value),
      info: InfoInput.dirty(form.info.value),
      phones: PhonesInput.dirty(form.phones.value),
      city: CityInput.dirty(form.city.value),
    );
  }

  /// What's wrong with a rate as typed (comma or dot), or null. Blank is fine: it's saved as 0.
  /// Invalid values can only come from the server: rateInputFormatter stops typing them.
  static String? rateError(String value) {
    final text = value.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    final rate = double.tryParse(text);
    if (rate == null) return 'введите число';
    if (rate < 0) return 'не может быть отрицательным';
    // The API stores rates as DECIMAL(8,2).
    if (text.contains('.') && text.split('.').last.length > 2) {
      return 'не больше двух знаков после запятой';
    }
    if (rate > 999999.99) return 'слишком большое значение';
    return null;
  }

  static String? nameError(ExchangePointForm form) {
    if (!form.isSubmitted) return null;

    switch (form.name.displayError) {
      case NameValidationError.empty:
        return 'Введите название';
      case null:
        return null;
    }
  }

  static String? addressError(ExchangePointForm form) {
    if (!form.isSubmitted) return null;

    switch (form.info.displayError) {
      case AddressValidationError.empty:
        return 'Введите адрес';
      case null:
        return null;
    }
  }

  /// Error for the phone field at [index].
  static String? phoneError(ExchangePointForm form, int index) {
    if (!form.isSubmitted) return null;

    final phone = form.phones.value[index].trim();
    if (phone.isEmpty) {
      // A blank field is fine as long as some other field has a number.
      final isOnlyField = index == 0 && form.phones.numbers.isEmpty;
      return isOnlyField ? 'Введите телефон' : null;
    }
    return PhonesInput.isValidNumber(phone)
        ? null
        : 'Формат: +7 701 123 4567 или 4 цифры';
  }
}
