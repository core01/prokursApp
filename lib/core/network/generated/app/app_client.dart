// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/public_user_dto.dart';

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
}
