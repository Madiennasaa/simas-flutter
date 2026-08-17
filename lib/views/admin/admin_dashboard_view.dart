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
        color: AppColors.primary,
        isReady: true,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClassListView())),
      ),
      _MenuItemData(
        icon: Icons.people_outline,
        label: "Siswa",
        color: AppColors.secondary,
        isReady: true,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentListView())),
      ),
      _MenuItemData(
        icon: Icons.person_outline,
        label: "Guru",
        color: AppColors.warning,
        isReady: true,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherListView())),
      ),
      _MenuItemData(
        icon: Icons.book_outlined,
        label: "Mata Pelajaran",
        color: AppColors.error,
        isReady: true,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubjectListView())),
      ),
      _MenuItemData(
        icon: Icons.calendar_today_outlined,
        label: "Tahun Ajaran",
        color: Colors.purple,
        isReady: true,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AcademicYearListView())),
      ),
      _MenuItemData(
        icon: Icons.campaign_outlined,
        label: "Pengumuman",
        color: Colors.teal,
        isReady: true,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementListView())),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _handleLogout(context)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Selamat datang, ${user?.name ?? ''}",
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) => _MenuTile(data: menuItems[index]),
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

  _MenuItemData({required this.icon, required this.label, required this.color, required this.isReady, this.onTap});
}

class _MenuTile extends StatelessWidget {
  final _MenuItemData data;

  const _MenuTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: data.isReady
            ? data.onTap
            : () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fitur ini belum tersedia")),
                ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data.icon, size: 32, color: data.isReady ? data.color : Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: data.isReady ? AppColors.textPrimary : Colors.grey.shade400,
                ),
              ),
              if (!data.isReady) ...[
                const SizedBox(height: 2),
                Text("Segera hadir", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
