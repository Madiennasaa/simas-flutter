import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_view.dart';
import 'student_subjects_view.dart';
import 'student_schedule_view.dart';
import 'student_grades_view.dart';
import 'student_attendance_view.dart';

class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({super.key});

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

    final items = [
      _MenuItem(
          icon: Icons.menu_book_outlined,
          label: "Mapel Saya",
          color: AppColors.accentGreen,
          builder: () => const StudentSubjectsView()),
      _MenuItem(
          icon: Icons.schedule_outlined,
          label: "Jadwal",
          color: const Color(0xFF5B8DEF),
          builder: () => const StudentScheduleView()),
      _MenuItem(
          icon: Icons.grade_outlined,
          label: "Nilai",
          color: const Color(0xFFF5A623),
          builder: () => const StudentGradesView()),
      _MenuItem(
          icon: Icons.checklist_rtl_outlined,
          label: "Absensi",
          color: const Color(0xFFEF6C6C),
          builder: () => const StudentAttendanceView()),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Dashboard Siswa"),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                      blurRadius: 18)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selamat datang,",
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withOpacity(0.85))),
                  const SizedBox(height: 2),
                  Text(user?.name ?? '',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  if (user?.className != null) ...[
                    const SizedBox(height: 4),
                    Text("Kelas ${user!.className}",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85))),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.3,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => item.builder())),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.textPrimary.withOpacity(0.05),
                              offset: const Offset(0, 4),
                              blurRadius: 12)
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: item.color.withOpacity(0.12),
                                shape: BoxShape.circle),
                            child: Icon(item.icon, size: 26, color: item.color),
                          ),
                          const SizedBox(height: 10),
                          Text(item.label,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
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

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final Widget Function() builder;

  _MenuItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.builder});
}
