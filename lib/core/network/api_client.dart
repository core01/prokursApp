import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';

/// API Client that automatically handles authentication
class ApiClient {
  static ApiClient? _instance;
  final Dio dio;
  final String _baseUrl;
  late final AuthProvider _authProvider;
  bool _isRefreshing = false;

  /// Get the singleton instance
  static ApiClient get instance {
    if (_instance == null) {
      throw Exception(
          'ApiClient not initialized. Call ApiClient.initialize() first.');
    }
    return _instance!;
  }

  /// Initialize the ApiClient with AuthProvider (call this once in main.dart)
  static void initialize(AuthProvider authProvider) {
    _instance = ApiClient._internal(authProvider);
  }

  static String get baseUrl => Platform.isAndroid ? dotenv.get('API_URL_ANDROID') : dotenv.get('API_URL_IOS');

  /// Private constructor
  ApiClient._internal(this._authProvider)
    : _baseUrl = '$baseUrl/',
        dio = Dio() {
    // Configure Dio
    dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    );

    // Add auth interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Skip auth for login and register endpoints
        if (options.path.contains('auth/')) {
          return handler.next(options);
        }

        // Add auth header if token is available
        if (_authProvider.tokens != null) {
          options.headers['Authorization'] =
              'Bearer ${_authProvider.tokens!.accessToken}';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Skip token refresh for login and register endpoints
        if (error.requestOptions.path.contains('auth/')) {
          return handler.next(error);
        }

        // Handle auth errors (401)
        if (error.response?.statusCode == 401) {
          if (!_isRefreshing) {
            bool refreshed = await _refreshToken();
            if (refreshed) {
              final response = await dio.request(
                error.requestOptions.path,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
                options: Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization':
                        'Bearer ${_authProvider.tokens!.accessToken}',
                  },
                ),
              );
              return handler.resolve(response);
            } else {
              _authProvider.signOut();
            }
          }
        }
        return handler.next(error);
      },
    ));

    // Add logging interceptor for debugging
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  /// Attempt to refresh the auth token
  Future<bool> _refreshToken() async {
    try {
      _isRefreshing = true;
      final refreshToken = _authProvider.tokens?.refreshToken;
      if (refreshToken == null) return false;

      final refreshDio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ));

      final response = await refreshDio.post(
        'auth/refresh',
        options: Options(
          headers: {
            'refresh-token': refreshToken,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _authProvider.updateTokens(response.data);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}

/// Extension to add HTTP methods directly to ApiClient
extension ApiClientExtension on ApiClient {
  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  /// POST request
  Future<Response> post(String path, {Object? data}) {
    return dio.post(path, data: data);
  }

  /// PUT request
  Future<Response> put(String path, {Object? data}) {
    return dio.put(path, data: data);
  }

  /// DELETE request
  Future<Response> delete(String path) {
    return dio.delete(path);
  }
}
