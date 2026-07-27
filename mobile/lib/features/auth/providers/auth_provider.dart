import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../../events/providers/event_detail_provider.dart';
import '../../events/providers/event_provider.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  StreamSubscription<void>? _sessionSubscription;

  @override
  Future<UserModel?> build() async {
    final tokenStorage = ref.read(tokenStorageProvider);

    final apiClient = ref.read(apiClientProvider);

    // Refresh token geçersiz olduğunda oturumu kapatır
    // ve kullanıcıya ait önbelleğe alınmış verileri temizler.
    _sessionSubscription ??= apiClient.sessionExpiredStream.listen((_) {
      _clearUserData();
      state = const AsyncData(null);
    });

    ref.onDispose(() {
      _sessionSubscription?.cancel();
    });

    final bool hasToken = await tokenStorage.hasAccessToken();

    if (!hasToken) {
      return null;
    }

    try {
      // Uygulama yeniden açıldığında profili
      // kayıtlı token ile getirir.
      return await ref.read(authRepositoryProvider).getProfile();
    } on AuthException {
      await tokenStorage.clearTokens();
      _clearUserData();
      return null;
    }
  }

  Future<bool> participantLogin({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final UserModel user = await ref
          .read(authRepositoryProvider)
          .participantLogin(email: email, password: password);

      // Önceki hesaptan kalan ekran verilerini temizler.
      _clearUserData();

      state = AsyncData(user);
      return true;
    } on AuthException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return false;
    }
  }

  Future<bool> organizerLogin({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final UserModel user = await ref
          .read(authRepositoryProvider)
          .organizerLogin(email: email, password: password);

      // Önceki hesaptan kalan ekran verilerini temizler.
      _clearUserData();

      state = AsyncData(user);
      return true;
    } on AuthException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AsyncLoading();

    try {
      final UserModel user = await ref
          .read(authRepositoryProvider)
          .register(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
          );

      // Önceki oturumdan kalan verileri temizler.
      _clearUserData();

      state = AsyncData(user);
      return true;
    } on AuthException catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      // Kullanıcı değişmeden önce bütün kullanıcıya
      // özel provider verilerini temizler.
      _clearUserData();

      state = const AsyncData(null);
    }
  }

  // Kullanıcıya özel önbelleğe alınmış verileri temizler.
  void _clearUserData() {
    ref.invalidate(eventsProvider);
    ref.invalidate(eventDetailProvider);
  }

  // Hata gösterildikten sonra giriş ekranının
  // normal durumuna dönmesini sağlar.
  void clearError() {
    if (state.hasError) {
      state = const AsyncData(null);
    }
  }

  // Profil güncellendiğinde yeni kullanıcı bilgisini
  // uygulamanın tamamına aktarır.
  void updateCurrentUser(UserModel user) {
    final UserModel? currentUser = state.value;

    // Profil güncellenirken kullanıcının seçtiği
    // participant veya organizer modunu korur.
    state = AsyncData(
      user.copyWith(loginMode: currentUser?.loginMode ?? user.loginMode),
    );
  }
}
