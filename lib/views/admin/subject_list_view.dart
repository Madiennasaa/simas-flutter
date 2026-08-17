import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/subject_provider.dart';
import '../widgets/loading_indicator.dart';

class SubjectListView extends StatefulWidget {
  const SubjectListView({super.key});

  @override
  State<SubjectListView> createState() => _SubjectListViewState();
}

class _SubjectListViewState extends State<SubjectListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubjectProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mata Pelajaran"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(SubjectProvider provider) {
    if (provider.isLoading && provider.subjects.isEmpty) return const LoadingIndicator();

    if (provider.errorMessage != null && provider.subjects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
        ),
      );
    }

    if (provider.subjects.isEmpty) {
      return const Center(child: Text("Belum ada mapel", style: TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<SubjectProvider>().fetchAll(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final s = provider.subjects[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.error.withOpacity(0.1),
                child: const Icon(Icons.book_outlined, size: 18, color: AppColors.error),
              ),
              title: Text(s.subjectName, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              subtitle: Text(
                "${s.type == 'mulok' ? 'Muatan Lokal' : 'Umum'} • KKM: ${s.kkm.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}
