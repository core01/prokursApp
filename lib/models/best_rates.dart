class BestRates {
  final num buyUSD;
  final num sellUSD;
  final num buyEUR;
  final num sellEUR;
  final num buyRUB;
  final num sellRUB;
  final num buyCNY;
  final num sellCNY;
  final num buyGBP;
  final num sellGBP;

  BestRates({
    this.buyCNY = -1,
    this.buyEUR = -1,
    this.buyGBP = -1,
    this.buyRUB = -1,
    this.buyUSD = -1,
    this.sellCNY = 10000,
    this.sellEUR = 10000,
    this.sellGBP = 10000,
    this.sellRUB = 10000,
    this.sellUSD = 10000,
  });

  Map<String, dynamic> _toMap() {
    return {
      'buyCNY': buyCNY,
      'buyEUR': buyEUR,
      'buyGBP': buyGBP,
      'buyRUB': buyRUB,
      'buyUSD': buyUSD,
      'sellCNY': sellCNY,
      'sellEUR': sellEUR,
      'sellGBP': sellGBP,
      'sellRUB': sellRUB,
      'sellUSD': sellUSD,
    };
  }

  dynamic get(String propertyName) {
    var _mapRep = _toMap();
    if (_mapRep.containsKey(propertyName)) {
      return _mapRep[propertyName];
    }

    throw ArgumentError('property not found $propertyName');
  }

  factory BestRates.fromJson(Map<String, dynamic> bestRatesFromJson) {
    return BestRates(
      buyCNY: bestRatesFromJson['buyCNY'],
      buyEUR: bestRatesFromJson['buyEUR'],
      buyGBP: bestRatesFromJson['buyGBP'],
      buyRUB: bestRatesFromJson['buyRUB'],
      buyUSD: bestRatesFromJson['buyUSD'],
      sellCNY: bestRatesFromJson['sellCNY'],
      sellEUR: bestRatesFromJson['sellEUR'],
      sellGBP: bestRatesFromJson['sellGBP'],
      sellRUB: bestRatesFromJson['sellRUB'],
      sellUSD: bestRatesFromJson['sellUSD'],
    );
  }
}
