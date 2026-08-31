import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/grade_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/assignment_provider.dart';
import '../../data/models/class_subject_model.dart';
import '../../data/models/grade_model.dart';
import '../widgets/loading_indicator.dart';

const _scoreTypeOptions = {
  'task_manual': 'Tugas Harian',
  'cbt': 'CBT/Kuis',
  'uts': 'UTS',
  'uas': 'UAS',
};

class GradeInputView extends StatefulWidget {
  final ClassSubjectModel classSubject;

  const GradeInputView({super.key, required this.classSubject});

  @override
  State<GradeInputView> createState() => _GradeInputViewState();
}

class _GradeInputViewState extends State<GradeInputView> {
  String _scoreType = 'task_manual';
  int? _selectedAssignmentId;
  final Map<int, TextEditingController> _scoreControllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<StudentProvider>()
          .fetchAll(classId: widget.classSubject.classId)
          .then((_) {
        for (final s in context.read<StudentProvider>().students) {
          _scoreControllers[s.id] = TextEditingController();
        }
        setState(() {});
      });
      context.read<AssignmentProvider>().fetchAll(widget.classSubject.id);
    });
  }

  @override
  void dispose() {
    for (final c in _scoreControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final students = context.read<StudentProvider>().students;
    if (students.isEmpty) return;

    final records = <GradeRecordInput>[];
    for (final s in students) {
      final text = _scoreControllers[s.id]?.text.trim() ?? '';
      final score = double.tryParse(text);
      if (score != null) {
        records.add(GradeRecordInput(studentId: s.id, score: score));
      }
    }

    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi minimal satu nilai siswa')));
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await context.read<GradeProvider>().submitGrades(
          classSubjectId: widget.classSubject.id,
          scoreType: _scoreType,
          records: records,
          assignmentId: _selectedAssignmentId,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Nilai tersimpan (${records.length} siswa)'
          : (context.read<GradeProvider>().errorMessage ?? 'Gagal menyimpan')),
    ));
    if (ok) {
      for (final c in _scoreControllers.values) {
        c.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final assignmentProvider = context.watch<AssignmentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Input Nilai"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              "${widget.classSubject.subjectName} • Kelas ${widget.classSubject.className}",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _scoreType,
                    decoration: const InputDecoration(
                        labelText: 'Jenis Nilai',
                        isDense: true,
                        border: OutlineInputBorder()),
                    items: _scoreTypeOptions.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _scoreType = v ?? 'task_manual'),
                  ),
                ),
              ],
            ),
          ),
          if (_scoreType == 'task_manual')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: DropdownButtonFormField<int?>(
                value: _selectedAssignmentId,
                decoration: const InputDecoration(
                    labelText: 'Kaitkan ke Tugas (opsional)',
                    isDense: true,
                    border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('Tidak dikaitkan')),
                  ...assignmentProvider.assignments.map((a) =>
                      DropdownMenuItem<int?>(
                          value: a.id, child: Text(a.title))),
                ],
                onChanged: (v) => setState(() => _selectedAssignmentId = v),
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: studentProvider.isLoading && studentProvider.students.isEmpty
                ? const LoadingIndicator()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: studentProvider.students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = studentProvider.students[index];
                      return Card(
                        elevation: 0,
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.fieldLine)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(s.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                              ),
                              SizedBox(
                                width: 70,
                                child: TextField(
                                  controller: _scoreControllers[s.id],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                      hintText: '0-100',
                                      isDense: true,
                                      border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isSubmitting || studentProvider.students.isEmpty)
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Simpan Nilai",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
