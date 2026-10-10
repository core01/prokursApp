// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/public_user_dto.dart';
import '../models/update_organization_input.dart';
import '../models/update_profile_input.dart';

part 'app_client.g.dart';

@RestApi()
abstract class AppClient {
  factory AppClient(Dio dio, {String? baseUrl}) = _AppClient;

  /// API welcome message
  @GET('/v2')
  Future<String> appControllerGetHelloV2();

  /// Get the authenticated user profile
  @GET('/v2/profile')
  Future<PublicUserDto> appControllerGetProfileV2();

  /// Update the authenticated user's first and last name
  @PATCH('/v2/profile')
  Future<PublicUserDto> appControllerUpdateProfileV2({
    @Body() required UpdateProfileInput body,
  });

  /// Update the authenticated user's organization (legal entity) and its license
  @PATCH('/v2/profile/organization')
  Future<PublicUserDto> appControllerUpdateOrganizationV2({
    @Body() required UpdateOrganizationInput body,
  });
}
