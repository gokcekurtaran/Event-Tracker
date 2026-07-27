import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/paginated_events.dart';


class EventException implements Exception {
  const EventException(
    this.message,
  );

  final String message;

  @override
  String toString() => message;
}


class EventRepository {
  EventRepository(
    this._apiClient,
  );

  final ApiClient _apiClient;

  // Backend'deki bütün aktif kategorileri getirir.
  Future<List<CategoryModel>> getCategories() async {
    try {
      final Response<dynamic> response =
          await _apiClient.dio.get(
        ApiConstants.categories,
      );

      if (response.data is! List) {
        throw const EventException(
          'The server returned an invalid category response.',
        );
      }

      final List<dynamic> categoryList =
          response.data as List<dynamic>;

      return categoryList.map(
        (dynamic item) {
          return CategoryModel.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          );
        },
      ).toList();
    } on DioException catch (error) {
      throw EventException(
        _extractErrorMessage(error),
      );
    }
  }

  // Etkinlikleri sayfalama ve filtre bilgileriyle getirir.
  Future<PaginatedEvents> getEvents({
    int page = 1,
    String? search,
    String? city,
    int? categoryId,
    bool? isFree,
    bool upcoming = true,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'upcoming': upcoming,
      };

      if (
          search != null &&
          search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      if (
          city != null &&
          city.trim().isNotEmpty) {
        queryParameters['city'] = city.trim();
      }

      if (categoryId != null) {
        queryParameters['category'] = categoryId;
      }

      if (isFree != null) {
        queryParameters['is_free'] = isFree;
      }

      final Response<dynamic> response =
          await _apiClient.dio.get(
        ApiConstants.events,
        queryParameters: queryParameters,
      );

      if (response.data is! Map) {
        throw const EventException(
          'The server returned an invalid event response.',
        );
      }

      final Map<String, dynamic> responseData =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final List<dynamic> results =
          responseData['results'] as List<dynamic>? ??
              <dynamic>[];

      final List<EventModel> events = results.map(
        (dynamic item) {
          return EventModel.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          );
        },
      ).toList();

      return PaginatedEvents(
        events: events,
        totalCount: _toInt(
          responseData['count'],
        ),
        currentPage: page,
        hasNextPage: responseData['next'] != null,
      );
    } on DioException catch (error) {
      throw EventException(
        _extractErrorMessage(error),
      );
    }
  }

  String _extractErrorMessage(
    DioException error,
  ) {
    final dynamic responseData = error.response?.data;

    if (responseData is Map) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(responseData);

      final dynamic detail = data['detail'];

      if (detail is List && detail.isNotEmpty) {
        return detail.first.toString();
      }

      if (detail != null) {
        return detail.toString();
      }
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      return 'The connection timed out.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server.';
    }

    return 'Could not load events. Please try again.';
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
    // Seçilen etkinliğin güncel detaylarını backend'den getirir.
  Future<EventModel> getEventDetail(
    int eventId,
  ) async {
    try {
      final Response<dynamic> response =
          await _apiClient.dio.get(
        ApiConstants.eventDetail(eventId),
      );

      return EventModel.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw EventException(
        _extractErrorMessage(error),
      );
    }
  }

  // Katılımcıyı seçilen etkinliğe kaydeder.
  Future<void> joinEvent(
    int eventId,
  ) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.joinEvent(eventId),
      );
    } on DioException catch (error) {
      throw EventException(
        _extractErrorMessage(error),
      );
    }
  }

  // Katılımcının etkinlik kaydını iptal eder.
  Future<void> leaveEvent(
    int eventId,
  ) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.leaveEvent(eventId),
      );
    } on DioException catch (error) {
      throw EventException(
        _extractErrorMessage(error),
      );
    }
  }

  // Etkinliği kullanıcının favorilerine ekler.
  Future<void> addFavorite(
    int eventId,
  ) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.favoriteEvent(eventId),
      );
    } on DioException catch (error) {
      throw EventException(
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
      throw EventException(
        _extractErrorMessage(error),
      );
    }
  }
}