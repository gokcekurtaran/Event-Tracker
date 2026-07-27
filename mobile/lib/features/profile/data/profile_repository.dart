import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/models/user_model.dart';


class ProfileException implements Exception {
  const ProfileException(
    this.message,
  );

  final String message;

  @override
  String toString() => message;
}


class ProfileRepository {
  ProfileRepository(
    this._apiClient,
  );

  final ApiClient _apiClient;

  // Kullanıcının profil bilgilerini multipart form ile günceller.
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String city,
    required String bio,
    String? imagePath,
  }) async {
    try {
      final Map<String, dynamic> formValues = {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'city': city.trim(),
        'bio': bio.trim(),
      };

      if (
          imagePath != null &&
          imagePath.isNotEmpty) {
        final String fileName = imagePath
            .split(
              RegExp(r'[/\\]'),
            )
            .last;

        formValues['profile_image'] =
            await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        );
      }

      final FormData formData = FormData.fromMap(
        formValues,
      );

      final Response<dynamic> response =
          await _apiClient.dio.patch(
        ApiConstants.profile,
        data: formData,
      );

      return UserModel.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );
    } on DioException catch (error) {
      throw ProfileException(
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
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        responseData,
      );

      if (data['detail'] != null) {
        return _valueToMessage(
          data['detail'],
        );
      }

      for (final dynamic value in data.values) {
        final String message =
            _valueToMessage(value);

        if (message.isNotEmpty) {
          return message;
        }
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

    return 'Could not update your profile.';
  }

  String _valueToMessage(
    dynamic value,
  ) {
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    if (value is Map && value.isNotEmpty) {
      return _valueToMessage(
        value.values.first,
      );
    }

    return value?.toString() ?? '';
  }
}