import 'package:flutter/foundation.dart';
import '../data/models/class_subject_model.dart';
import '../data/repositories/class_subject_repository.dart';

class ClassSubjectProvider extends ChangeNotifier {
  final _repository = ClassSubjectRepository();

  List<ClassSubjectModel> _classSubjects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ClassSubjectModel> get classSubjects => _classSubjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Kalau dipanggil dari akun guru, backend otomatis filter cuma penugasan dia.
  Future<void> fetchAll({int? classId, int? academicYearId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _classSubjects = await _repository.getAll(classId: classId, academicYearId: academicYearId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required int classId,
    required int subjectId,
    required int teacherId,
    required int academicYearId,
  }) async {
    try {
      await _repository.create(
        classId: classId,
        subjectId: subjectId,
        teacherId: teacherId,
        academicYearId: academicYearId,
      );
      await fetchAll(academicYearId: academicYearId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(int id) async {
    try {
      await _repository.remove(id);
      _classSubjects.removeWhere((cs) => cs.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }
}
