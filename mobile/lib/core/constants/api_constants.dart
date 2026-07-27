class ApiConstants {
  ApiConstants._();

  // Telefondan bilgisayardaki Django sunucusuna ulaşır.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.142:8000',
  );

  // Kullanıcı işlemlerinde kullanılan endpoint'ler
  static const String register = '/api/auth/register/';
  static const String participantLogin =
      '/api/auth/participant/login/';
  static const String organizerLogin =
      '/api/auth/organizer/login/';
  static const String refreshToken = '/api/auth/refresh/';
  static const String logout = '/api/auth/logout/';
  static const String profile = '/api/auth/profile/';

  // Kategori ve etkinlik endpoint'leri
  static const String categories = '/api/categories/';
  static const String events = '/api/events/';
  static const String organizerEvents = '/api/events/my-events/';

  // Katılım ve favori endpoint'leri
  static const String myAttendances = '/api/me/attendances/';
  static const String myFavorites = '/api/me/favorites/';

  static String eventDetail(int eventId) {
    return '/events/$eventId/';
  }

  static String joinEvent(int eventId) {
    return '/events/$eventId/join/';
  }

  static String leaveEvent(int eventId) {
    return '/events/$eventId/leave/';
  }

  static String favoriteEvent(int eventId) {
    return '/events/$eventId/favorite/';
  }

  static String organizerParticipants(int eventId) {
    return '/organizer/events/$eventId/participants/';
  }

  static String organizerReport(int eventId) {
    return '/organizer/events/$eventId/report/';
  }
}