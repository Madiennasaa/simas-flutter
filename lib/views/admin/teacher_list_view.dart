import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/teacher_provider.dart';
import '../widgets/loading_indicator.dart';

class TeacherListView extends StatefulWidget {
  const TeacherListView({super.key});

  @override
  State<TeacherListView> createState() => _TeacherListViewState();
}

class _TeacherListViewState extends State<TeacherListView> {
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
        title: const Text("Daftar Guru"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(TeacherProvider provider) {
    if (provider.isLoading && provider.teachers.isEmpty) return const LoadingIndicator();

    if (provider.errorMessage != null && provider.teachers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
        ),
      );
    }

    if (provider.teachers.isEmpty) {
      return const Center(child: Text("Belum ada guru", style: TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TeacherProvider>().fetchAll(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.teachers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final t = provider.teachers[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.warning.withOpacity(0.15),
                child: Text(
                  t.name.isNotEmpty ? t.name[0].toUpperCase() : "?",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning),
                ),
              ),
              title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              subtitle: Text(
                "${t.teacherType == 'homeroom' ? 'Wali Kelas' : 'Guru Mapel'}"
                "${t.nip != null ? ' • NIP: ${t.nip}' : ''}",
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}
