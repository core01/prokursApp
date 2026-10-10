import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/network/date_only_interceptor.dart';
import 'package:prokurs/core/network/generated/export.dart';

/// Records what leaves the app.
class _RecordingApi implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(jsonEncode({}), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _RecordingApi api;
  late Dio dio;

  setUp(() {
    api = _RecordingApi();
    dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = api
      ..interceptors.add(const DateOnlyInterceptor());
  });

  Map<String, dynamic> sent() => api.requests.single.data as Map<String, dynamic>;

  test('a day picked as a DateTime reaches the API as YYYY-MM-DD', () async {
    final body = UpdateOrganizationInput(
      organizationName: 'ТОО «Обмен»',
      licenseDate: DateTime(2024, 3, 15),
    ).toJson();
    // What json_serializable writes: the full date-time the API would answer with a 400.
    expect(body['licenseDate'], '2024-03-15T00:00:00.000');

    await dio.patch<void>('/v2/profile/organization', data: body);

    expect(sent()['licenseDate'], '2024-03-15');
    expect(sent()['organizationName'], 'ТОО «Обмен»');
  });

  test('a UTC midnight and a null stay what they should be', () async {
    await dio.put<void>('/v2/points/personal/1', data: {
      'license_appendix_date': '2024-03-15T00:00:00.000Z',
      'license_appendix_number': null,
      'rate': 1.5,
    });

    expect(sent()['license_appendix_date'], '2024-03-15');
    expect(sent()['license_appendix_number'], isNull);
    expect(sent()['rate'], 1.5);
  });

  test('a moment that is not a midnight is left alone', () async {
    await dio.post<void>('/v2/x', data: {'at': '2024-03-15T10:30:00.000'});

    expect(sent()['at'], '2024-03-15T10:30:00.000');
  });
}
