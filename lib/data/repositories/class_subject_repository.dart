import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/class_subject_model.dart';

class ClassSubjectRepository {
  final _dio = ApiClient.instance.dio;

  /// Kalau login sebagai guru, backend otomatis filter cuma penugasan dia sendiri
  /// (gak perlu kirim teacherId manual dari sini).
  Future<List<ClassSubjectModel>> getAll({int? classId, int? academicYearId}) async {
    try {
      final res = await _dio.get(ApiEndpoints.classSubjects, queryParameters: {
        if (classId != null) "classId": classId,
        if (academicYearId != null) "academicYearId": academicYearId,
      });
      final List data = res.data["data"];
      return data.map((e) => ClassSubjectModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil data penugasan");
    }
  }

  Future<ClassSubjectModel> create({
    required int classId,
    required int subjectId,
    required int teacherId,
    required int academicYearId,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.classSubjects, data: {
        "classId": classId,
        "subjectId": subjectId,
        "teacherId": teacherId,
        "academicYearId": academicYearId,
      });
      return ClassSubjectModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal membuat penugasan guru");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.classSubjects}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus penugasan");
    }
  }
}
