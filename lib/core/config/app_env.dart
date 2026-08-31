/// Konfigurasi environment (staging vs production), dibaca dari
/// --dart-define saat build/run. Default ke staging kalau tidak
/// di-define, biar developer lokal tidak ke-nyasar ke API production
/// secara tidak sengaja.
///
/// Cara pakai:
///   Staging (default, buat debug harian):
///     flutter run --dart-define=ENV=staging
///
///   Production (buat rilis final):
///     flutter build apk --release --dart-define=ENV=production
class AppEnv {
  AppEnv._();

  static const String name =
      String.fromEnvironment('ENV', defaultValue: 'staging');

  static bool get isStaging => name == 'staging';
  static bool get isProduction => name == 'production';

  /// Base URL API per environment. Ganti sesuai domain staging/production
  /// kamu di GitHub/hosting (mis. subdomain terpisah untuk staging).
  static const String _stagingApiUrl = String.fromEnvironment(
    'API_BASE_URL_STAGING',
    defaultValue: 'https://simasapistaging1-lavr0tj0.b4a.run/api',
  );

  static const String _productionApiUrl = String.fromEnvironment(
    'API_BASE_URL_PRODUCTION',
    defaultValue: 'https://api.simas-sukorame.my.id/api',
  );

  static String get apiBaseUrl =>
      isProduction ? _productionApiUrl : _stagingApiUrl;

  /// Label kecil buat ditampilkan di UI (misal ribbon "STAGING") biar
  /// gampang dibedain dari build production waktu testing di HP.
  static String get label => isProduction ? 'PRODUCTION' : 'STAGING';
}
