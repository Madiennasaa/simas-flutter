import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/material_provider.dart';
import '../../providers/assignment_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_badge.dart';

class StudentSubjectDetailView extends StatefulWidget {
  final int classSubjectId;
  final String subjectName;

  const StudentSubjectDetailView(
      {super.key, required this.classSubjectId, required this.subjectName});

  @override
  State<StudentSubjectDetailView> createState() =>
      _StudentSubjectDetailViewState();
}

class _StudentSubjectDetailViewState extends State<StudentSubjectDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialProvider>().fetchAll(widget.classSubjectId);
      context.read<AssignmentProvider>().fetchAll(widget.classSubjectId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.subjectName),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accentGreen,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.accentGreen,
          tabs: const [Tab(text: 'Materi'), Tab(text: 'Tugas')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMaterials(), _buildAssignments()],
      ),
    );
  }

  Widget _buildMaterials() {
    final provider = context.watch<MaterialProvider>();
    if (provider.isLoading && provider.materials.isEmpty)
      return const LoadingIndicator();
    if (provider.materials.isEmpty) {
      return const AdminEmptyState(
          icon: Icons.menu_book_outlined,
          color: AppColors.accentGreen,
          message: "Belum ada materi");
    }
    return ListView.separated(
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
                child:
                    Icon(Icons.link, size: 18, color: AppColors.accentGreen)),
            title: Text(m.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            subtitle: m.description != null
                ? Text(m.description!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary))
                : null,
            trailing: const Icon(Icons.open_in_new,
                size: 18, color: AppColors.textMuted),
            onTap: () => _openLink(m.linkUrl),
          ),
        );
      },
    );
  }

  Widget _buildAssignments() {
    final provider = context.watch<AssignmentProvider>();
    if (provider.isLoading && provider.assignments.isEmpty)
      return const LoadingIndicator();
    if (provider.assignments.isEmpty) {
      return const AdminEmptyState(
          icon: Icons.assignment_outlined,
          color: Color(0xFF5B8DEF),
          message: "Belum ada tugas");
    }
    return ListView.separated(
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
                Text(a.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
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
                    color:
                        a.isOverdue ? AppColors.error : const Color(0xFF5B8DEF),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
