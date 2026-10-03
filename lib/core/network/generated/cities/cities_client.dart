// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/points_rates_with_bests_and_nb_rates_dto.dart';
import '../models/public_city_dto.dart';
import '../models/sort_by.dart';

part 'cities_client.g.dart';

@RestApi()
abstract class CitiesClient {
  factory CitiesClient(Dio dio, {String? baseUrl}) = _CitiesClient;

  @GET('/v2/cities')
  Future<List<PublicCityDto>> citiesControllerFindAllV2();

  /// Find all points for a city.
  ///
  /// Returns a list of exchange points, best rates, and national bank rates for the specified city.
  ///
  /// [id] - City ID.
  ///
  /// [sortBy] - Sorting criteria.
  @GET('/v2/cities/{id}/points')
  Future<PointsRatesWithBestsAndNbRatesDto> citiesControllerGetPointsV2({
    @Path('id') required int id,
    @Query('sortBy') SortBy? sortBy,
  });
}
