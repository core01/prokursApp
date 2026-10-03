import 'package:dio/dio.dart';
import 'package:prokurs/core/exceptions/conflict_exception.dart';
import 'package:prokurs/core/exceptions/unauthorized_exception.dart';
import 'package:prokurs/core/exceptions/api_exception.dart';
import 'package:prokurs/core/network/api_client.dart';
import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/features/auth/domain/models/auth_tokens.dart';

class AuthService {
  AuthClient get _auth => ApiClient.instance.api.auth;

  Future<AuthTokens> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.authControllerLoginV2(
        body: LoginDto(username: email, password: password),
      );

      return AuthTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(message: 'Invalid credentials');
      } else {
        throw ApiException.fromDio(e);
      }
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.authControllerRegisterV2(
        body: CreateUserInput(
          fullName: fullName,
          username: email,
          password: password,
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException(message: e.response?.data['message']);
      } else {
        throw ApiException.fromDio(e);
      }
    }
  }

  /// Revokes the refresh token on the server.
  Future<void> logout(String refreshToken) =>
      _auth.authControllerLogOutV2(refreshToken: refreshToken);
}
