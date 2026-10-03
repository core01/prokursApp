import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prokurs/core/exceptions/session_expired_exception.dart';
import 'package:prokurs/core/network/auth_interceptor.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _refreshPath = '/v2/auth/refresh';
const _resourcePath = '/v2/points/personal';

/// Stands in for the API: records every request and answers with [respond].
class _FakeApi implements HttpClientAdapter {
  _FakeApi(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final List<RequestOptions> requests = [];

  int get refreshCalls => requests.where((r) => r.path == _refreshPath).length;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    // Lets concurrent requests all leave before the first response comes back.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int statusCode, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody _unauthorized() =>
    _json(401, {'message': 'Unauthorized', 'statusCode': 401});

ResponseBody _newTokens() =>
    _json(201, {'accessToken': 'new-access', 'refreshToken': 'new-refresh'});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthProvider authProvider;

  Dio buildDio(_FakeApi api) {
    final options = BaseOptions(baseUrl: 'http://api.test');
    final plainDio = Dio(options)..httpClientAdapter = api;
    return Dio(options)
      ..httpClientAdapter = api
      ..interceptors.add(AuthInterceptor(authProvider, plainDio));
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'old-access',
      'refresh_token': 'old-refresh',
    });
    authProvider = AuthProvider();
    await authProvider.checkAuth();
  });

  test('concurrent 401s share one refresh and all retry with the new token',
      () async {
    final api = _FakeApi((options) {
      if (options.path == _refreshPath) {
        return options.headers['refresh-token'] == 'old-refresh'
            ? _newTokens()
            : _unauthorized();
      }
      return options.headers['Authorization'] == 'Bearer new-access'
          ? _json(200, [])
          : _unauthorized();
    });
    final dio = buildDio(api);

    final responses =
        await Future.wait(List.generate(3, (_) => dio.get(_resourcePath)));

    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(api.refreshCalls, 1);
    expect(authProvider.tokens?.accessToken, 'new-access');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('refresh_token'), 'new-refresh');
  });

  test('rejected refresh token ends the session and marks every failed request', () async {
    final api = _FakeApi((_) => _unauthorized());
    final dio = buildDio(api);
    final isSessionExpired = isA<DioException>()
        .having((e) => e.error, 'error', isA<SessionExpiredException>());

    // Two at once, like "Мои точки" on open: the second waits behind the first.
    await Future.wait([
      expectLater(dio.get(_resourcePath), throwsA(isSessionExpired)),
      expectLater(dio.get(_resourcePath), throwsA(isSessionExpired)),
    ]);

    expect(api.refreshCalls, 1);
    expect(authProvider.isAuthenticated, isFalse);
    expect(authProvider.takeExpiredSession().expired, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('refresh_token'), isNull);
  });

  test('a retry that fails again is not refreshed a second time', () async {
    final api = _FakeApi((options) =>
        options.path == _refreshPath ? _newTokens() : _unauthorized());
    final dio = buildDio(api);

    await expectLater(dio.get(_resourcePath), throwsA(isA<DioException>()));

    expect(api.refreshCalls, 1);
    expect(api.requests.length, 3); // request, refresh, one retry
    expect(authProvider.isAuthenticated, isTrue);
  });

  test('network failure during refresh keeps the session', () async {
    final api = _FakeApi((options) {
      if (options.path == _refreshPath) {
        throw DioException.connectionError(
            requestOptions: options, reason: 'offline');
      }
      return _unauthorized();
    });
    final dio = buildDio(api);

    // The session is kept, so this is an ordinary error, not an expired session.
    await expectLater(
      dio.get(_resourcePath),
      throwsA(isA<DioException>()
          .having((e) => e.error, 'error', isNot(isA<SessionExpiredException>()))),
    );

    expect(authProvider.tokens?.refreshToken, 'old-refresh');
  });

  test('signing out during a refresh does not bring the session back', () async {
    final api = _FakeApi((options) {
      if (options.path == _refreshPath) {
        // The session ends while the refresh is in flight.
        authProvider.expireSession();
        return _newTokens();
      }
      return _unauthorized();
    });
    final dio = buildDio(api);

    await expectLater(dio.get(_resourcePath), throwsA(isA<DioException>()));

    expect(authProvider.isAuthenticated, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access_token'), isNull);
  });

  test('auth endpoints get no bearer token and no refresh', () async {
    final api = _FakeApi((_) => _unauthorized());
    final dio = buildDio(api);

    await expectLater(
        dio.post('/v2/auth/login'), throwsA(isA<DioException>()));

    expect(api.requests.single.headers.containsKey('Authorization'), isFalse);
    expect(authProvider.isAuthenticated, isTrue);
  });
}
