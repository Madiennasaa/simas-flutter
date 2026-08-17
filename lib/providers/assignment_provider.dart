import 'package:flutter/foundation.dart';
import '../data/models/assignment_model.dart';
import '../data/repositories/assignment_repository.dart';

class AssignmentProvider extends ChangeNotifier {
  final _repository = AssignmentRepository();

  List<AssignmentModel> _assignments = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _currentClassSubjectId;

  List<AssignmentModel> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAll(int classSubjectId) async {
    _currentClassSubjectId = classSubjectId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _assignments = await _repository.getAll(classSubjectId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required int classSubjectId,
    required String title,
    String? description,
    String? attachmentUrl,
    DateTime? dueDate,
  }) async {
    try {
      await _repository.create(
        classSubjectId: classSubjectId,
        title: title,
        description: description,
        attachmentUrl: attachmentUrl,
        dueDate: dueDate,
      );
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
