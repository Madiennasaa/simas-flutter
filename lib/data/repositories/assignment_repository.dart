import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/assignment_model.dart';

class AssignmentRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<AssignmentModel>> getAll(int classSubjectId) async {
    try {
      final res = await _dio.get(ApiEndpoints.assignments, queryParameters: {"classSubjectId": classSubjectId});
      final List data = res.data["data"];
      return data.map((e) => AssignmentModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil tugas");
    }
  }

  Future<AssignmentModel> create({
    required int classSubjectId,
    required String title,
    String? description,
    String? attachmentUrl,
    DateTime? dueDate,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.assignments, data: {
        "classSubjectId": classSubjectId,
        "title": title,
        if (description != null) "description": description,
        if (attachmentUrl != null) "attachmentUrl": attachmentUrl,
        if (dueDate != null) "dueDate": dueDate.toIso8601String(),
      });
      return AssignmentModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal membuat tugas");
    }
  }

  Future<AssignmentModel> update(int id, {String? title, String? description, DateTime? dueDate}) async {
    try {
      final res = await _dio.put("${ApiEndpoints.assignments}/$id", data: {
        if (title != null) "title": title,
        if (description != null) "description": description,
        if (dueDate != null) "dueDate": dueDate.toIso8601String(),
      });
      return AssignmentModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal memperbarui tugas");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.assignments}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus tugas");
    }
  }
}
