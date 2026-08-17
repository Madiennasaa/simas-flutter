import 'package:flutter/foundation.dart';
import '../data/models/schedule_model.dart';
import '../data/repositories/schedule_repository.dart';

class ScheduleProvider extends ChangeNotifier {
  final _repository = ScheduleRepository();

  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAll({int? classId, int? classSubjectId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _schedules = await _repository.getAll(classId: classId, classSubjectId: classSubjectId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create({
    required int classSubjectId,
    required String day,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await _repository.create(classSubjectId: classSubjectId, day: day, startTime: startTime, endTime: endTime);
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
