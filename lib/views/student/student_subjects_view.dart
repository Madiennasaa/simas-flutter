import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/schedule_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_empty_state.dart';
import 'student_subject_detail_view.dart';

/// Daftar mapel unik yang diikuti siswa, diturunkan dari data jadwal
/// (backend belum punya endpoint "mapel saya" khusus siswa, tapi jadwal
/// terbuka buat semua role dan sudah membawa classSubjectId per mapel).
class StudentSubjectsView extends StatefulWidget {
  const StudentSubjectsView({super.key});

  @override
  State<StudentSubjectsView> createState() => _StudentSubjectsViewState();
}

class _StudentSubjectsViewState extends State<StudentSubjectsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final classId = context.read<AuthProvider>().user?.classId;
      if (classId != null)
        context.read<ScheduleProvider>().fetchAll(classId: classId);
    });
  }

  List<ScheduleModel> _uniqueSubjects(List<ScheduleModel> schedules) {
    final seen = <int>{};
    final result = <ScheduleModel>[];
    for (final s in schedules) {
      if (seen.add(s.classSubjectId)) result.add(s);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final subjects = _uniqueSubjects(provider.schedules);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mapel Saya"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: provider.isLoading && provider.schedules.isEmpty
          ? const LoadingIndicator()
          : subjects.isEmpty
              ? const AdminEmptyState(
                  icon: Icons.menu_book_outlined,
                  color: AppColors.accentGreen,
                  message: "Belum ada mapel terjadwal untuk kelasmu",
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = subjects[index];
                    return Card(
                      elevation: 0,
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.fieldLine)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.accentGreen.withOpacity(0.12),
                          child: const Icon(Icons.menu_book_outlined,
                              size: 18, color: AppColors.accentGreen),
                        ),
                        title: Text(s.subjectName ?? 'Mapel',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        subtitle: Text(s.teacherName ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textMuted),
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => StudentSubjectDetailView(
                              classSubjectId: s.classSubjectId,
                              subjectName: s.subjectName ?? 'Mapel'),
                        )),
                      ),
                    );
                  },
                ),
    );
  }
}
