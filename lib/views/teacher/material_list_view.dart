import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/material_provider.dart';
import '../../data/models/class_subject_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_empty_state.dart';

class MaterialListView extends StatefulWidget {
  final ClassSubjectModel classSubject;

  const MaterialListView({super.key, required this.classSubject});

  @override
  State<MaterialListView> createState() => _MaterialListViewState();
}

class _MaterialListViewState extends State<MaterialListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialProvider>().fetchAll(widget.classSubject.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MaterialProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Materi"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, provider),
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(MaterialProvider provider) {
    if (provider.isLoading && provider.materials.isEmpty)
      return const LoadingIndicator();

    if (provider.materials.isEmpty) {
      return AdminEmptyState(
        icon: Icons.menu_book_outlined,
        color: AppColors.accentGreen,
        message: "Belum ada materi untuk kelas ini",
        ctaLabel: "Tambah materi",
        onCta: () => _openForm(context, provider),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<MaterialProvider>().fetchAll(widget.classSubject.id),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.materials.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final m = provider.materials[index];
          return Card(
            elevation: 0,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.fieldLine)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: Color(0x1F4CD08A),
                child: Icon(Icons.link, size: 18, color: AppColors.accentGreen),
              ),
              title: Text(m.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              subtitle: Text(m.description ?? m.linkUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Hapus materi ini?'),
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
                  if (confirmed == true) await provider.remove(m.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, MaterialProvider provider) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final linkCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
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
                const Text('Tambah Materi',
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
                decoration: const InputDecoration(labelText: 'Judul')),
            const SizedBox(height: 8),
            TextFormField(
                controller: descCtrl,
                decoration:
                    const InputDecoration(labelText: 'Deskripsi (opsional)'),
                maxLines: 2),
            const SizedBox(height: 8),
            TextFormField(
                controller: linkCtrl,
                decoration: const InputDecoration(
                    labelText: 'Link materi (Drive/YouTube/dll)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final link = linkCtrl.text.trim();
                  if (title.isEmpty || link.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Judul dan link wajib diisi')));
                    return;
                  }
                  final ok = await provider.create(
                    classSubjectId: widget.classSubject.id,
                    title: title,
                    description: descCtrl.text.trim().isEmpty
                        ? null
                        : descCtrl.text.trim(),
                    linkUrl: link,
                  );
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Materi ditambahkan'
                          : (provider.errorMessage ?? 'Gagal'))));
                },
                child: const Text('Simpan'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
