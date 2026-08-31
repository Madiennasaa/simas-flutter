import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/academic_year_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_stat_header.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_badge.dart';

class AcademicYearListView extends StatefulWidget {
  const AcademicYearListView({super.key});

  @override
  State<AcademicYearListView> createState() => _AcademicYearListViewState();
}

class _AcademicYearListViewState extends State<AcademicYearListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicYearProvider>().fetchAll();
    });
  }

  Future<void> _confirmSetActive(int id, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ganti Semester Aktif?"),
        content: Text(
          "Semester \"$label\" akan diaktifkan. Semester yang sekarang aktif otomatis dikunci "
          "(gak bisa diedit lagi kecuali dibuka manual). Yakin?",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal")),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Ya, Aktifkan")),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AcademicYearProvider>().setActive(id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Semester aktif berhasil diganti"),
              backgroundColor: AppColors.success),
        );
      } else {
        final error = context.read<AcademicYearProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error ?? "Gagal mengganti semester"),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicYearProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tahun Ajaran"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(AcademicYearProvider provider) {
    if (provider.isLoading && provider.years.isEmpty)
      return const LoadingIndicator();

    if (provider.errorMessage != null && provider.years.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(provider.errorMessage!,
              style: const TextStyle(color: AppColors.error)),
        ),
      );
    }

    if (provider.years.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.calendar_today_outlined,
        color: Color(0xFFA78BFA),
        message: "Belum ada tahun ajaran",
      );
    }

    final activeCount = provider.years.where((y) => y.isActive).length;

    return RefreshIndicator(
      onRefresh: () => context.read<AcademicYearProvider>().fetchAll(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        itemCount: provider.years.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return AdminStatHeader(
              icon: Icons.calendar_today_outlined,
              color: const Color(0xFFA78BFA),
              value: provider.years.length.toString(),
              label:
                  activeCount > 0 ? "Tahun ajaran (1 aktif)" : "Tahun ajaran",
            );
          }
          final y = provider.years[index - 1];
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color:
                          y.isActive ? AppColors.success : AppColors.fieldLine,
                      width: y.isActive ? 1.5 : 1),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(y.label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        if (y.isActive)
                          const AdminBadge(
                              label: "Aktif", color: AppColors.success)
                        else if (y.isLocked)
                          const AdminBadge(
                              label: "Terkunci", color: AppColors.textSecondary)
                        else
                          const AdminBadge(
                              label: "Belum aktif", color: AppColors.warning),
                      ],
                    ),
                  ),
                  trailing: y.isActive
                      ? null
                      : TextButton(
                          onPressed: () => _confirmSetActive(y.id, y.label),
                          child: const Text("Aktifkan"),
                        ),
                ),
              ));
        },
      ),
    );
  }
}
