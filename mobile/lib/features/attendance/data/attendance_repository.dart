import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/attendance_model.dart';


class AttendanceException implements Exception {
  const AttendanceException(
    this.message,
  );

  final String message;

  @override
  String toString() => message;
}


class AttendanceRepository {
  AttendanceRepository(
    this._apiClient,
  );

  final ApiClient _apiClient;

  // Kullanıcının aktif katılım kayıtlarını backend'den getirir.
  Future<List<AttendanceModel>>
      getMyAttendances() async {
    try {
      final Response<dynamic> response =
          await _apiClient.dio.get(
        ApiConstants.myAttendances,
      );

      if (response.data is! Map) {
        throw const AttendanceException(
          'The server returned an invalid attendance response.',
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
          return AttendanceModel.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          );
        },
      ).toList();
    } on DioException catch (error) {
      throw AttendanceException(
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
}