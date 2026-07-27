import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/favorite_model.dart';

class FavoriteException implements Exception {
  const FavoriteException(
    this.message,
  );

  final String message;

  @override
  String toString() => message;
}

class FavoriteRepository {
  FavoriteRepository(
    this._apiClient,
  );

  final ApiClient _apiClient;

  // Kullanıcının favori etkinliklerini backend'den getirir.
  Future<List<FavoriteModel>> getFavorites() async {
    try {
      final Response<dynamic> response =
          await _apiClient.dio.get(
        ApiConstants.myFavorites,
      );

      if (response.data is! Map) {
        throw const FavoriteException(
          'The server returned an invalid favorites response.',
        );
      }

      final Map<String, dynamic> responseData =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final List<dynamic> results =
          responseData['results'] as List<dynamic>? ??
              <dynamic>[];

      return results.map(
        (dynamic item) {
          return FavoriteModel.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          );
        },
      ).toList();
    } on DioException catch (error) {
      throw FavoriteException(
        _extractErrorMessage(error),
      );
    }
  }

  // Etkinliği kullanıcının favorilerinden çıkarır.
  Future<void> removeFavorite(
    int eventId,
  ) async {
    try {
      await _apiClient.dio.delete(
        ApiConstants.favoriteEvent(eventId),
      );
    } on DioException catch (error) {
      throw FavoriteException(
        _extractErrorMessage(error),
      );
    }
  }

  String _extractErrorMessage(
    DioException error,
  ) {
    final dynamic responseData =
        error.response?.data;

    if (responseData is Map) {
      final dynamic detail =
          responseData['detail'];

      if (detail is List && detail.isNotEmpty) {
        return detail.first.toString();
      }

      if (detail != null) {
        return detail.toString();
      }
    }

    if (
        error.type ==
        DioExceptionType.connectionTimeout) {
      return 'The connection timed out.';
    }
    if (
        error.type ==
        DioExceptionType.connectionError) {
      return 'Could not connect to the server.';
    }

    return 'Could not load favorite events.';
  }
}