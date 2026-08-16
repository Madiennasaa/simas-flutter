import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/school_class_model.dart';

class ClassRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<SchoolClassModel>> getAll() async {
    try {
      final res = await _dio.get(ApiEndpoints.classes);
      final List data = res.data["data"];
      return data.map((e) => SchoolClassModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil data kelas");
    }
  }

  Future<SchoolClassModel> create({
    required String className,
    required int gradeLevel,
    required String phase,
    int? homeroomTeacherId,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.classes, data: {
        "className": className,
        "gradeLevel": gradeLevel,
        "phase": phase,
        if (homeroomTeacherId != null) "homeroomTeacherId": homeroomTeacherId,
      });
      return SchoolClassModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal membuat kelas");
    }
  }

  // Partial update: cuma field yang diisi (non-null) yang dikirim,
  // sesuai backend yang sekarang udah PATCH-style.
  Future<SchoolClassModel> update(
    int id, {
    String? className,
    int? gradeLevel,
    String? phase,
    int? homeroomTeacherId,
  }) async {
    try {
      final res = await _dio.put("${ApiEndpoints.classes}/$id", data: {
        if (className != null) "className": className,
        if (gradeLevel != null) "gradeLevel": gradeLevel,
        if (phase != null) "phase": phase,
        if (homeroomTeacherId != null) "homeroomTeacherId": homeroomTeacherId,
      });
      return SchoolClassModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal memperbarui kelas");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.classes}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus kelas");
    }
  }
}
