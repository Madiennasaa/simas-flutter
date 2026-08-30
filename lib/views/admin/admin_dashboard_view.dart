import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_view.dart';
import 'class_list_view.dart';
import 'student_list_view.dart';
import 'teacher_list_view.dart';
import 'subject_list_view.dart';
import 'academic_year_list_view.dart';
import 'announcement_list_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

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

    // Menu lain (guru, mapel, tahun ajaran, pengumuman) belum punya halaman,
    // ditandai isReady: false biar keliatan mana yang udah bisa dipakai.
    final menuItems = [
      _MenuItemData(
        icon: Icons.class_outlined,
        label: "Kelas",
        color: AppColors.accentGreen,
        isReady: true,
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ClassListView())),
      ),
      _MenuItemData(
        icon: Icons.people_outline,
        label: "Siswa",
        color: const Color(0xFF5B8DEF),
        isReady: true,
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const StudentListView())),
      ),
      _MenuItemData(
        icon: Icons.person_outline,
        label: "Guru",
        color: const Color(0xFFF5A623),
        isReady: true,
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const TeacherListView())),
      ),
      _MenuItemData(
        icon: Icons.book_outlined,
        label: "Mata Pelajaran",
        color: const Color(0xFFEF6C6C),
        isReady: true,
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SubjectListView())),
      ),
      _MenuItemData(
        icon: Icons.calendar_today_outlined,
        label: "Tahun Ajaran",
        color: const Color(0xFFA78BFA),
        isReady: true,
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AcademicYearListView())),
      ),
      _MenuItemData(
        icon: Icons.campaign_outlined,
        label: "Pengumuman",
        color: const Color(0xFF4FBDBA),
        isReady: true,
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AnnouncementListView())),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
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
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings_outlined,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat datang,",
                          style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withOpacity(0.85)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.name ?? '',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.3,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) =>
                  _MenuTile(data: menuItems[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  final bool isReady;
  final VoidCallback? onTap;

  _MenuItemData(
      {required this.icon,
      required this.label,
      required this.color,
      required this.isReady,
      this.onTap});
}

class _MenuTile extends StatelessWidget {
  final _MenuItemData data;

  const _MenuTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: data.isReady
            ? data.onTap
            : () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fitur ini belum tersedia")),
                ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.05),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (data.isReady ? data.color : AppColors.inactiveGrey)
                      .withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon,
                    size: 26,
                    color: data.isReady ? data.color : AppColors.inactiveGrey),
              ),
              const SizedBox(height: 10),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: data.isReady
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
              if (!data.isReady) ...[
                const SizedBox(height: 2),
                Text("Segera hadir",
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
