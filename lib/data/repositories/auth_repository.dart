import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _client = ApiClient.instance;

  /// Return UserModel kalau sukses. Throw Exception dengan pesan dari backend
  /// kalau gagal (backend selalu balikin { success, message, ... }).
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.login,
        data: {"username": username, "password": password},
      );

      final data = response.data["data"];
      final token = data["token"];
      await _client.saveToken(token);

      return UserModel.fromJson(data["user"]);
    } on DioException catch (e) {
      final message = e.response?.data?["message"] ?? "Gagal terhubung ke server";
      throw Exception(message);
    }
  }

  /// Dipanggil saat app dibuka, buat cek token tersimpan masih valid atau tidak.
  Future<UserModel?> getCurrentUser() async {
    final token = await _client.getToken();
    if (token == null) return null;

    try {
      final response = await _client.dio.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data["data"]);
    } on DioException {
      // Token invalid/expired, interceptor sudah hapus token-nya
      return null;
    }
  }

  Future<void> logout() async {
    await _client.clearToken();
  }
}
