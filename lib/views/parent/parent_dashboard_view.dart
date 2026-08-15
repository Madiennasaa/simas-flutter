import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_view.dart';

/// Stub dashboard Wali Murid. Nanti diisi widget-widget sesuai fitur
/// role ini (lihat daftar modul di README backend buat referensi endpoint).
class ParentDashboardView extends StatelessWidget {
  const ParentDashboardView({super.key});

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Dashboard Wali Murid"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Selamat datang, ${user?.name ?? ''}",
          style: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
