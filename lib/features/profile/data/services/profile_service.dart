import 'package:dio/dio.dart';
import 'package:prokurs/core/exceptions/api_exception.dart';
import 'package:prokurs/core/network/api_client.dart';
import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/features/profile/domain/models/user_profile.dart';

/// The signed-in user's profile and organization (API v2).
class ProfileService {
  AppClient get _app => ApiClient.instance.api.app;

  Future<T> _call<T>(Future<T> request) async {
    try {
      return await request;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UserProfile> getProfile() async =>
      UserProfile.fromDto(await _call(_app.appControllerGetProfileV2()));

  /// Saves the organization. The answer is the profile as stored (the phone and the БИН are
  /// normalized by the server).
  Future<UserProfile> saveOrganization(UpdateOrganizationInput input) async =>
      UserProfile.fromDto(
          await _call(_app.appControllerUpdateOrganizationV2(body: input)));
}
