import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/exceptions/api_exception.dart';
import 'package:prokurs/core/exceptions/session_expired_exception.dart';

DioException _failed(int? statusCode, {Object? body, Object? error}) {
  final options = RequestOptions(path: '/v2/points/personal');
  return DioException(
    requestOptions: options,
    response: statusCode == null
        ? null
        : Response(requestOptions: options, statusCode: statusCode, data: body),
    error: error,
  );
}

DioException _unauthorized({Object? error}) => _failed(401, error: error);

void main() {
  test('a known API message is shown translated', () {
    final e = ApiException(
      message: 'each value in phone_numbers must be a valid phone number',
      statusCode: 400,
    );

    expect(e.toString(), startsWith('Проверьте номера телефонов'));
  });

  test('a request the interceptor marked becomes SessionExpiredException', () {
    expect(ApiException.fromDio(_unauthorized(error: SessionExpiredException())),
        isA<SessionExpiredException>());
  });

  test('an unmarked 401 (the session was kept) is an ordinary error', () {
    final e = ApiException.fromDio(_unauthorized());
    expect(e, isNot(isA<SessionExpiredException>()));
    expect(e.toString(), 'Не удалось выполнить запрос');
  });

  test('an untranslated API message without field errors asks to check the input', () {
    final e = ApiException(
      message: 'each value in phone_numbers must be a valid phone number\n'
          'name must be a string',
      statusCode: 400,
    );

    expect(e.toString(), 'Проверьте введённые данные');
  });

  test('field errors say which field is wrong and why', () {
    final e = ApiException.fromDio(_failed(400, body: {
      'message': ['buyUSD must not be less than 0'],
      'errors': [
        {'field': 'buyUSD', 'constraint': 'min'},
        {'field': 'phone_numbers', 'constraint': 'matches'},
        {'field': 'work_modes.mon', 'constraint': 'arrayMinSize'},
        {'field': 'name', 'constraint': 'maxLength'},
        {'field': 'latitude', 'constraint': 'isLatitude'},
        {'field': 'something_new', 'constraint': 'min'},
      ],
    }));

    expect(e.toString().split('\n'), [
      'Покупка USD: не может быть отрицательным',
      'Телефоны: нужен формат +7 701 123 4567 или 4 цифры',
      'Режим работы: неверное значение',
      'Название: слишком длинное значение',
      'Координаты: вне допустимого диапазона',
      'Проверьте введённые данные',
    ]);
  });

  test("the organization's and the appendix's field errors are named", () {
    final e = ApiException.fromDio(_failed(400, body: {
      'message': ['bin must be a valid БИН'],
      'errors': [
        {'field': 'bin', 'constraint': 'isBin'},
        {'field': 'contactPhone', 'constraint': 'matches'},
        {'field': 'licenseDate', 'constraint': 'isNotInFuture'},
        {'field': 'license_appendix_date', 'constraint': 'matches'},
        {'field': 'license_appendix_number', 'constraint': 'maxLength'},
        {'field': 'organizationName', 'constraint': 'maxLength'},
      ],
    }));

    expect(e.toString().split('\n'), [
      'БИН: неверный БИН, проверьте все 12 цифр',
      'Контактный телефон: нужен формат +7 701 123 4567',
      'Дата выдачи лицензии: не может быть в будущем',
      'Дата приложения: неверная дата',
      'Номер приложения: слишком длинное значение',
      'Наименование организации: слишком длинное значение',
    ]);
  });

  test('no response and server failures have their own texts', () {
    expect(ApiException.fromDio(_failed(null)).toString(), startsWith('Нет соединения с сервером'));
    expect(ApiException.fromDio(_failed(503)).toString(), startsWith('Сервер временно недоступен'));
    expect(ApiException.fromDio(_failed(429)).toString(), startsWith('Слишком много попыток'));
  });
}
