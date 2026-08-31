import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/subject_provider.dart';
import '../../data/models/subject_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_stat_header.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_badge.dart';

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
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSubjectForm(context, provider: provider),
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(SubjectProvider provider) {
    if (provider.isLoading && provider.subjects.isEmpty)
      return const LoadingIndicator();

    if (provider.errorMessage != null && provider.subjects.isEmpty) {
      return _ErrorState(
        message: provider.errorMessage!,
        onRetry: () => context.read<SubjectProvider>().fetchAll(),
      );
    }

    if (provider.subjects.isEmpty) {
      return AdminEmptyState(
        icon: Icons.book_outlined,
        color: AppColors.accentGreen,
        message: "Belum ada mata pelajaran",
        ctaLabel: "Tambah mapel",
        onCta: () => _openSubjectForm(context, provider: provider),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<SubjectProvider>().fetchAll(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        itemCount: provider.subjects.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return AdminStatHeader(
              icon: Icons.book_outlined,
              color: AppColors.accentGreen,
              value: provider.subjects.length.toString(),
              label: "Mata pelajaran",
            );
          }
          final s = provider.subjects[index - 1];
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
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
                    backgroundColor: AppColors.accentGreen.withOpacity(0.12),
                    child: const Icon(Icons.book_outlined,
                        size: 18, color: AppColors.accentGreen),
                  ),
                  title: Text(s.subjectName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        AdminBadge(
                          label: s.type == 'mulok' ? 'Muatan Lokal' : 'Umum',
                          color: s.type == 'mulok'
                              ? const Color(0xFFA78BFA)
                              : AppColors.accentGreen,
                        ),
                        const SizedBox(width: 6),
                        Text("KKM ${s.kkm.toStringAsFixed(0)}",
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        _openSubjectForm(context,
                            provider: provider, existing: s);
                      } else if (v == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Konfirmasi'),
                            content:
                                const Text('Yakin ingin menghapus mapel ini?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                                ? 'Mapel dihapus'
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
              ));
        },
      ),
    );
  }

  void _openSubjectForm(BuildContext context,
      {required SubjectProvider provider, SubjectModel? existing}) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.subjectName ?? '');
    final kkmCtrl = TextEditingController(
        text: existing != null ? existing.kkm.toStringAsFixed(0) : '70');
    String selectedType = existing?.type ?? 'general';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
                      Text(isEdit ? 'Edit Mapel' : 'Tambah Mapel',
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
                    decoration: const InputDecoration(labelText: 'Nama Mapel'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipe'),
                    items: const [
                      DropdownMenuItem(value: 'general', child: Text('Umum')),
                      DropdownMenuItem(
                          value: 'mulok', child: Text('Muatan Lokal')),
                    ],
                    onChanged: (v) =>
                        setState(() => selectedType = v ?? 'general'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: kkmCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'KKM'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameCtrl.text.trim();
                            final kkm = double.tryParse(kkmCtrl.text.trim());
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Nama mapel wajib diisi')));
                              return;
                            }
                            bool ok = false;
                            if (isEdit) {
                              ok = await provider.update(existing.id,
                                  subjectName: name,
                                  type: selectedType,
                                  kkm: kkm);
                            } else {
                              ok = await provider.create(
                                  subjectName: name,
                                  type: selectedType,
                                  kkm: kkm);
                            }
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text(ok
                                  ? (isEdit
                                      ? 'Mapel diperbarui'
                                      : 'Mapel dibuat')
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
