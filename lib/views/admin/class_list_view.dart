import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/class_provider.dart';
import '../widgets/loading_indicator.dart';

class ClassListView extends StatefulWidget {
  const ClassListView({super.key});

  @override
  State<ClassListView> createState() => _ClassListViewState();
}

class _ClassListViewState extends State<ClassListView> {
  @override
  void initState() {
    super.initState();
    // Panggil setelah frame pertama, biar gak error "setState during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Daftar Kelas"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ClassProvider provider) {
    if (provider.isLoading && provider.classes.isEmpty) {
      return const LoadingIndicator();
    }

    if (provider.errorMessage != null && provider.classes.isEmpty) {
      return _ErrorState(
        message: provider.errorMessage!,
        onRetry: () => context.read<ClassProvider>().fetchAll(),
      );
    }

    if (provider.classes.isEmpty) {
      return const Center(child: Text("Belum ada kelas", style: TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ClassProvider>().fetchAll(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.classes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final c = provider.classes[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  c.className,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              title: Text(
                "Kelas ${c.className}",
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              subtitle: Text(
                "Fase ${c.phase} • ${c.studentCount} siswa"
                "${c.homeroomTeacherName != null ? ' • Wali: ${c.homeroomTeacherName}' : ' • Belum ada wali kelas'}",
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text("Coba Lagi")),
          ],
        ),
      ),
    );
  }
}
