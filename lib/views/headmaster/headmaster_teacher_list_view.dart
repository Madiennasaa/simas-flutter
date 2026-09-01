import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/teacher_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_stat_header.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_badge.dart';

class HeadmasterTeacherListView extends StatefulWidget {
  const HeadmasterTeacherListView({super.key});

  @override
  State<HeadmasterTeacherListView> createState() =>
      _HeadmasterTeacherListViewState();
}

class _HeadmasterTeacherListViewState extends State<HeadmasterTeacherListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Data Guru"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: provider.isLoading && provider.teachers.isEmpty
          ? const LoadingIndicator()
          : provider.teachers.isEmpty
              ? const AdminEmptyState(
                  icon: Icons.person_outline,
                  color: Color(0xFFF5A623),
                  message: "Belum ada guru terdaftar")
              : RefreshIndicator(
                  onRefresh: () => context.read<TeacherProvider>().fetchAll(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                    itemCount: provider.teachers.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return AdminStatHeader(
                          icon: Icons.person_outline,
                          color: const Color(0xFFF5A623),
                          value: provider.teachers.length.toString(),
                          label: "Guru terdaftar",
                        );
                      }
                      final t = provider.teachers[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
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
                                  const Color(0xFFF5A623).withOpacity(0.12),
                              child: const Icon(Icons.person_outline,
                                  size: 18, color: Color(0xFFF5A623)),
                            ),
                            title: Text(t.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: AdminBadge(
                                label: t.teacherType == 'homeroom'
                                    ? 'Wali Kelas'
                                    : 'Guru Mapel',
                                color: t.teacherType == 'homeroom'
                                    ? const Color(0xFF5B8DEF)
                                    : const Color(0xFFF5A623),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
