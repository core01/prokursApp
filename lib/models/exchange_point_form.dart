import 'package:prokurs/models/exchange_point.dart';
import 'package:prokurs/models/form_inputs.dart';

class ExchangePointForm {
  final NameInput name;
  final InfoInput info;
  final PhonesInput phones;
  final CityInput city;
  final num gross;

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
  final String buyGold;
  final String sellGold;

  const ExchangePointForm({
    this.name = const NameInput.pure(),
    this.info = const InfoInput.pure(),
    this.phones = const PhonesInput.pure(),
    this.city = const CityInput.pure(),
    this.gross = 0,
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
    this.buyGold = '',
    this.sellGold = '',
  });

  ExchangePointForm copyWith({
    NameInput? name,
    InfoInput? info,
    PhonesInput? phones,
    CityInput? city,
    num? gross,
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
    String? buyGold,
    String? sellGold,
  }) {
    return ExchangePointForm(
      name: name ?? this.name,
      info: info ?? this.info,
      phones: phones ?? this.phones,
      city: city ?? this.city,
      gross: gross ?? this.gross,
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
      buyGold: buyGold ?? this.buyGold,
      sellGold: sellGold ?? this.sellGold,
    );
  }

  bool get isValid {
    final nameValid = name.isValid;
    final infoValid = info.isValid;
    final phoneValid = phones.isValid;
    final cityValid = city.isValid;

    print('Form validation - Name: $nameValid, Info: $infoValid, Phone: $phoneValid, City: $cityValid');
    print('Name value: "${name.value}"');
    print('Info value: "${info.value}"');
    print('Phones value: "${phones.value}"');
    print('City value: ${city.value}');

    return nameValid && infoValid && phoneValid && cityValid;
  }

  double _parseRate(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.value,
      'info': info.value,
      'phones': phones.value,
      'city_id': city.value,
      'gross': gross,
      'buyUSD': _parseRate(buyUSD),
      'sellUSD': _parseRate(sellUSD),
      'buyEUR': _parseRate(buyEUR),
      'sellEUR': _parseRate(sellEUR),
      'buyRUB': _parseRate(buyRUB),
      'sellRUB': _parseRate(sellRUB),
      'buyCNY': _parseRate(buyCNY),
      'sellCNY': _parseRate(sellCNY),
      'buyGBP': _parseRate(buyGBP),
      'sellGBP': _parseRate(sellGBP),
      'buyGold': _parseRate(buyGold),
      'sellGold': _parseRate(sellGold),
    };
  }

  static ExchangePointForm fromExchangePoint(ExchangePoint point) {
    return ExchangePointForm(
      name: NameInput.dirty(point.name),
      info: InfoInput.dirty(point.info ?? ''),
      phones: PhonesInput.dirty(point.phones != null && point.phones.isNotEmpty ? point.phones[0].toString() : ''),
      city: CityInput.dirty(point.city_id.toInt()),
      gross: point.gross,
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
