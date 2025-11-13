import 'package:dio/dio.dart';
import 'package:prokurs/core/exceptions/conflict_exception.dart';
import 'package:prokurs/core/exceptions/unauthorized_exception.dart';
import 'package:prokurs/core/exceptions/api_exception.dart';
import 'package:prokurs/core/network/api_client.dart';
import 'package:prokurs/features/auth/domain/models/auth_tokens.dart';

class AuthService {
  Future<AuthTokens> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        'auth/login',
        data: {
          'username': email,
          'password': password,
        },
      );

      return AuthTokens.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(message: 'Invalid credentials');
      } else {
        throw ApiException(
          message: 'Failed to sign in',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      }
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        'auth/register',
        data: {
          'fullName': fullName,
          'username': email,
          'password': password,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException(message: e.response?.data['message']);
      } else {
        throw ApiException(
          message: 'Failed to sign up',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      }
    }
  }
}
