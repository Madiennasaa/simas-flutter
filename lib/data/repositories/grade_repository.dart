import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/grade_model.dart';

class GradeRepository {
  final _dio = ApiClient.instance.dio;

  /// Dipakai guru: submit nilai satu kelas sekaligus untuk satu jenis nilai
  Future<List<GradeModel>> bulkCreate({
    required int classSubjectId,
    required String scoreType,
    required List<GradeRecordInput> records,
    int? assignmentId,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.grades, data: {
        "classSubjectId": classSubjectId,
        "scoreType": scoreType,
        "records": records.map((r) => r.toJson()).toList(),
        if (assignmentId != null) "assignmentId": assignmentId,
      });
      final List data = res.data["data"];
      return data.map((e) => GradeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menyimpan nilai");
    }
  }

  /// Dipakai siswa: lihat nilai sendiri
  Future<List<GradeModel>> myGrades(int academicYearId) async {
    try {
      final res = await _dio.get(ApiEndpoints.gradesMe, queryParameters: {"academicYearId": academicYearId});
      final List data = res.data["data"];
      return data.map((e) => GradeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil nilai");
    }
  }

  /// Dipakai wali murid: lihat nilai salah satu anaknya
  Future<List<GradeModel>> childGrades(int studentId, int academicYearId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.gradesChild(studentId),
        queryParameters: {"academicYearId": academicYearId},
      );
      final List data = res.data["data"];
      return data.map((e) => GradeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil nilai anak");
    }
  }

  /// Dipakai guru/admin/kepsek: rekap nilai satu kelas-mapel
  Future<List<GradeModel>> byClassSubject(int classSubjectId, {String? scoreType}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.gradesByClassSubject(classSubjectId),
        queryParameters: scoreType != null ? {"scoreType": scoreType} : null,
      );
      final List data = res.data["data"];
      return data.map((e) => GradeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil rekap nilai");
    }
  }
}
