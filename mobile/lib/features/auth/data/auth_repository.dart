import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';


class AuthException implements Exception {
  const AuthException(
    this.message,
  );

  final String message;

  @override
  String toString() => message;
}


class AuthRepository {
  AuthRepository(
    this._apiClient,
    this._tokenStorage,
  );

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  // Katılımcı hesabıyla giriş yapar.
  Future<UserModel> participantLogin({
  required String email,
  required String password,
  }) {
  return _login(
    endpoint: ApiConstants.participantLogin,
    email: email,
    password: password,
    loginMode: 'participant',
  );
}

  // Organizatör hesabıyla giriş yapar.
  Future<UserModel> organizerLogin({
  required String email,
  required String password,
  }) {
  return _login(
    endpoint: ApiConstants.organizerLogin,
    email: email,
    password: password,
    loginMode: 'organizer',
  );
}

  Future<UserModel> _login({
  required String endpoint,
  required String email,
  required String password,
  required String loginMode,
  }) async {
  try {
    print(endpoint);
    final Response<dynamic> response =
        await _apiClient.dio.post(
      endpoint,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final UserModel user =
        await _saveAuthenticationResponse(
      response.data,
    );

    await _tokenStorage.saveLoginMode(
      loginMode,
    );

    return user.copyWith(
      loginMode: loginMode,
    );
  } on DioException catch (error) {
    throw AuthException(
      _extractErrorMessage(error),
    );
  }
}

  // Yeni katılımcı hesabı oluşturur.
  // Yeni katılımcı hesabı oluşturur.
Future<UserModel> register({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String confirmPassword,
}) async {
  try {
    // Kullanıcı bilgilerini kayıt endpoint'ine gönderir.
    final Response<dynamic> response =
        await _apiClient.dio.post(
      ApiConstants.register,
      data: {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'confirm_password': confirmPassword,
      },
    );

    // Backend'den dönen token ve kullanıcı
    // bilgilerini ayrıştırıp güvenli alana kaydeder.
    final UserModel user =
        await _saveAuthenticationResponse(
      response.data,
    );

    // Uygulama üzerinden kayıt olan kullanıcı
    // katılımcı modunda oturum açar.
    await _tokenStorage.saveLoginMode(
      'participant',
    );

    return user.copyWith(
      loginMode: 'participant',
    );
  } on DioException catch (error) {
    throw AuthException(
      _extractErrorMessage(error),
    );
  }
}

  // Access token'a ait kullanıcı profilini getirir.
  Future<UserModel> getProfile() async {
    try {
      final Response<dynamic> response =
          await _apiClient.dio.get(
        ApiConstants.profile,
      );

      final Map<String, dynamic> data =
          _convertToStringMap(response.data);

      return UserModel.fromJson(data);
    } on DioException catch (error) {
      throw AuthException(
        _extractErrorMessage(error),
      );
    }
  }

  // Refresh token'ı backend'de geçersiz kılar ve token'ları siler.
  Future<void> logout() async {
    final String? refreshToken =
        await _tokenStorage.getRefreshToken();

    try {
      if (
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        await _apiClient.dio.post(
          ApiConstants.logout,
          data: {
            'refresh': refreshToken,
          },
        );
      }
    } on DioException {
      // Backend'e ulaşılamasa bile cihazdaki token'lar temizlenir.
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  Future<UserModel> _saveAuthenticationResponse(
    dynamic responseData,
  ) async {
    final Map<String, dynamic> data =
        _convertToStringMap(responseData);

    final String? accessToken =
        data['access']?.toString();

    final String? refreshToken =
        data['refresh']?.toString();

    final dynamic userData = data['user'];

    if (
        accessToken == null ||
        refreshToken == null ||
        userData is! Map) {
      throw const AuthException(
        'The server returned an invalid authentication response.',
      );
    }

    // Giriş veya kayıt sonucunda gelen token'ları güvenli alana kaydeder.
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return UserModel.fromJson(
      Map<String, dynamic>.from(userData),
    );
  }

  Map<String, dynamic> _convertToStringMap(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw const AuthException(
      'The server returned an invalid response.',
    );
  }

  String _extractErrorMessage(
    DioException error,
  ) {
    final dynamic responseData = error.response?.data;

    if (responseData is Map) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(responseData);

      if (data['detail'] != null) {
        return _valueToMessage(
          data['detail'],
        );
      }

      // Serializer tarafından döndürülen ilk hata mesajını bulur.
      for (final dynamic value in data.values) {
        final String message = _valueToMessage(value);

        if (message.isNotEmpty) {
          return message;
        }
      }
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      return 'The connection timed out.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server.';
    }

    return 'Something went wrong. Please try again.';
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