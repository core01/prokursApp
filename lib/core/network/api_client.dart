import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prokurs/core/network/auth_interceptor.dart';
import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/features/auth/presentation/state/auth_provider.dart';

/// API Client that automatically handles authentication
class ApiClient {
  static ApiClient? _instance;
  final Dio dio;

  /// Generated API client. Its paths carry the API version (`/v2/...`).
  late final RestClient api = RestClient(dio);

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

  static BaseOptions get _options => BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      );

  /// Private constructor
  ApiClient._internal(AuthProvider authProvider) : dio = Dio(_options) {
    final plainDio = Dio(_options);
    dio.interceptors.add(AuthInterceptor(authProvider, plainDio));

    // Add logging interceptor for debugging
    if (kDebugMode) {
      for (final client in [dio, plainDio]) {
        client.interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
        ));
      }
    }
  }
}
