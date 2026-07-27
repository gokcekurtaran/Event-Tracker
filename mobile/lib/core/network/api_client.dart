import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient(
    this._tokenStorage,
  ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          seconds: 15,
        ),
        receiveTimeout: const Duration(
          seconds: 15,
        ),
        sendTimeout: const Duration(
          seconds: 15,
        ),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Her isteğin öncesinde ve hata sonrasında çalışacak
    // interceptor yapısını Dio'ya ekler.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  // Aynı anda birden fazla 401 hatası geldiğinde yalnızca
  // bir token yenileme isteğinin çalışmasını sağlar.
  Completer<bool>? _refreshCompleter;

  // Refresh token da geçersiz olduğunda uygulamaya
  // oturumun sona erdiğini bildirir.
  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  Stream<void> get sessionExpiredStream =>
      _sessionExpiredController.stream;

  Dio get dio => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Güvenli alandaki access token'ı okur.
    final String? accessToken =
        await _tokenStorage.getAccessToken();

    if (
        accessToken != null &&
        accessToken.isNotEmpty) {
      // Token'ı bütün korumalı isteklere otomatik ekler.
      options.headers['Authorization'] =
          'Bearer $accessToken';
    }

    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final bool isUnauthorized =
        error.response?.statusCode == 401;

    final bool isRefreshRequest =
        error.requestOptions.path ==
            ApiConstants.refreshToken;

    // 401 dışındaki hataları normal biçimde iletir.
    if (!isUnauthorized || isRefreshRequest) {
      handler.next(error);
      return;
    }

    final bool refreshSuccessful =
        await _refreshAccessToken();

    if (!refreshSuccessful) {
      // Refresh token da geçersizse cihazdaki token'ları temizler.
      await _tokenStorage.clearTokens();

      // Router'ın kullanıcıyı login ekranına yönlendirmesi
      // için oturum sona erdi bilgisini yayınlar.
      _sessionExpiredController.add(null);

      handler.next(error);
      return;
    }

    try {
      // Güvenli alana kaydedilen yeni access token'ı okur.
      final String? newAccessToken =
          await _tokenStorage.getAccessToken();

      if (newAccessToken == null) {
        handler.next(error);
        return;
      }

      // Başarısız olan ilk isteğin header'ına yeni token'ı ekler.
      error.requestOptions.headers['Authorization'] =
          'Bearer $newAccessToken';

      // İlk isteği yeni access token ile tekrar gönderir.
      final Response<dynamic> response = await _dio.fetch(
        error.requestOptions,
      );

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refreshAccessToken() async {
    // Başka bir istek token yeniliyorsa aynı sonucu bekler.
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final String? refreshToken =
          await _tokenStorage.getRefreshToken();

      if (
          refreshToken == null ||
          refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // Refresh isteği ana Dio interceptor'ına girmesin diye
      // ayrı ve sade bir Dio nesnesi kullanır.
      final Dio refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(
            seconds: 15,
          ),
          receiveTimeout: const Duration(
            seconds: 15,
          ),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final Response<dynamic> response =
          await refreshDio.post(
        ApiConstants.refreshToken,
        data: {
          'refresh': refreshToken,
        },
      );

      final dynamic responseData = response.data;

      if (responseData is! Map) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final String? newAccessToken =
          responseData['access']?.toString();

      final String? newRefreshToken =
          responseData['refresh']?.toString();

      if (
          newAccessToken == null ||
          newAccessToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // Yeni access token'ı güvenli alana kaydeder.
      await _tokenStorage.saveAccessToken(
        newAccessToken,
      );

      // Backend refresh token'ı döndürdüyse eskisinin yerine kaydeder.
      if (
          newRefreshToken != null &&
          newRefreshToken.isNotEmpty) {
        await _tokenStorage.saveRefreshToken(
          newRefreshToken,
        );
      }

      _refreshCompleter!.complete(true);
      return true;
    } on DioException {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      // Bekleyen istekler sonucu aldıktan sonra kilidi kaldırır.
      _refreshCompleter = null;
    }
  }
}