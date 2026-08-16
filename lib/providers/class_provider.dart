import 'package:flutter/foundation.dart';
import '../data/models/school_class_model.dart';
import '../data/repositories/class_repository.dart';

class ClassProvider extends ChangeNotifier {
  final _repository = ClassRepository();

  List<SchoolClassModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SchoolClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _classes = await _repository.getAll();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required String className,
    required int gradeLevel,
    required String phase,
    int? homeroomTeacherId,
  }) async {
    try {
      await _repository.create(
        className: className,
        gradeLevel: gradeLevel,
        phase: phase,
        homeroomTeacherId: homeroomTeacherId,
      );
      await fetchAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int id, {String? className, int? gradeLevel, String? phase, int? homeroomTeacherId}) async {
    try {
      await _repository.update(id,
          className: className, gradeLevel: gradeLevel, phase: phase, homeroomTeacherId: homeroomTeacherId);
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
