import 'package:flutter/foundation.dart';
import '../data/models/grade_model.dart';
import '../data/repositories/grade_repository.dart';

class GradeProvider extends ChangeNotifier {
  final _repository = GradeRepository();

  List<GradeModel> _grades = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GradeModel> get grades => _grades;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---- Guru: submit nilai ----
  Future<bool> submitGrades({
    required int classSubjectId,
    required String scoreType,
    required List<GradeRecordInput> records,
    int? assignmentId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.bulkCreate(
        classSubjectId: classSubjectId,
        scoreType: scoreType,
        records: records,
        assignmentId: assignmentId,
      );
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

  // ---- Siswa: lihat nilai sendiri ----
  Future<void> fetchMyGrades(int academicYearId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _grades = await _repository.myGrades(academicYearId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Wali murid: lihat nilai anak ----
  Future<void> fetchChildGrades(int studentId, int academicYearId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _grades = await _repository.childGrades(studentId, academicYearId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Guru/admin/kepsek: rekap per kelas-mapel ----
  Future<void> fetchByClassSubject(int classSubjectId, {String? scoreType}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _grades = await _repository.byClassSubject(classSubjectId, scoreType: scoreType);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
