import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/assignment_provider.dart';
import '../../data/models/class_subject_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_badge.dart';

class AssignmentListView extends StatefulWidget {
  final ClassSubjectModel classSubject;

  const AssignmentListView({super.key, required this.classSubject});

  @override
  State<AssignmentListView> createState() => _AssignmentListViewState();
}

class _AssignmentListViewState extends State<AssignmentListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentProvider>().fetchAll(widget.classSubject.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssignmentProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Tugas"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, provider),
        backgroundColor: const Color(0xFF5B8DEF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(AssignmentProvider provider) {
    if (provider.isLoading && provider.assignments.isEmpty)
      return const LoadingIndicator();

    if (provider.assignments.isEmpty) {
      return AdminEmptyState(
        icon: Icons.assignment_outlined,
        color: const Color(0xFF5B8DEF),
        message: "Belum ada tugas untuk kelas ini",
        ctaLabel: "Tambah tugas",
        onCta: () => _openForm(context, provider),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<AssignmentProvider>().fetchAll(widget.classSubject.id),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.assignments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final a = provider.assignments[index];
          return Card(
            elevation: 0,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.fieldLine)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(a.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textPrimary))),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: AppColors.error),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text('Hapus tugas ini?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Hapus')),
                              ],
                            ),
                          );
                          if (confirmed == true) await provider.remove(a.id);
                        },
                      ),
                    ],
                  ),
                  if (a.description != null) ...[
                    const SizedBox(height: 4),
                    Text(a.description!,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                  if (a.dueDate != null) ...[
                    const SizedBox(height: 8),
                    AdminBadge(
                      label:
                          "Deadline: ${a.dueDate!.day}/${a.dueDate!.month}/${a.dueDate!.year}${a.isOverdue ? ' (lewat)' : ''}",
                      color: a.isOverdue
                          ? AppColors.error
                          : const Color(0xFF5B8DEF),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, AssignmentProvider provider) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Tambah Tugas',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Judul Tugas')),
              const SizedBox(height: 8),
              TextFormField(
                  controller: descCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Deskripsi (opsional)'),
                  maxLines: 3),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(dueDate == null
                    ? 'Pilih deadline (opsional)'
                    : 'Deadline: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'),
                trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => dueDate = picked);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Judul tugas wajib diisi')));
                      return;
                    }
                    final ok = await provider.create(
                      classSubjectId: widget.classSubject.id,
                      title: title,
                      description: descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                      dueDate: dueDate,
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(ok
                            ? 'Tugas dibuat'
                            : (provider.errorMessage ?? 'Gagal'))));
                  },
                  child: const Text('Simpan'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
