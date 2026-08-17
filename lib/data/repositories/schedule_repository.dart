import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final _dio = ApiClient.instance.dio;

  Future<List<ScheduleModel>> getAll({int? classId, int? classSubjectId}) async {
    try {
      final res = await _dio.get(ApiEndpoints.schedules, queryParameters: {
        if (classId != null) "classId": classId,
        if (classSubjectId != null) "classSubjectId": classSubjectId,
      });
      final List data = res.data["data"];
      return data.map((e) => ScheduleModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal mengambil jadwal");
    }
  }

  /// startTime/endTime format "HH:MM", contoh "07:30"
  Future<ScheduleModel> create({
    required int classSubjectId,
    required String day,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.schedules, data: {
        "classSubjectId": classSubjectId,
        "day": day,
        "startTime": startTime,
        "endTime": endTime,
      });
      return ScheduleModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal membuat jadwal (cek kemungkinan bentrok)");
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.delete("${ApiEndpoints.schedules}/$id");
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Gagal menghapus jadwal");
    }
  }
}
