import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/user_model.dart';
import '../auth/login_view.dart';
import 'parent_grades_view.dart';
import 'parent_attendance_view.dart';
import 'parent_schedule_view.dart';
import 'parent_announcements_view.dart';

class ParentDashboardView extends StatefulWidget {
  const ParentDashboardView({super.key});

  @override
  State<ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends State<ParentDashboardView> {
  ParentChild? _selectedChild;

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
    final children = user?.children ?? [];

    // Default ke anak pertama kalau belum ada yang dipilih.
    if (_selectedChild == null && children.isNotEmpty) {
      _selectedChild = children.first;
    }

    final items = _selectedChild == null
        ? <_MenuItem>[]
        : [
            _MenuItem(
                icon: Icons.grade_outlined,
                label: "Nilai",
                color: const Color(0xFFF5A623),
                builder: () => ParentGradesView(child: _selectedChild!)),
            _MenuItem(
                icon: Icons.checklist_rtl_outlined,
                label: "Absensi",
                color: const Color(0xFFEF6C6C),
                builder: () => ParentAttendanceView(child: _selectedChild!)),
            _MenuItem(
                icon: Icons.schedule_outlined,
                label: "Jadwal",
                color: const Color(0xFF5B8DEF),
                builder: () => ParentScheduleView(child: _selectedChild!)),
            _MenuItem(
                icon: Icons.campaign_outlined,
                label: "Pengumuman",
                color: const Color(0xFF4FBDBA),
                builder: () => const ParentAnnouncementsView()),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Dashboard Wali Murid"),
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
              child: Text("Selamat datang, ${user?.name ?? ''}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
          if (children.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DropdownButtonFormField<ParentChild>(
                value: _selectedChild,
                decoration: const InputDecoration(
                    labelText: 'Pilih Anak',
                    isDense: true,
                    border: OutlineInputBorder()),
                items: children
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                            "${c.name ?? 'Anak #${c.id}'} • Kelas ${c.className ?? ''}")))
                    .toList(),
                onChanged: (v) => setState(() => _selectedChild = v),
              ),
            )
          else if (_selectedChild != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                "${_selectedChild!.name ?? ''} • Kelas ${_selectedChild!.className ?? ''}",
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
              ),
            ),
          Expanded(
            child: children.isEmpty
                ? const Center(
                    child: Text("Belum ada data anak terhubung ke akun ini",
                        style: TextStyle(color: AppColors.textMuted)))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                              MaterialPageRoute(
                                  builder: (_) => item.builder())),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        AppColors.textPrimary.withOpacity(0.05),
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
                                  child: Icon(item.icon,
                                      size: 26, color: item.color),
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
