import 'package:flutter/foundation.dart';
import '../data/models/student_model.dart';
import '../data/repositories/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final _repository = StudentRepository();

  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentClassId; 

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get currentClassId => _currentClassId;

  Future<void> fetchAll({int? classId}) async {
    _currentClassId = classId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _students = await _repository.getAll(classId: classId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String username,
    required String password,
    required String name,
    String? nisn,
    required int classId,
    String? phoneNumber,
  }) async {
    _errorMessage = null; 
    try {
      await _repository.create(
        username: username,
        password: password,
        name: name,
        nisn: nisn,
        classId: classId,
        phoneNumber: phoneNumber,
      );
      await fetchAll(classId: _currentClassId); 
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(
    int id, {
    String? name,
    String? phoneNumber,
    String? nisn,
    int? classId,
  }) async {
    _errorMessage = null; 
    try {
      await _repository.update(
        id,
        name: name,
        phoneNumber: phoneNumber,
        nisn: nisn,
        classId: classId,
      );
      await fetchAll(classId: _currentClassId); 
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(int id) async {
    _errorMessage = null; 
    try {
      await _repository.remove(id);
      await fetchAll(classId: _currentClassId); 
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }
}