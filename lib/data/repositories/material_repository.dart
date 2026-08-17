import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/material_model.dart';

class MaterialRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<MaterialModel>> getAll(int classSubjectId) async {
    try {
      final res = await _dio.get(ApiEndpoints.materials, queryParameters: {"classSubjectId": classSubjectId});
      final List data = res.data["data"];
      return data.map((e) => MaterialModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil materi");
    }
  }

  Future<MaterialModel> create({
    required int classSubjectId,
    required String title,
    String? description,
    required String linkUrl,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.materials, data: {
        "classSubjectId": classSubjectId,
        "title": title,
        if (description != null) "description": description,
        "linkUrl": linkUrl,
      });
      return MaterialModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengunggah materi");
    }
  }

  Future<MaterialModel> update(int id, {String? title, String? description, String? linkUrl}) async {
    try {
      final res = await _dio.put("${ApiEndpoints.materials}/$id", data: {
        if (title != null) "title": title,
        if (description != null) "description": description,
        if (linkUrl != null) "linkUrl": linkUrl,
      });
      return MaterialModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal memperbarui materi");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.materials}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus materi");
    }
  }
}
