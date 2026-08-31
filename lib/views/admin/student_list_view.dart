import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/student_provider.dart';
import '../../providers/class_provider.dart';
import '../../data/models/student_model.dart';
import '../../data/models/school_class_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_stat_header.dart';
import '../widgets/admin_empty_state.dart';

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
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openStudentForm(context, provider: studentProvider),
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<int?>(
                    value: null, child: Text("Semua kelas")),
                ...classProvider.classes.map(
                  (c) => DropdownMenuItem<int?>(
                      value: c.id, child: Text("Kelas ${c.className}")),
                ),
              ],
              onChanged: _onClassFilterChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AdminStatHeader(
              icon: Icons.people_outline,
              color: AppColors.accentGreenDark,
              value: studentProvider.students.length.toString(),
              label: _selectedClassId == null
                  ? "Total siswa"
                  : "Siswa di kelas ini",
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
          child: Text(provider.errorMessage!,
              style: const TextStyle(color: AppColors.error)),
        ),
      );
    }

    if (provider.students.isEmpty) {
      return AdminEmptyState(
        icon: Icons.people_outline,
        color: AppColors.accentGreenDark,
        message: _selectedClassId == null
            ? "Belum ada siswa terdaftar"
            : "Belum ada siswa di kelas ini",
        ctaLabel: "Tambah siswa",
        onCta: () => _openStudentForm(context, provider: provider),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<StudentProvider>().fetchAll(classId: _selectedClassId),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: provider.students.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final s = provider.students[index];
          return Card(
            elevation: 0,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.fieldLine),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.secondary.withOpacity(0.1),
                child: Text(
                  s.name.isNotEmpty ? s.name[0].toUpperCase() : "?",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
              ),
              title: Text(s.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              subtitle: Text(
                "NISN: ${s.nisn ?? '-'}${s.className != null ? ' • Kelas ${s.className}' : ''}",
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    _openStudentForm(context, provider: provider, existing: s);
                  } else if (v == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text('Yakin ingin menghapus siswa ini?'),
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
                      final ok = await provider.remove(s.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? 'Siswa dihapus'
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

  void _openStudentForm(BuildContext context,
      {required StudentProvider provider, StudentModel? existing}) {
    final isEdit = existing != null;
    final usernameCtrl = TextEditingController(text: existing?.username ?? '');
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final nisnCtrl = TextEditingController(text: existing?.nisn ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phoneNumber ?? '');
    int? selectedClassId = existing?.classId ?? _selectedClassId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final classProvider = context.read<ClassProvider>();
        if (classProvider.classes.isEmpty && !classProvider.isLoading)
          classProvider.fetchAll();

        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(isEdit ? 'Edit Siswa' : 'Tambah Siswa',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!isEdit) ...[
                    TextFormField(
                        controller: usernameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Username')),
                    const SizedBox(height: 8),
                    TextFormField(
                        controller: passwordCtrl,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password')),
                    const SizedBox(height: 8),
                  ],
                  TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nama')),
                  const SizedBox(height: 8),
                  TextFormField(
                      controller: nisnCtrl,
                      decoration: const InputDecoration(
                          labelText: 'NISN (opsional kelas 1)')),
                  const SizedBox(height: 8),
                  TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                          labelText: 'No. HP (opsional)')),
                  const SizedBox(height: 8),
                  Consumer<ClassProvider>(builder: (context, cp, __) {
                    if (cp.isLoading) return const LinearProgressIndicator();
                    return DropdownButtonFormField<int>(
                      value: selectedClassId,
                      decoration:
                          const InputDecoration(labelText: 'Pilih Kelas'),
                      items: cp.classes
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text('Kelas ${c.className}')))
                          .toList(),
                      onChanged: (v) => setState(() => selectedClassId = v),
                    );
                  }),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final username = usernameCtrl.text.trim();
                          final password = passwordCtrl.text;
                          final name = nameCtrl.text.trim();
                          final nisn = nisnCtrl.text.trim();
                          final phone = phoneCtrl.text.trim().isEmpty
                              ? null
                              : phoneCtrl.text.trim();
                          final classId = selectedClassId;

                          if (!isEdit) {
                            // Determine selected class grade level
                            SchoolClassModel? selectedClass;
                            try {
                              selectedClass = classProvider.classes
                                  .firstWhere((c) => c.id == classId);
                            } catch (_) {
                              selectedClass = null;
                            }
                            final isGrade1 = selectedClass != null &&
                                selectedClass.gradeLevel == 1;

                            if (username.isEmpty ||
                                password.isEmpty ||
                                name.isEmpty ||
                                classId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Nama, Username, Password, dan Kelas wajib diisi')));
                              return;
                            }

                            if (!isGrade1 && nisn.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'NISN wajib diisi untuk siswa kelas 2 ke atas')));
                              return;
                            }

                            final nisnVal = nisn.isEmpty ? null : nisn;
                            final ok = await provider.create(
                                username: username,
                                password: password,
                                name: name,
                                nisn: nisnVal,
                                classId: classId,
                                phoneNumber: phone);

                            if (!ctx.mounted) return;

                            if (ok) {
                              // 🟢 KALAU SUKSES: Tutup modal & tampilkan toast hijau
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Siswa berhasil dibuat'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else {
                              // 🔴 KALAU GAGAL: JANGAN POP MODAL! Tampilkan snackbar error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.errorMessage ??
                                      'Gagal membuat siswa'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          } else {
                            SchoolClassModel? selectedClass;
                            try {
                              selectedClass = classProvider.classes
                                  .firstWhere((c) => c.id == classId);
                            } catch (_) {
                              selectedClass = null;
                            }
                            final isGrade1 = selectedClass != null &&
                                selectedClass.gradeLevel == 1;

                            if (name.isEmpty || classId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Nama dan Kelas wajib diisi')));
                              return;
                            }

                            if (!isGrade1 && nisn.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'NISN wajib diisi untuk siswa kelas 2 ke atas')));
                              return;
                            }

                            final nisnVal = nisn.isEmpty ? null : nisn;
                            final ok = await provider.update(existing.id,
                                name: name,
                                nisn: nisnVal,
                                phoneNumber: phone,
                                classId: classId);

                            if (!ctx.mounted) return;

                            if (ok) {
                              // 🟢 KALAU SUKSES UPDATE: Tutup modal & tampilkan toast hijau
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Siswa diperbarui'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else {
                              // 🔴 KALAU GAGAL UPDATE: JANGAN POP MODAL! Tampilkan snackbar error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.errorMessage ??
                                      'Gagal memperbarui siswa'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(isEdit ? 'Simpan' : 'Buat'),
                      ),
                    ),
                  ])
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
