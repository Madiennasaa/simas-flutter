import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/teacher_model.dart';

class TeacherRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<TeacherModel>> getAll() async {
    try {
      final res = await _dio.get(ApiEndpoints.teachers);
      final List data = res.data["data"];
      return data.map((e) => TeacherModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil data guru");
    }
  }

  Future<TeacherModel> create({
    required String username,
    required String password,
    required String name,
    required String teacherType,
    String? nip,
    String? phoneNumber,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.teachers, data: {
        "username": username,
        "password": password,
        "name": name,
        "teacherType": teacherType,
        if (nip != null) "nip": nip,
        if (phoneNumber != null) "phoneNumber": phoneNumber,
      });
      return TeacherModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menambahkan guru");
    }
  }

  Future<TeacherModel> update(int id, {String? name, String? phoneNumber, String? nip, String? teacherType}) async {
    try {
      final res = await _dio.put("${ApiEndpoints.teachers}/$id", data: {
        if (name != null) "name": name,
        if (phoneNumber != null) "phoneNumber": phoneNumber,
        if (nip != null) "nip": nip,
        if (teacherType != null) "teacherType": teacherType,
      });
      return TeacherModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal memperbarui data guru");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.teachers}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus guru");
    }
  }
}
