import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/announcement_model.dart';

class AnnouncementRepository {
  final _dio = ApiClient.instance.dio;

  /// Backend otomatis filter sesuai role user yang login, gak perlu kirim parameter apa-apa.
  Future<List<AnnouncementModel>> getAll() async {
    try {
      final res = await _dio.get(ApiEndpoints.announcements);
      final List data = res.data["data"];
      return data.map((e) => AnnouncementModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil pengumuman");
    }
  }

  Future<AnnouncementModel> create({required String title, required String content, String? targetRole}) async {
    try {
      final res = await _dio.post(ApiEndpoints.announcements, data: {
        "title": title,
        "content": content,
        if (targetRole != null) "targetRole": targetRole,
      });
      return AnnouncementModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal membuat pengumuman");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.announcements}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus pengumuman");
    }
  }
}
