import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_subject_provider.dart';
import '../../providers/academic_year_provider.dart';
import '../auth/login_view.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_stat_header.dart';
import '../widgets/admin_empty_state.dart';
import 'class_subject_detail_view.dart';

class TeacherDashboardView extends StatefulWidget {
  const TeacherDashboardView({super.key});

  @override
  State<TeacherDashboardView> createState() => _TeacherDashboardViewState();
}

class _TeacherDashboardViewState extends State<TeacherDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ayProvider = context.read<AcademicYearProvider>();
      if (ayProvider.years.isEmpty) await ayProvider.fetchAll();
      final teacherId = context.read<AuthProvider>().user?.teacherId;
      if (teacherId != null) {
        context.read<ClassSubjectProvider>().fetchAll(
              teacherId: teacherId,
              academicYearId: ayProvider.active?.id,
            );
      }
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<ClassSubjectProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Dashboard Guru"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.textSecondary),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.accentGreen.withOpacity(0.30),
                      offset: const Offset(0, 8),
                      blurRadius: 18),
                ],
              ),
              child: Text(
                "Selamat datang, ${user?.name ?? ''}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(ClassSubjectProvider provider) {
    if (provider.isLoading && provider.classSubjects.isEmpty)
      return const LoadingIndicator();

    if (provider.classSubjects.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.class_outlined,
        color: AppColors.accentGreen,
        message:
            "Belum ada kelas/mapel yang ditugaskan ke kamu.\nHubungi admin untuk penugasan.",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      itemCount: provider.classSubjects.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return AdminStatHeader(
            icon: Icons.class_outlined,
            color: AppColors.accentGreen,
            value: provider.classSubjects.length.toString(),
            label: "Kelas & mapel yang kamu ajar",
          );
        }
        final cs = provider.classSubjects[index - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 0,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.fieldLine)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.accentGreen.withOpacity(0.12),
                child: const Icon(Icons.menu_book_outlined,
                    size: 18, color: AppColors.accentGreen),
              ),
              title: Text(cs.subjectName ?? 'Mapel',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              subtitle: Text("Kelas ${cs.className ?? cs.classId}",
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              trailing:
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ClassSubjectDetailView(classSubject: cs))),
            ),
          ),
        );
      },
    );
  }
}
