import 'package:dio/dio.dart';
import '../models/event_report_model.dart';
import '../models/organizer_participant_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../events/models/event_model.dart';
import '../../events/models/paginated_events.dart';


class OrganizerException implements Exception {
  const OrganizerException(
    this.message,
  );

  final String message;

  @override
  String toString() => message;
}


class OrganizerRepository {
  OrganizerRepository(
    this._apiClient,
  );

  final ApiClient _apiClient;

  // Organizatörün oluşturduğu etkinlikleri bütün
  // durumlarıyla backend'den getirir.
  Future<PaginatedEvents> getMyEvents({
    int page = 1,
  }) async {
    try {
      final Response<dynamic> response =
          await _apiClient.dio.get(
        ApiConstants.organizerEvents,
        queryParameters: {
          'page': page,
        },
      );

      if (response.data is! Map) {
        throw const OrganizerException(
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
      throw OrganizerException(
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
    return 'Could not load your events.';
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
    // Yeni etkinliği fotoğraf ve form bilgileriyle backend'e gönderir.
  Future<EventModel> createEvent({
    required String title,
    required String description,
    required String coverImagePath,
    required DateTime startDate,
    required DateTime endDate,
    required String city,
    required String locationName,
    required String address,
    double? latitude,
    double? longitude,
    required int capacity,
    required double price,
    required int categoryId,
    required String status,
  }) async {
    try {
      final String fileName = coverImagePath
          .split(
            RegExp(r'[/\\]'),
          )
          .last;

      final Map<String, dynamic> values = {
        'title': title.trim(),
        'description': description.trim(),
        'cover_image': await MultipartFile.fromFile(
          coverImagePath,
          filename: fileName,
        ),
        'start_date': startDate.toUtc().toIso8601String(),
        'end_date': endDate.toUtc().toIso8601String(),
        'city': city.trim(),
        'location_name': locationName.trim(),
        'address': address.trim(),
        'capacity': capacity,
        'price': price.toStringAsFixed(2),
        'category_id': categoryId,
        'status': status,
      };

      if (latitude != null) {
        values['latitude'] = latitude;
      }

      if (longitude != null) {
        values['longitude'] = longitude;
      }

      final Response<dynamic> response =
          await _apiClient.dio.post(
        ApiConstants.events,
        data: FormData.fromMap(values),
      );

      return EventModel.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw OrganizerException(
        _extractErrorMessage(error),
      );
    }
  }
    // Organizatörün kendi etkinliğine kayıt olan
  // aktif katılımcıları getirir.
  Future<List<OrganizerParticipantModel>>
      getParticipants(
    int eventId,
  ) async {
    try {
      final Response<dynamic> response =
          await _apiClient.dio.get(
        ApiConstants.organizerParticipants(
          eventId,
        ),
      );

      final Map<String, dynamic> responseData =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final List<dynamic> results =
          responseData['results'] as List<dynamic>? ??
              <dynamic>[];

      return results.map(
        (dynamic item) {
          return OrganizerParticipantModel.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          );
        },
      ).toList();
    } on DioException catch (error) {
      throw OrganizerException(
        _extractErrorMessage(error),
      );
    }
  }

  // Organizatörün etkinliğine ait katılım
  // raporunu backend'den getirir.
  Future<EventReportModel> getEventReport(
    int eventId,
  ) async {
    try {
      final Response<dynamic> response =
          await _apiClient.dio.get(
        ApiConstants.organizerReport(
          eventId,
        ),
      );

      return EventReportModel.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw OrganizerException(
        _extractErrorMessage(error),
      );
    }
  }
  // Organizatörün kendisine ait etkinliği günceller.
Future<EventModel> updateEvent({
  required int eventId,
  required String title,
  required String description,
  String? coverImagePath,
  required DateTime startDate,
  required DateTime endDate,
  required String city,
  required String locationName,
  required String address,
  double? latitude,
  double? longitude,
  required int capacity,
  required double price,
  required int categoryId,
  required String status,
}) async {
  try {
    final Map<String, dynamic> values = {
      'title': title.trim(),
      'description': description.trim(),
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate.toUtc().toIso8601String(),
      'city': city.trim(),
      'location_name': locationName.trim(),
      'address': address.trim(),
      'capacity': capacity,
      'price': price.toStringAsFixed(2),
      'category_id': categoryId,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
    };

    // Yeni fotoğraf seçilmişse güncelleme isteğine ekler.
    if (
        coverImagePath != null &&
        coverImagePath.isNotEmpty) {
      final String fileName = coverImagePath
          .split(
            RegExp(r'[/\\]'),
          )
          .last;

      values['cover_image'] =
          await MultipartFile.fromFile(
        coverImagePath,
        filename: fileName,
      );
    }

    final Response<dynamic> response =
        await _apiClient.dio.patch(
      ApiConstants.eventDetail(eventId),
      data: FormData.fromMap(values),
    );

    return EventModel.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  } on DioException catch (error) {
    throw OrganizerException(
      _extractErrorMessage(error),
    );
  }
}
}