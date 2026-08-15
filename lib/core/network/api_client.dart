import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';

/// Dipakai buat komunikasi ke backend Express. Satu instance dipakai
/// di seluruh app lewat ApiClient.instance, biar interceptor token
/// gak perlu dipasang ulang-ulang di tiap repository.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Tempelin token JWT ke tiap request kalau ada, kecuali endpoint login
          final token = await _storage.read(key: _tokenKey);
          if (token != null && !options.path.contains(ApiEndpoints.login)) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Token expired/invalid -> hapus token tersimpan.
          // UI (auth_provider) yang nentuin redirect ke login, bukan di sini,
          // supaya ApiClient gak perlu tau soal navigasi.
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: _tokenKey);
          }
          return handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = "auth_token";

  Dio get dio => _dio;

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
