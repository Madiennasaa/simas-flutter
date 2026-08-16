import 'package:flutter/foundation.dart';
import '../data/models/teacher_model.dart';
import '../data/repositories/teacher_repository.dart';

class TeacherProvider extends ChangeNotifier {
  final _repository = TeacherRepository();

  List<TeacherModel> _teachers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TeacherModel> get teachers => _teachers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _teachers = await _repository.getAll();
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
    required String teacherType,
    String? nip,
    String? phoneNumber,
  }) async {
    try {
      await _repository.create(
        username: username,
        password: password,
        name: name,
        teacherType: teacherType,
        nip: nip,
        phoneNumber: phoneNumber,
      );
      await fetchAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int id, {String? name, String? phoneNumber, String? nip, String? teacherType}) async {
    try {
      await _repository.update(id, name: name, phoneNumber: phoneNumber, nip: nip, teacherType: teacherType);
      await fetchAll();
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
      await fetchAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }
}
