import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/announcement_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_empty_state.dart';

class ParentAnnouncementsView extends StatefulWidget {
  const ParentAnnouncementsView({super.key});

  @override
  State<ParentAnnouncementsView> createState() =>
      _ParentAnnouncementsViewState();
}

class _ParentAnnouncementsViewState extends State<ParentAnnouncementsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Pengumuman"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: provider.isLoading && provider.announcements.isEmpty
          ? const LoadingIndicator()
          : provider.announcements.isEmpty
              ? const AdminEmptyState(
                  icon: Icons.campaign_outlined,
                  color: Color(0xFF4FBDBA),
                  message: "Belum ada pengumuman")
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<AnnouncementProvider>().fetchAll(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.announcements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final a = provider.announcements[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                  width: 4, color: const Color(0xFF4FBDBA)),
                              Expanded(
                                child: Card(
                                  elevation: 0,
                                  color: AppColors.surface,
                                  margin: EdgeInsets.zero,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12)),
                                    side:
                                        BorderSide(color: AppColors.fieldLine),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(a.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: AppColors.textPrimary)),
                                        const SizedBox(height: 4),
                                        Text(a.content,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color:
                                                    AppColors.textSecondary)),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${a.createdAt.day}/${a.createdAt.month}/${a.createdAt.year}",
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
