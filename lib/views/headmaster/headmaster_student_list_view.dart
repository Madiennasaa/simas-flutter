import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_stat_header.dart';
import '../widgets/admin_empty_state.dart';

class HeadmasterStudentListView extends StatefulWidget {
  const HeadmasterStudentListView({super.key});

  @override
  State<HeadmasterStudentListView> createState() =>
      _HeadmasterStudentListViewState();
}

class _HeadmasterStudentListViewState extends State<HeadmasterStudentListView> {
  int? _selectedClassId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final classProvider = context.read<ClassProvider>();
      if (classProvider.classes.isEmpty) await classProvider.fetchAll();
      context.read<StudentProvider>().fetchAll(classId: _selectedClassId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final provider = context.watch<StudentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Data Siswa"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: DropdownButtonFormField<int?>(
              value: _selectedClassId,
              decoration: const InputDecoration(
                  labelText: 'Filter Kelas',
                  isDense: true,
                  border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text('Semua Kelas')),
                ...classProvider.classes.map((c) => DropdownMenuItem<int?>(
                    value: c.id, child: Text('Kelas ${c.className}'))),
              ],
              onChanged: (v) {
                setState(() => _selectedClassId = v);
                context.read<StudentProvider>().fetchAll(classId: v);
              },
            ),
          ),
          Expanded(
            child: provider.isLoading && provider.students.isEmpty
                ? const LoadingIndicator()
                : provider.students.isEmpty
                    ? const AdminEmptyState(
                        icon: Icons.people_outline,
                        color: AppColors.accentGreenDark,
                        message: "Belum ada siswa")
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                        itemCount: provider.students.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return AdminStatHeader(
                              icon: Icons.people_outline,
                              color: AppColors.accentGreenDark,
                              value: provider.students.length.toString(),
                              label: _selectedClassId == null
                                  ? "Total siswa"
                                  : "Siswa di kelas ini",
                            );
                          }
                          final s = provider.students[index - 1];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 0,
                              color: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: AppColors.fieldLine)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.accentGreenDark
                                      .withOpacity(0.12),
                                  child: const Icon(Icons.person_outline,
                                      size: 18,
                                      color: AppColors.accentGreenDark),
                                ),
                                title: Text(s.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                                subtitle: Text(
                                  "Kelas ${s.className ?? s.classId}${s.nisn != null ? ' • NISN ${s.nisn}' : ''}",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary),
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
