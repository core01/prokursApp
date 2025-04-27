import 'package:flutter/foundation.dart';
import 'package:prokurs/models/auth_tokens.dart';
import 'package:prokurs/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthTokens? _tokens;

  bool _isLoading = false;

  AuthTokens? get tokens => _tokens;
  bool get isAuthenticated => _tokens != null;
  bool get isLoading => _isLoading;
  
  String? get userEmail {
    if (_tokens == null) return null;
    try {
      // Get the payload part (second part) of the JWT
      final parts = _tokens!.accessToken.split('.');
      if (parts.length != 3) return null;

      // Decode the base64 payload directly with base64Url
      final normalized = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(normalized));
      final payload = json.decode(payloadJson);

      // Extract email from the payload
      return payload['username'];
    } catch (e) {
      debugPrint('Error decoding token: $e');
      return null;
    }
  }

  Future<bool> checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');
      
      debugPrint('checkAuth -> accessToken: $accessToken');
      debugPrint('checkAuth -> refreshToken: $refreshToken');
      
      if (accessToken != null && refreshToken != null) {
        _tokens = AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
      notifyListeners();
      return isAuthenticated;
    } catch (e) {
      debugPrint('Error checking auth: $e');
      return false;
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tokens = await _authService.signIn(email: email, password: password);

      // Save tokens to SharedPreferences
      if (_tokens != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _tokens!.accessToken);
        await prefs.setString('refresh_token', _tokens!.refreshToken);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String fullName, String email, String password) async {
    _isLoading = true;
    try {
      await _authService.signUp(fullName: fullName, email: email, password: password);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> clearTokens() async {
    _tokens = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_email');
  }

  Future<void> signOut() async {
    _isLoading = true;
    try {
      await clearTokens();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  /// Updates the authentication tokens
  Future<void> updateTokens(Map<String, dynamic> tokenData) async {
    try {
      debugPrint('AuthProvider -> updateTokens -> received data: $tokenData');

      final newTokens = AuthTokens.fromJson(tokenData);
      _tokens = newTokens;

      // Save tokens to shared preferences
      final prefs = await SharedPreferences.getInstance();

      // Use both individual keys and the combined 'tokens' key for backward compatibility
      await prefs.setString('access_token', newTokens.accessToken);
      await prefs.setString('refresh_token', newTokens.refreshToken);
      await prefs.setString('tokens', jsonEncode(tokenData));

      debugPrint('AuthProvider -> updateTokens -> tokens saved: $_tokens');
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating tokens: $e');
      throw Exception('Failed to update tokens: $e');
    }
  }
}
