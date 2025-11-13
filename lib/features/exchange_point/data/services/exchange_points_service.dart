import 'package:flutter/cupertino.dart';
import 'package:prokurs/core/network/api_client.dart';
import 'package:prokurs/features/exchange_point/domain/models/exchange_point.dart';

/// Service for managing exchange points operations
class ExchangePointsService {
  // Get ApiClient singleton instance
  final ApiClient _apiClient = ApiClient.instance;

  // API endpoint paths
  static const String _baseEndpoint = 'points';

  /// Get list of exchange points owned by the current user
  Future<List<ExchangePoint>> getMyExchangePointsList() async {
    try {
      final response = await _apiClient.get('$_baseEndpoint/personal');
      return (response.data as List<dynamic>)
          .map((json) => ExchangePoint.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching my exchange points: $e');
      rethrow;
    }
  }

  /// Create a new exchange point
  Future<Map<String, dynamic>> createExchangePoint(
      Map<String, dynamic> pointData) async {
    try {
      final response =
          await _apiClient.post('$_baseEndpoint/personal', data: pointData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error creating exchange point: $e');
      rethrow;
    }
  }

  /// Update an existing exchange point
  Future<Map<String, dynamic>> updateExchangePoint(
      num id, Map<String, dynamic> pointData) async {
    try {
      final response =
          await _apiClient.put('$_baseEndpoint/personal/$id', data: pointData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error updating exchange point: $e');
      rethrow;
    }
  }

  /// Delete an exchange point
  Future<bool> deleteExchangePoint(num id) async {
    try {
      debugPrint('Deleting exchange point: $_baseEndpoint/personal/$id');
      final response = await _apiClient.delete('$_baseEndpoint/personal/$id');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting exchange point: $e');
      rethrow;
    }
  }
}
