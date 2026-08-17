import 'package:flutter/foundation.dart';
import '../data/models/material_model.dart';
import '../data/repositories/material_repository.dart';

class MaterialProvider extends ChangeNotifier {
  final _repository = MaterialRepository();

  List<MaterialModel> _materials = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentClassSubjectId;

  List<MaterialModel> get materials => _materials;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAll(int classSubjectId) async {
    _currentClassSubjectId = classSubjectId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _materials = await _repository.getAll(classSubjectId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({required int classSubjectId, required String title, String? description, required String linkUrl}) async {
    try {
      await _repository.create(classSubjectId: classSubjectId, title: title, description: description, linkUrl: linkUrl);
      await fetchAll(classSubjectId);
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
      if (_currentClassSubjectId != null) await fetchAll(_currentClassSubjectId!);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }
}
