import 'package:flutter/foundation.dart';
import '../data/models/subject_model.dart';
import '../data/repositories/subject_repository.dart';

class SubjectProvider extends ChangeNotifier {
  final _repository = SubjectRepository();

  List<SubjectModel> _subjects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SubjectModel> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _subjects = await _repository.getAll();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({required String subjectName, required String type, double? kkm}) async {
    try {
      await _repository.create(subjectName: subjectName, type: type, kkm: kkm);
      await fetchAll();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int id, {String? subjectName, String? type, double? kkm}) async {
    try {
      await _repository.update(id, subjectName: subjectName, type: type, kkm: kkm);
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
