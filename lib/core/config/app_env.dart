/// Konfigurasi environment (local / staging / production), dibaca dari
/// --dart-define saat build/run. Default ke staging kalau tidak
/// di-define, biar developer lokal tidak ke-nyasar ke API production
/// secara tidak sengaja.
///
/// Cara pakai:
///   Local (develop harian, backend WSL via `adb reverse tcp:3000 tcp:3000`):
///     flutter run --dart-define=ENV=local
///
///   Staging (tes ke backend cloud/Back4app):
///     flutter run --dart-define=ENV=staging
///
///   Production (buat rilis final):
///     flutter build apk --release --dart-define=ENV=production
class AppEnv {
  AppEnv._();

  static const String name =
      String.fromEnvironment('ENV', defaultValue: 'staging');

  static bool get isLocal => name == 'local';
  static bool get isStaging => name == 'staging';
  static bool get isProduction => name == 'production';

  // Backend WSL lokal. Sebelum run dengan ENV=local, pastikan:
  //   1. Backend jalan di WSL (`npm run dev`, dengar di 0.0.0.0:3000)
  //   2. `adb reverse tcp:3000 tcp:3000` sudah dijalankan (HP via USB)
  static const String _localApiUrl = String.fromEnvironment(
    'API_BASE_URL_LOCAL',
    defaultValue: 'http://localhost:3000/api',
  );

  /// Base URL API per environment. Ganti sesuai domain staging/production
  /// kamu di GitHub/hosting (mis. subdomain terpisah untuk staging).
  static const String _stagingApiUrl = String.fromEnvironment(
    'API_BASE_URL_STAGING',
    defaultValue: 'https://simasapistaging1-qky5g6l0.b4a.run//api',
  );

  static const String _productionApiUrl = String.fromEnvironment(
    'API_BASE_URL_PRODUCTION',
    defaultValue: 'https://api.simas-sukorame.my.id/api',
  );

  static String get apiBaseUrl {
    if (isLocal) return _localApiUrl;
    if (isProduction) return _productionApiUrl;
    return _stagingApiUrl;
  }

  /// Label kecil buat ditampilkan di UI (misal ribbon "LOCAL"/"STAGING")
  /// biar gampang dibedain build mana yang lagi jalan.
  static String get label {
    if (isLocal) return 'LOCAL';
    if (isProduction) return 'PRODUCTION';
    return 'STAGING';
  }
}
