import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/features/exchange_points/domain/models/city.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';
import 'package:prokurs/features/rates/domain/models/best_rates.dart';

/// Every field of an API DTO is either mapped into the app's model, and its value checked
/// below, or listed as unused with the reason. A field the API adds later (after
/// tool/codegen.sh) fails this until it's decided, so a mapping can't silently drop a field
/// the way `fromRate` once dropped wholesale_note.
void expectEveryFieldHandled(
  Map<String, dynamic> dtoJson, {
  required Set<String> mapped,
  Map<String, String> unused = const {},
}) {
  final fields = dtoJson.keys.toSet();
  final handled = {...mapped, ...unused.keys};
  expect(fields.difference(handled), isEmpty,
      reason: 'API fields neither mapped nor listed as unused');
  expect(handled.difference(fields), isEmpty, reason: 'fields the API no longer has');
}

const _pointUnused = {
  'company_id': 'the owner company: the app works with the signed-in user',
  'published': 'moderation status (1 published, 0 on moderation): not shown yet',
  'sorting': 'the server order: the app sorts by the rates',
  'atms': 'ATMs nearby: not shown yet',
};

const _pointMapped = {
  'id', 'name', 'info', 'city_id', 'day_and_night', 'longitude', 'latitude', 'gross',
  'logo', 'wholesale_note', 'work_modes', 'description', 'date_update', //
  'buyUSD', 'sellUSD', 'buyEUR', 'sellEUR', 'buyRUB', 'sellRUB', //
  'buyCNY', 'sellCNY', 'buyGBP', 'sellGBP',
};

/// A point as the API sends it, every field set to a value of its own.
Map<String, dynamic> _pointJson({required String phonesField}) => {
      'id': 7,
      'name': 'Обменник',
      'info': 'ул. Абая 1',
      'buyUSD': 1.1,
      'sellUSD': 1.2,
      'buyEUR': 2.1,
      'sellEUR': 2.2,
      'buyRUB': 3.1,
      'sellRUB': 3.2,
      'buyCNY': 4.1,
      'sellCNY': 4.2,
      'buyGBP': 5.1,
      'sellGBP': 5.2,
      'city_id': 4,
      'day_and_night': 1,
      'company_id': 9,
      'published': 1,
      'sorting': 3,
      'longitude': 76.9,
      'latitude': 43.2,
      'gross': 1,
      'atms': 'Банкомат у входа',
      'logo': 'https://example.kz/logo.png',
      'wholesale_note': 'Оптовые курсы от 100 000 тенге',
      'work_modes': {
        'mon': ['09:00', '18:00', '', ''],
      },
      'description': 'Без комиссии',
      'date_update': 1700000000,
      phonesField: ['+7 701 123 4567'],
    };

void _expectPoint(ExchangePoint point) {
  expect(point.id, 7);
  expect(point.name, 'Обменник');
  expect(point.info, 'ул. Абая 1');
  expect([point.buyUSD, point.sellUSD], [1.1, 1.2]);
  expect([point.buyEUR, point.sellEUR], [2.1, 2.2]);
  expect([point.buyRUB, point.sellRUB], [3.1, 3.2]);
  expect([point.buyCNY, point.sellCNY], [4.1, 4.2]);
  expect([point.buyGBP, point.sellGBP], [5.1, 5.2]);
  expect(point.cityId, 4);
  expect(point.dayAndNight, 1);
  expect([point.longitude, point.latitude], [76.9, 43.2]);
  expect(point.gross, 1);
  expect(point.logo, 'https://example.kz/logo.png');
  expect(point.wholesaleNote, 'Оптовые курсы от 100 000 тенге');
  expect(point.workModes?.mon, ['09:00', '18:00', '', '']);
  expect(point.description, 'Без комиссии');
  expect(point.dateUpdate, 1700000000);
  expect(point.phones, ['+7 701 123 4567']);
}

void main() {
  test('a point from the public rates: every API field is mapped or listed', () {
    final json = _pointJson(phonesField: 'phones');
    final dto = PointWithParsedPhonesDto.fromJson(json);

    expectEveryFieldHandled(dto.toJson(),
        mapped: {..._pointMapped, 'phones'}, unused: _pointUnused);
    _expectPoint(ExchangePoint.fromRate(dto));
  });

  test("a signed-in user's point: every API field is mapped or listed", () {
    final json = _pointJson(phonesField: 'phone_numbers');
    final dto = PersonalPointV2Dto.fromJson(json);

    expectEveryFieldHandled(dto.toJson(),
        mapped: {..._pointMapped, 'phone_numbers'}, unused: _pointUnused);
    _expectPoint(ExchangePoint.fromPersonal(dto));
  });

  test('a city: every API field is mapped or listed', () {
    final dto = PublicCityDto.fromJson(
        {'id': 4, 'name': 'Астана', 'longitude': 71.4, 'latitude': 51.1, 'slug': 'astana'});

    expectEveryFieldHandled(dto.toJson(), mapped: {'id', 'name'}, unused: {
      'longitude': 'the city center: the map centers on the point',
      'latitude': 'the city center: the map centers on the point',
      'slug': 'for web addresses',
    });
    final city = City.fromDto(dto);
    expect([city.id, city.title], [4, 'Астана']);
  });

  test('the best rates: every API field is mapped or listed', () {
    final dto = BestCoursesDto.fromJson({
      'buyUSD': 1.1, 'sellUSD': 1.2, 'buyEUR': 2.1, 'sellEUR': 2.2,
      'buyRUB': 3.1, 'sellRUB': 3.2, 'buyCNY': 4.1, 'sellCNY': 4.2,
      'buyGBP': 5.1, 'sellGBP': 5.2, 'buyXAU': 6.1, 'sellXAU': 6.2, //
    });

    expectEveryFieldHandled(dto.toJson(), mapped: {
      'buyUSD', 'sellUSD', 'buyEUR', 'sellEUR', 'buyRUB', 'sellRUB', //
      'buyCNY', 'sellCNY', 'buyGBP', 'sellGBP',
    }, unused: {
      'buyXAU': 'gold is not among the currencies the app shows',
      'sellXAU': 'gold is not among the currencies the app shows',
    });
    final best = BestRates.fromDto(dto);
    expect([best.buyUSD, best.sellUSD, best.buyEUR, best.sellEUR, best.buyRUB],
        [1.1, 1.2, 2.1, 2.2, 3.1]);
    expect([best.sellRUB, best.buyCNY, best.sellCNY, best.buyGBP, best.sellGBP],
        [3.2, 4.1, 4.2, 5.1, 5.2]);
  });
}
