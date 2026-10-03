import 'package:dio/dio.dart';
import 'package:prokurs/core/exceptions/session_expired_exception.dart';
import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/features/auth/domain/models/auth_tokens.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';

/// Attaches the access token and, on 401, refreshes it once and retries the request.
///
/// A [QueuedInterceptor] handles errors one at a time, so concurrent 401s share a single
/// refresh: the first one refreshes, the rest see a newer token and only retry.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._authProvider, this._plainDio);

  final AuthProvider _authProvider;

  /// Has no auth interceptor. Used for the refresh call and for retries, so a failed retry
  /// can neither loop nor wait in this interceptor's own queue.
  final Dio _plainDio;

  static bool _isAuthPath(String path) => path.contains('/auth/');

  /// Fails [err]'s request as "the session ended", so screens can tell it from other errors.
  static void _rejectSessionExpired(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(err.copyWith(error: SessionExpiredException()));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = _authProvider.tokens?.accessToken;
    if (accessToken != null && !_isAuthPath(options.path)) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final tokens = _authProvider.tokens;
    if (err.response?.statusCode != 401 || _isAuthPath(options.path)) {
      return handler.next(err);
    }
    // A request queued behind the one that found the session over.
    if (tokens == null) return _rejectSessionExpired(err, handler);

    var accessToken = tokens.accessToken;

    // If the request went out with an older token, a queued request has refreshed it already.
    if (options.headers['Authorization'] == 'Bearer $accessToken') {
      try {
        final refreshed = await AuthClient(_plainDio)
            .authControllerRefreshV2(refreshToken: tokens.refreshToken);
        // Signed out or in again while refreshing: don't bring the old session back.
        if (!identical(_authProvider.tokens, tokens)) return handler.next(err);
        accessToken = refreshed.accessToken;
        await _authProvider.updateTokens(AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshed.refreshToken,
        ));
      } catch (e) {
        // 401 means the refresh token is dead. A network or server failure keeps the session.
        if (e is DioException && e.response?.statusCode == 401) {
          await _authProvider.expireSession();
          return _rejectSessionExpired(err, handler);
        }
        return handler.next(err);
      }
    }

    try {
      options.headers['Authorization'] = 'Bearer $accessToken';
      handler.resolve(await _plainDio.fetch(options));
    } on DioException catch (e) {
      handler.reject(e);
    }
  }
}
