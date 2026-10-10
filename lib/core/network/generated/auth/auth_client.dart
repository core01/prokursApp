// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/change_password_input.dart';
import '../models/create_user_input.dart';
import '../models/login_dto.dart';
import '../models/login_response_dto.dart';
import '../models/public_user_dto.dart';
import '../models/refresh_response_dto.dart';
import '../models/reset_password_dto.dart';
import '../models/success_response_dto.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  /// Register a new user
  @POST('/v2/auth/register')
  Future<PublicUserDto> authControllerRegisterV2({
    @Body() required CreateUserInput body,
  });

  /// Login with username and password
  @POST('/v2/auth/login')
  Future<LoginResponseDto> authControllerLoginV2({
    @Body() required LoginDto body,
  });

  /// Confirm email address.
  ///
  /// [token] - Confirmation token.
  @GET('/v2/auth/confirm')
  Future<SuccessResponseDto> authControllerConfirmV2({
    @Query('token') required String token,
  });

  /// Resend confirmation email
  @POST('/v2/auth/resend-confirmation-link')
  Future<SuccessResponseDto> authControllerResendConfirmationLinkV2();

  /// Logout user: revokes the presented refresh token.
  ///
  /// [refreshToken] - Refresh token to revoke.
  @POST('/v2/auth/log-out')
  Future<void> authControllerLogOutV2({
    @Header('refresh-token') required String refreshToken,
  });

  /// Change the password; signs out the other devices
  @POST('/v2/auth/change-password')
  Future<LoginResponseDto> authControllerChangePasswordV2({
    @Body() required ChangePasswordInput body,
  });

  /// Refresh access token.
  ///
  /// [refreshToken] - Refresh token.
  @POST('/v2/auth/refresh')
  Future<RefreshResponseDto> authControllerRefreshV2({
    @Header('refresh-token') required String refreshToken,
  });

  /// Confirm password reset token.
  ///
  /// [token] - Reset password confirmation token.
  @GET('/v2/auth/reset')
  Future<SuccessResponseDto> authControllerResetPasswordConfirmV2({
    @Query('token') required String token,
  });

  /// Request password reset
  @POST('/v2/auth/reset')
  Future<SuccessResponseDto> authControllerResetPasswordV2({
    @Body() required ResetPasswordDto body,
  });
}
