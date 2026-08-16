import 'package:flutter/foundation.dart';
import '../data/models/attendance_model.dart';
import '../data/repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  final _repository = AttendanceRepository();

  List<AttendanceModel> _attendances = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceModel> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---- Guru: submit absensi ----
  Future<bool> submitAttendance({
    required int classSubjectId,
    required DateTime date,
    required List<AttendanceRecordInput> records,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.bulkCreate(classSubjectId: classSubjectId, date: date, records: records);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ---- Siswa: lihat absensi sendiri ----
  Future<void> fetchMyAttendance(int academicYearId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _attendances = await _repository.myAttendance(academicYearId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Wali murid: lihat absensi anak ----
  Future<void> fetchChildAttendance(int studentId, int academicYearId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _attendances = await _repository.childAttendance(studentId, academicYearId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Kepala sekolah/admin: rekap per kelas ----
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? get summary => _summary;

  Future<void> fetchClassSummary(int classId, int academicYearId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _summary = await _repository.classSummary(classId, academicYearId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
