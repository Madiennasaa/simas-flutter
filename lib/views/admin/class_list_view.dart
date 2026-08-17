import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/class_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../data/models/school_class_model.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openClassForm(context, provider: provider),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
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
      return const Center(
          child: Text("Belum ada kelas",
              style: TextStyle(color: AppColors.textSecondary)));
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  c.className,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              ),
              title: Text(
                "Kelas ${c.className}",
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              subtitle: Text(
                "Tingkat ${c.gradeLevel} • ${c.studentCount} siswa"
                "${c.homeroomTeacherName != null ? ' • Wali: ${c.homeroomTeacherName}' : ' • Belum ada wali kelas'}",
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    _openClassForm(context, provider: provider, existing: c);
                  } else if (v == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text('Yakin ingin menghapus kelas ini?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      final ok = await provider.remove(c.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? 'Kelas dihapus'
                            : (provider.errorMessage ?? 'Gagal menghapus')),
                      ));
                    }
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openClassForm(BuildContext context,
      {required ClassProvider provider, SchoolClassModel? existing}) {
    final isEdit = existing != null;
    final classNameCtrl =
        TextEditingController(text: existing?.className ?? '');
    int? selectedGrade = existing?.gradeLevel;
    int? selectedTeacherId = existing?.homeroomTeacherId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // ensure teachers fetched
        final tProvider = context.read<TeacherProvider>();
        if (tProvider.teachers.isEmpty && !tProvider.isLoading)
          tProvider.fetchAll();
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(isEdit ? 'Edit Kelas' : 'Tambah Kelas',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                      controller: classNameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nama Kelas')),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedGrade,
                    decoration:
                        const InputDecoration(labelText: 'Tingkat Kelas'),
                    items: List.generate(6, (i) => i + 1)
                        .map((g) => DropdownMenuItem(
                            value: g, child: Text(g.toString())))
                        .toList(),
                    onChanged: (v) => setState(() => selectedGrade = v),
                  ),
                  const SizedBox(height: 8),
                  Consumer<TeacherProvider>(builder: (context, tp, __) {
                    if (tp.isLoading) return const LinearProgressIndicator();
                    final teachers = tp.teachers;
                    return DropdownButtonFormField<int?>(
                      value: selectedTeacherId,
                      decoration: const InputDecoration(
                          labelText: 'Wali Kelas (opsional)'),
                      items: [
                        const DropdownMenuItem<int?>(
                            value: null, child: Text('Tidak ada')),
                        ...teachers
                            .map((t) => DropdownMenuItem<int?>(
                                value: t.id, child: Text(t.name)))
                            .toList(),
                      ],
                      onChanged: (v) => setState(() => selectedTeacherId = v),
                    );
                  }),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = classNameCtrl.text.trim();
                            final grade = selectedGrade;
                            if (name.isEmpty || grade == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Nama dan tingkat wajib diisi')));
                              return;
                            }
                            bool ok = false;
                            if (isEdit) {
                              ok = await provider.update(existing!.id,
                                  className: name,
                                  gradeLevel: grade,
                                  homeroomTeacherId: selectedTeacherId);
                            } else {
                              ok = await provider.create(
                                  className: name,
                                  gradeLevel: grade,
                                  homeroomTeacherId: selectedTeacherId);
                            }
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(ok
                                    ? (isEdit
                                        ? 'Kelas diperbarui'
                                        : 'Kelas dibuat')
                                    : (provider.errorMessage ?? 'Gagal'))));
                          },
                          child: Text(isEdit ? 'Simpan' : 'Buat'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text("Coba Lagi")),
          ],
        ),
      ),
    );
  }
}
