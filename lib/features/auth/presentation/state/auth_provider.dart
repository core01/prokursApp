import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:prokurs/features/auth/data/services/auth_service.dart';
import 'package:prokurs/features/auth/domain/models/auth_tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthTokens? _tokens;

  bool _isLoading = false;

  // Set when the server ended the session; the sign-in screen reads it once.
  bool _sessionExpired = false;
  String? _expiredSessionEmail;

  AuthTokens? get tokens => _tokens;
  bool get isAuthenticated => _tokens != null;
  bool get isLoading => _isLoading;

  /// Whether the server ended the session (rather than the user signing out). Unlike
  /// [takeExpiredSession], reading it doesn't reset it.
  bool get sessionExpired => _sessionExpired;

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
      await updateTokens(
          await _authService.signIn(email: email, password: password));
      _sessionExpired = false;
      _expiredSessionEmail = null;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearTokens() async {
    _tokens = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_email');
    // Written by older app versions.
    await prefs.remove('tokens');
  }

  /// The user signs out. Listeners (see main.dart) take them back to the rates.
  Future<void> signOut() async {
    final refreshToken = _tokens?.refreshToken;
    if (refreshToken != null) {
      // In the background: signing out must not wait for the network.
      unawaited(_authService.logout(refreshToken).catchError((Object e) {
        // Offline, or the token is already rotated/revoked: nothing to revoke.
        debugPrint('Error revoking refresh token: $e');
      }));
    }
    _sessionExpired = false;
    _expiredSessionEmail = null;
    await clearTokens();
    notifyListeners();
  }

  /// The server rejected the refresh token. Like [signOut], but the sign-in screen tells the
  /// user why they are there and prefills their email.
  Future<void> expireSession() async {
    _sessionExpired = true;
    _expiredSessionEmail = userEmail;
    await clearTokens();
    notifyListeners();
  }

  /// Whether the session expired since the last sign-in, and its email. Resets both, so the
  /// sign-in screen explains the expiry only the first time it opens after it.
  ({bool expired, String? email}) takeExpiredSession() {
    final session = (expired: _sessionExpired, email: _expiredSessionEmail);
    _sessionExpired = false;
    _expiredSessionEmail = null;
    return session;
  }

  /// Updates the authentication tokens
  Future<void> updateTokens(AuthTokens tokens) async {
    _tokens = tokens;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', tokens.accessToken);
    await prefs.setString('refresh_token', tokens.refreshToken);

    notifyListeners();
  }
}
