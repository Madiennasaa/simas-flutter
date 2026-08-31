import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import '../../data/models/class_subject_model.dart';
import '../../data/models/attendance_model.dart';
import '../widgets/loading_indicator.dart';

const _statusOptions = {
  'hadir': ('Hadir', AppColors.success),
  'sakit': ('Sakit', Color(0xFFF5A623)),
  'izin': ('Izin', Color(0xFF5B8DEF)),
  'alpha': ('Alpha', AppColors.error),
};

class AttendanceInputView extends StatefulWidget {
  final ClassSubjectModel classSubject;

  const AttendanceInputView({super.key, required this.classSubject});

  @override
  State<AttendanceInputView> createState() => _AttendanceInputViewState();
}

class _AttendanceInputViewState extends State<AttendanceInputView> {
  DateTime _selectedDate = DateTime.now();
  final Map<int, String> _statusByStudent = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<StudentProvider>()
          .fetchAll(classId: widget.classSubject.classId)
          .then((_) {
        // Default semua siswa "hadir", guru tinggal ubah yang tidak hadir.
        final students = context.read<StudentProvider>().students;
        setState(() {
          for (final s in students) {
            _statusByStudent[s.id] = 'hadir';
          }
        });
      });
    });
  }

  Future<void> _submit() async {
    final students = context.read<StudentProvider>().students;
    if (students.isEmpty) return;

    setState(() => _isSubmitting = true);
    final records = students
        .map((s) => AttendanceRecordInput(
            studentId: s.id, status: _statusByStudent[s.id] ?? 'hadir'))
        .toList();

    final ok = await context.read<AttendanceProvider>().submitAttendance(
          classSubjectId: widget.classSubject.id,
          date: _selectedDate,
          records: records,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Absensi tersimpan'
          : (context.read<AttendanceProvider>().errorMessage ??
              'Gagal menyimpan')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Input Absensi"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${widget.classSubject.subjectName} • Kelas ${widget.classSubject.className}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                ),
              ],
            ),
          ),
          Expanded(
            child: studentProvider.isLoading && studentProvider.students.isEmpty
                ? const LoadingIndicator()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: studentProvider.students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = studentProvider.students[index];
                      final status = _statusByStudent[s.id] ?? 'hadir';
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
                              DropdownButton<String>(
                                value: status,
                                underline: const SizedBox(),
                                items: _statusOptions.entries
                                    .map((e) => DropdownMenuItem(
                                          value: e.key,
                                          child: Text(e.value.$1,
                                              style: TextStyle(
                                                  color: e.value.$2,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13)),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() =>
                                    _statusByStudent[s.id] = v ?? 'hadir'),
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
                    backgroundColor: AppColors.accentGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Simpan Absensi",
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
