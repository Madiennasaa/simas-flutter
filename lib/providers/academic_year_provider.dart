import 'package:flutter/foundation.dart';
import '../data/models/academic_year_model.dart';
import '../data/repositories/academic_year_repository.dart';

class AcademicYearProvider extends ChangeNotifier {
  final _repository = AcademicYearRepository();

  List<AcademicYearModel> _years = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AcademicYearModel> get years => _years;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AcademicYearModel? get active =>
      _years.where((y) => y.isActive).isEmpty ? null : _years.firstWhere((y) => y.isActive);

  Future<void> fetchAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _years = await _repository.getAll();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String year, String semester) async {
    try {
      await _repository.create(year, semester);
      await fetchAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> setActive(int id) async {
    try {
      await _repository.setActive(id);
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
