import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage =
            secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _loginModeKey = 'login_mode';

  // Access ve refresh token'ları güvenli alana kaydeder.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(
        key: _accessTokenKey,
        value: accessToken,
      ),
      _secureStorage.write(
        key: _refreshTokenKey,
        value: refreshToken,
      ),
    ]);
  }

  // Yeni access token'ı kaydeder.
  Future<void> saveAccessToken(
    String accessToken,
  ) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: accessToken,
    );
  }

  // Yeni refresh token'ı kaydeder.
  Future<void> saveRefreshToken(
    String refreshToken,
  ) async {
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );
  }

  // Kayıtlı access token'ı döndürür.
  Future<String?> getAccessToken() {
    return _secureStorage.read(
      key: _accessTokenKey,
    );
  }

  // Kayıtlı refresh token'ı döndürür.
  Future<String?> getRefreshToken() {
    return _secureStorage.read(
      key: _refreshTokenKey,
    );
  }

  // Cihazda access token bulunup bulunmadığını kontrol eder.
  Future<bool> hasAccessToken() async {
    final String? accessToken = await getAccessToken();

    return accessToken != null && accessToken.isNotEmpty;
  }
  // Kullanıcının participant veya organizer
// giriş türünü güvenli alana kaydeder.
Future<void> saveLoginMode(
  String loginMode,
) async {
  await _secureStorage.write(
    key: _loginModeKey,
    value: loginMode,
  );
}

// Kullanıcının en son giriş yaptığı uygulama modunu döndürür.
Future<String?> getLoginMode() {
  return _secureStorage.read(
    key: _loginModeKey,
  );
}

  // Kullanıcı çıkış yaptığında bütün token'ları temizler.
  Future<void> clearTokens() async {
  await Future.wait([
    _secureStorage.delete(
      key: _accessTokenKey,
    ),
    _secureStorage.delete(
      key: _refreshTokenKey,
    ),
    _secureStorage.delete(
      key: _loginModeKey,
    ),
  ]);
}
}