import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/subject_model.dart';

class SubjectRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<SubjectModel>> getAll() async {
    try {
      final res = await _dio.get(ApiEndpoints.subjects);
      final List data = res.data["data"];
      return data.map((e) => SubjectModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil data mapel");
    }
  }

  Future<SubjectModel> create({required String subjectName, required String type, double? kkm}) async {
    try {
      final res = await _dio.post(ApiEndpoints.subjects, data: {
        "subjectName": subjectName,
        "type": type,
        if (kkm != null) "kkm": kkm,
      });
      return SubjectModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal membuat mapel");
    }
  }

  Future<SubjectModel> update(int id, {String? subjectName, String? type, double? kkm}) async {
    try {
      final res = await _dio.put("${ApiEndpoints.subjects}/$id", data: {
        if (subjectName != null) "subjectName": subjectName,
        if (type != null) "type": type,
        if (kkm != null) "kkm": kkm,
      });
      return SubjectModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal memperbarui mapel");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.subjects}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus mapel");
    }
  }
}
