import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:prokurs/providers/auth.dart';

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
      throw Exception('ApiClient not initialized. Call ApiClient.initialize() first.');
    }
    return _instance!;
  }

  /// Initialize the ApiClient with AuthProvider (call this once in main.dart)
  static void initialize(AuthProvider authProvider) {
    _instance = ApiClient._internal(authProvider);
  }

  /// Private constructor
  ApiClient._internal(this._authProvider)
      : _baseUrl = '${FlutterConfig.get('API_URL')}/',
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
        // Add auth header if token is available
        debugPrint('api_client -> onRequest -> _authProvider.tokens: ${_authProvider.tokens}');
        if (_authProvider.tokens != null) {
          options.headers['Authorization'] = 'Bearer ${_authProvider.tokens!.accessToken}';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        debugPrint('api_client -> onError -> error: $error');
        // Handle auth errors (401)
        if (error.response?.statusCode == 401) {
          // Only attempt to refresh if we're not already refreshing
          if (!_isRefreshing) {
            // Try to refresh the token
            debugPrint('Token expired, attempting to refresh...');
            bool refreshed = await _refreshToken();

            if (refreshed) {
              // If successful, retry the original request
              debugPrint('Token refreshed, retrying request');
              // Clone the original request options
              final options = error.requestOptions;

              // Create a new request
              final response = await dio.request(
                options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: Options(
                  method: options.method,
                  headers: {
                    ...options.headers,
                    'Authorization': 'Bearer ${_authProvider.tokens!.accessToken}',
                  },
                ),
              );

              // Return the successful response
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
      debugPrint(
          'ApiClient -> _refreshToken -> attempting with token: ${_authProvider.tokens?.refreshToken.substring(0, 10)}...');

      // Create a separate Dio instance for the refresh request
      // to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ));

      // Get the refresh token
      final refreshToken = _authProvider.tokens?.refreshToken;
      if (refreshToken == null) {
        debugPrint('ApiClient -> _refreshToken -> refreshToken is null');
        return false;
      }

      // Make the refresh token request
      debugPrint('ApiClient -> _refreshToken -> making request to ${_baseUrl}auth/refresh');
      final response = await refreshDio.post(
        'auth/refresh',
        options: Options(
          headers: {
            'refresh-token': refreshToken,
          },
        ),
      );

      // Check if the refresh was successful
      debugPrint('ApiClient -> _refreshToken -> response: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('ApiClient -> _refreshToken -> refresh successful, data: ${response.data}');
        // Update tokens in the auth provider
        await _authProvider.updateTokens(response.data);
        debugPrint('ApiClient -> _refreshToken -> tokens updated: ${_authProvider.tokens}');
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
