import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final _dio = ApiClient.instance.dio;

  /// Dipakai guru: submit absensi satu kelas sekaligus untuk satu tanggal.
  Future<List<AttendanceModel>> bulkCreate({
    required int classSubjectId,
    required DateTime date,
    required List<AttendanceRecordInput> records,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.attendanceBulk, data: {
        "classSubjectId": classSubjectId,
        "date": date.toIso8601String().split("T").first, // format YYYY-MM-DD
        "records": records.map((r) => r.toJson()).toList(),
      });
      final List data = res.data["data"];
      return data.map((e) => AttendanceModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menyimpan absensi");
    }
  }

  /// Dipakai siswa: lihat riwayat absensi diri sendiri
  Future<List<AttendanceModel>> myAttendance(int academicYearId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.attendanceMe,
        queryParameters: {"academicYearId": academicYearId},
      );
      final List data = res.data["data"];
      return data.map((e) => AttendanceModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil data absensi");
    }
  }

  /// Dipakai wali murid: lihat absensi salah satu anaknya
  Future<List<AttendanceModel>> childAttendance(int studentId, int academicYearId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.attendanceChild(studentId),
        queryParameters: {"academicYearId": academicYearId},
      );
      final List data = res.data["data"];
      return data.map((e) => AttendanceModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil data absensi anak");
    }
  }

  /// Dipakai kepala sekolah/admin: rekap persentase kehadiran per kelas
  Future<Map<String, dynamic>> classSummary(int classId, int academicYearId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.attendanceSummary(classId),
        queryParameters: {"academicYearId": academicYearId},
      );
      return res.data["data"];
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil rekap absensi");
    }
  }
}
