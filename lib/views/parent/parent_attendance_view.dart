import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/academic_year_provider.dart';
import '../../data/models/user_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_badge.dart';

const _statusLabel = {
  'hadir': ('Hadir', AppColors.success),
  'sakit': ('Sakit', Color(0xFFF5A623)),
  'izin': ('Izin', Color(0xFF5B8DEF)),
  'alpha': ('Alpha', AppColors.error),
};

class ParentAttendanceView extends StatefulWidget {
  final ParentChild child;

  const ParentAttendanceView({super.key, required this.child});

  @override
  State<ParentAttendanceView> createState() => _ParentAttendanceViewState();
}

class _ParentAttendanceViewState extends State<ParentAttendanceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ayProvider = context.read<AcademicYearProvider>();
      if (ayProvider.years.isEmpty) await ayProvider.fetchAll();
      final activeId = ayProvider.active?.id;
      if (activeId != null)
        context
            .read<AttendanceProvider>()
            .fetchChildAttendance(widget.child.id, activeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final records = [...provider.attendances]
      ..sort((a, b) => b.date.compareTo(a.date));

    final total = records.length;
    final hadir = records.where((r) => r.status == 'hadir').length;
    final percent = total == 0 ? 0 : (hadir / total * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Absensi ${widget.child.name ?? ''}"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: provider.isLoading && provider.attendances.isEmpty
          ? const LoadingIndicator()
          : records.isEmpty
              ? const AdminEmptyState(
                  icon: Icons.checklist_rtl_outlined,
                  color: Color(0xFFEF6C6C),
                  message: "Belum ada catatan absensi")
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.18)),
                        ),
                        child: Row(
                          children: [
                            Text("$percent%",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.success)),
                            const SizedBox(width: 8),
                            Text("Kehadiran ($hadir dari $total)",
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: records.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final r = records[index];
                          final status = _statusLabel[r.status] ??
                              (r.status, AppColors.textMuted);
                          return Card(
                            elevation: 0,
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppColors.fieldLine)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              title: Text(
                                  "${r.date.day}/${r.date.month}/${r.date.year}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              subtitle: r.subjectName != null
                                  ? Text(r.subjectName!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary))
                                  : null,
                              trailing: AdminBadge(
                                  label: status.$1, color: status.$2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
