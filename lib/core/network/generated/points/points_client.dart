// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_point_v2_input.dart';
import '../models/personal_point_v2_dto.dart';
import '../models/public_point_v2_dto.dart';
import '../models/replace_point_v2_input.dart';
import '../models/success_response_dto.dart';

part 'points_client.g.dart';

@RestApi()
abstract class PointsClient {
  factory PointsClient(Dio dio, {String? baseUrl}) = _PointsClient;

  @GET('/v2/points/personal')
  Future<List<PersonalPointV2Dto>> pointsV2ControllerFindUserPointsV2();

  @POST('/v2/points/personal')
  Future<PersonalPointV2Dto> pointsV2ControllerCreateUserPointV2({
    @Body() required CreatePointV2Input body,
  });

  @GET('/v2/points/personal/{id}')
  Future<PersonalPointV2Dto> pointsV2ControllerFindUserPointByIdV2({
    @Path('id') required int id,
  });

  @DELETE('/v2/points/personal/{id}')
  Future<SuccessResponseDto> pointsV2ControllerDeleteUserPointByIdV2({
    @Path('id') required int id,
  });

  @PUT('/v2/points/personal/{id}')
  Future<PersonalPointV2Dto> pointsV2ControllerUpdateUserPointByIdV2({
    @Path('id') required int id,
    @Body() required ReplacePointV2Input body,
  });

  /// Get a single published exchange point by id
  @GET('/v2/points/{id}')
  Future<PublicPointV2Dto> pointsV2ControllerFindPublicPointByIdV2({
    @Path('id') required int id,
  });
}
