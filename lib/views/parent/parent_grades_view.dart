import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/grade_provider.dart';
import '../../providers/academic_year_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/grade_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_badge.dart';

const _scoreTypeLabel = {
  'task_manual': 'Tugas Harian',
  'cbt': 'CBT/Kuis',
  'uts': 'UTS',
  'uas': 'UAS',
};

class ParentGradesView extends StatefulWidget {
  final ParentChild child;

  const ParentGradesView({super.key, required this.child});

  @override
  State<ParentGradesView> createState() => _ParentGradesViewState();
}

class _ParentGradesViewState extends State<ParentGradesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ayProvider = context.read<AcademicYearProvider>();
      if (ayProvider.years.isEmpty) await ayProvider.fetchAll();
      final activeId = ayProvider.active?.id;
      if (activeId != null)
        context
            .read<GradeProvider>()
            .fetchChildGrades(widget.child.id, activeId);
    });
  }

  Map<String, List<GradeModel>> _groupBySubject(List<GradeModel> grades) {
    final map = <String, List<GradeModel>>{};
    for (final g in grades) {
      map.putIfAbsent(g.subjectName ?? 'Mapel', () => []).add(g);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GradeProvider>();
    final grouped = _groupBySubject(provider.grades);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Nilai ${widget.child.name ?? ''}"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: provider.isLoading && provider.grades.isEmpty
          ? const LoadingIndicator()
          : grouped.isEmpty
              ? const AdminEmptyState(
                  icon: Icons.grade_outlined,
                  color: Color(0xFFF5A623),
                  message: "Belum ada nilai yang tercatat")
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: grouped.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          ...entry.value.map((g) => Card(
                                elevation: 0,
                                color: AppColors.surface,
                                margin: const EdgeInsets.only(bottom: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side:
                                        BorderSide(color: AppColors.fieldLine)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  title: AdminBadge(
                                      label: _scoreTypeLabel[g.scoreType] ??
                                          g.scoreType,
                                      color: const Color(0xFFF5A623)),
                                  subtitle: g.assignmentTitle != null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(g.assignmentTitle!,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary)))
                                      : null,
                                  trailing: Text(
                                    g.score.toStringAsFixed(0),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: g.score >= 70
                                            ? AppColors.success
                                            : AppColors.error),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
