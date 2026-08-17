import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../widgets/loading_indicator.dart';

class StudentListView extends StatefulWidget {
  const StudentListView({super.key});

  @override
  State<StudentListView> createState() => _StudentListViewState();
}

class _StudentListViewState extends State<StudentListView> {
  int? _selectedClassId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchAll();
      // Manfaatin ClassProvider yang mungkin udah ke-fetch dari halaman lain,
      // kalau belum ya fetch juga buat ngisi dropdown filter.
      final classProvider = context.read<ClassProvider>();
      if (classProvider.classes.isEmpty) classProvider.fetchAll();
    });
  }

  void _onClassFilterChanged(int? classId) {
    setState(() => _selectedClassId = classId);
    context.read<StudentProvider>().fetchAll(classId: classId);
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final classProvider = context.watch<ClassProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Daftar Siswa"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int?>(
              value: _selectedClassId,
              decoration: const InputDecoration(
                labelText: "Filter berdasarkan kelas",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text("Semua kelas")),
                ...classProvider.classes.map(
                  (c) => DropdownMenuItem<int?>(value: c.id, child: Text("Kelas ${c.className}")),
                ),
              ],
              onChanged: _onClassFilterChanged,
            ),
          ),
          Expanded(child: _buildBody(studentProvider)),
        ],
      ),
    );
  }

  Widget _buildBody(StudentProvider provider) {
    if (provider.isLoading && provider.students.isEmpty) {
      return const LoadingIndicator();
    }

    if (provider.errorMessage != null && provider.students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
        ),
      );
    }

    if (provider.students.isEmpty) {
      return const Center(child: Text("Belum ada siswa", style: TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<StudentProvider>().fetchAll(classId: _selectedClassId),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: provider.students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final s = provider.students[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.secondary.withOpacity(0.1),
                child: Text(
                  s.name.isNotEmpty ? s.name[0].toUpperCase() : "?",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
              ),
              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              subtitle: Text(
                "NISN: ${s.nisn}${s.className != null ? ' • Kelas ${s.className}' : ''}",
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}
