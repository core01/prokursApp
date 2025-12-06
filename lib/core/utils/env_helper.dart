import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Helper class to provide environment variables to native platforms
class EnvHelper {
  static const MethodChannel _channel = MethodChannel('com.prokurs.app/env');

  /// Initialize method channel handler to provide env vars to native code
  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'getEnv') {
        final key = call.arguments as String;
        return dotenv.get(key, fallback: '');
      }
      return null;
    });
  }

  /// Get environment variable value
  static String get(String key, {String fallback = ''}) {
    return dotenv.get(key, fallback: fallback);
  }
}

