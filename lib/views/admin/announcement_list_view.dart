import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/announcement_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class AnnouncementListView extends StatefulWidget {
  const AnnouncementListView({super.key});

  @override
  State<AnnouncementListView> createState() => _AnnouncementListViewState();
}

class _AnnouncementListViewState extends State<AnnouncementListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().fetchAll();
    });
  }

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const _CreateAnnouncementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Pengumuman"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(AnnouncementProvider provider) {
    if (provider.isLoading && provider.announcements.isEmpty) return const LoadingIndicator();

    if (provider.errorMessage != null && provider.announcements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
        ),
      );
    }

    if (provider.announcements.isEmpty) {
      return const Center(child: Text("Belum ada pengumuman", style: TextStyle(color: AppColors.textSecondary)));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AnnouncementProvider>().fetchAll(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.announcements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final a = provider.announcements[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                        onPressed: () => context.read<AnnouncementProvider>().remove(a.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(a.content, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CreateAnnouncementSheet extends StatefulWidget {
  const _CreateAnnouncementSheet();

  @override
  State<_CreateAnnouncementSheet> createState() => _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends State<_CreateAnnouncementSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _targetRole = "all";
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    final success = await context.read<AnnouncementProvider>().create(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          targetRole: _targetRole,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Buat Pengumuman", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul", border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: "Isi Pengumuman", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _targetRole,
            decoration: const InputDecoration(labelText: "Target", border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: "all", child: Text("Semua orang")),
              DropdownMenuItem(value: "teacher", child: Text("Guru")),
              DropdownMenuItem(value: "student", child: Text("Siswa")),
              DropdownMenuItem(value: "parent", child: Text("Wali Murid")),
            ],
            onChanged: (v) => setState(() => _targetRole = v ?? "all"),
          ),
          const SizedBox(height: 16),
          CustomButton(label: "Simpan", isLoading: _isSubmitting, onPressed: _submit),
        ],
      ),
    );
  }
}
