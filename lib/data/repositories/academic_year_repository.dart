import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/academic_year_model.dart';

class AcademicYearRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<AcademicYearModel>> getAll() async {
    try {
      final res = await _dio.get(ApiEndpoints.academicYears);
      final List data = res.data["data"];
      return data.map((e) => AcademicYearModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil data tahun ajaran");
    }
  }

  Future<AcademicYearModel> create(String year, String semester) async {
    try {
      final res = await _dio.post(ApiEndpoints.academicYears, data: {"year": year, "semester": semester});
      return AcademicYearModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal membuat tahun ajaran");
    }
  }

  /// Aktifin tahun ajaran ini, backend otomatis ngunci yang sebelumnya aktif.
  Future<AcademicYearModel> setActive(int id) async {
    try {
      final res = await _dio.patch(ApiEndpoints.academicYearSetActive(id));
      return AcademicYearModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengganti semester aktif");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.academicYears}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus tahun ajaran");
    }
  }
}
