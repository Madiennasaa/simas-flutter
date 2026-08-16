import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/student_model.dart';

class StudentRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<StudentModel>> getAll({int? classId}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.students,
        queryParameters: classId != null ? {"classId": classId} : null,
      );
      final List data = res.data["data"];
      return data.map((e) => StudentModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil data siswa");
    }
  }

  Future<StudentModel> create({
    required String username,
    required String password,
    required String name,
    required String nisn,
    required int classId,
    String? phoneNumber,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.students, data: {
        "username": username,
        "password": password,
        "name": name,
        "nisn": nisn,
        "classId": classId,
        if (phoneNumber != null) "phoneNumber": phoneNumber,
      });
      return StudentModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menambahkan siswa");
    }
  }

  Future<StudentModel> update(int id, {String? name, String? phoneNumber, String? nisn, int? classId}) async {
    try {
      final res = await _dio.put("${ApiEndpoints.students}/$id", data: {
        if (name != null) "name": name,
        if (phoneNumber != null) "phoneNumber": phoneNumber,
        if (nisn != null) "nisn": nisn,
        if (classId != null) "classId": classId,
      });
      return StudentModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal memperbarui data siswa");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.students}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus siswa");
    }
  }
}
