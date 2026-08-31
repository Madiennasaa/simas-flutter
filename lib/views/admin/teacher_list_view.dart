import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/teacher_provider.dart';
import '../../data/models/teacher_model.dart';
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
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTeacherForm(context, provider: provider),
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(TeacherProvider provider) {
    if (provider.isLoading && provider.teachers.isEmpty)
      return const LoadingIndicator();

    if (provider.errorMessage != null && provider.teachers.isEmpty) {
      return _ErrorState(
        message: provider.errorMessage!,
        onRetry: () => context.read<TeacherProvider>().fetchAll(),
      );
    }

    if (provider.teachers.isEmpty) {
      return const Center(
          child: Text("Belum ada guru",
              style: TextStyle(color: AppColors.textMuted)));
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
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.fieldLine),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFF5A623).withOpacity(0.12),
                child: const Icon(Icons.person_outline,
                    size: 18, color: Color(0xFFF5A623)),
              ),
              title: Text(t.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              subtitle: Text(
                "${t.teacherType == 'homeroom' ? 'Wali Kelas' : 'Guru Mapel'}"
                "${t.nip != null && t.nip!.isNotEmpty ? ' • NIP: ${t.nip}' : ''}"
                "${t.phoneNumber != null && t.phoneNumber!.isNotEmpty ? ' • ${t.phoneNumber}' : ''}",
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    _openTeacherForm(context, provider: provider, existing: t);
                  } else if (v == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text('Yakin ingin menghapus guru ini?'),
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
                      final ok = await provider.remove(t.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? 'Guru dihapus'
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

  void _openTeacherForm(BuildContext context,
      {required TeacherProvider provider, TeacherModel? existing}) {
    final isEdit = existing != null;
    final usernameCtrl = TextEditingController(text: existing?.username ?? '');
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final nipCtrl = TextEditingController(text: existing?.nip ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phoneNumber ?? '');
    String selectedType = existing?.teacherType ?? 'subject_specialist';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(isEdit ? 'Edit Guru' : 'Tambah Guru',
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
                      controller: nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Nama Lengkap'),
                    ),
                    const SizedBox(height: 8),
                    // Username & password cuma diisi pas tambah guru baru — akun
                    // yang sudah ada tidak bisa ganti username/password dari sini.
                    if (!isEdit) ...[
                      TextFormField(
                        controller: usernameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: passwordCtrl,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                      ),
                      const SizedBox(height: 8),
                    ],
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Tipe Guru'),
                      items: const [
                        DropdownMenuItem(
                            value: 'homeroom', child: Text('Wali Kelas')),
                        DropdownMenuItem(
                            value: 'subject_specialist',
                            child: Text('Guru Mapel')),
                      ],
                      onChanged: (v) => setState(
                          () => selectedType = v ?? 'subject_specialist'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nipCtrl,
                      decoration:
                          const InputDecoration(labelText: 'NIP (opsional)'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(labelText: 'No. HP (opsional)'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Nama wajib diisi')));
                                return;
                              }
                              if (!isEdit &&
                                  (usernameCtrl.text.trim().isEmpty ||
                                      passwordCtrl.text.trim().isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Username dan password wajib diisi')));
                                return;
                              }
                              bool ok = false;
                              if (isEdit) {
                                ok = await provider.update(
                                  existing.id,
                                  name: name,
                                  phoneNumber: phoneCtrl.text.trim(),
                                  nip: nipCtrl.text.trim(),
                                  teacherType: selectedType,
                                );
                              } else {
                                ok = await provider.create(
                                  username: usernameCtrl.text.trim(),
                                  password: passwordCtrl.text.trim(),
                                  name: name,
                                  teacherType: selectedType,
                                  nip: nipCtrl.text.trim().isEmpty
                                      ? null
                                      : nipCtrl.text.trim(),
                                  phoneNumber: phoneCtrl.text.trim().isEmpty
                                      ? null
                                      : phoneCtrl.text.trim(),
                                );
                              }
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content: Text(ok
                                    ? (isEdit
                                        ? 'Data guru diperbarui'
                                        : 'Guru berhasil ditambahkan')
                                    : (provider.errorMessage ?? 'Gagal')),
                              ));
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
