import 'package:dio/dio.dart';
import 'package:prokurs/core/exceptions/api_exception.dart';
import 'package:prokurs/core/network/api_client.dart';
import 'package:prokurs/core/network/generated/export.dart';
import 'package:prokurs/features/exchange_points/domain/models/exchange_point.dart';

/// Service for managing exchange points operations
class ExchangePointsService {
  PointsClient get _points => ApiClient.instance.api.points;

  Future<T> _call<T>(Future<T> request) async {
    try {
      return await request;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Get list of exchange points owned by the current user
  Future<List<ExchangePoint>> getMyExchangePointsList() async {
    final points = await _call(_points.pointsV2ControllerFindUserPointsV2());
    return points.map(ExchangePoint.fromPersonal).toList();
  }

  /// Get one exchange point owned by the current user
  Future<ExchangePoint> getMyExchangePoint(num id) async =>
      ExchangePoint.fromPersonal(await _call(
          _points.pointsV2ControllerFindUserPointByIdV2(id: id.toInt())));

  /// Create a new exchange point
  Future<void> createExchangePoint(CreatePointV2Input point) =>
      _call(_points.pointsV2ControllerCreateUserPointV2(body: point));

  /// Replace an existing exchange point: every field of it is overwritten
  Future<void> updateExchangePoint(num id, ReplacePointV2Input point) => _call(
      _points.pointsV2ControllerUpdateUserPointByIdV2(
          id: id.toInt(), body: point));

  /// Delete an exchange point
  Future<void> deleteExchangePoint(num id) =>
      _call(_points.pointsV2ControllerDeleteUserPointByIdV2(id: id.toInt()));
}
