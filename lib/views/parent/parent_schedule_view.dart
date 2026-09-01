import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/schedule_provider.dart';
import '../../data/models/user_model.dart';
import '../../data/models/schedule_model.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/admin_empty_state.dart';

const _dayOrder = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu'];
const _dayLabel = {
  'senin': 'Senin',
  'selasa': 'Selasa',
  'rabu': 'Rabu',
  'kamis': 'Kamis',
  'jumat': "Jum'at",
  'sabtu': 'Sabtu',
};

class ParentScheduleView extends StatefulWidget {
  final ParentChild child;

  const ParentScheduleView({super.key, required this.child});

  @override
  State<ParentScheduleView> createState() => _ParentScheduleViewState();
}

class _ParentScheduleViewState extends State<ParentScheduleView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().fetchAll(classId: widget.child.classId);
    });
  }

  Map<String, List<ScheduleModel>> _groupByDay(List<ScheduleModel> schedules) {
    final map = <String, List<ScheduleModel>>{};
    for (final s in schedules) {
      map.putIfAbsent(s.day, () => []).add(s);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final grouped = _groupByDay(provider.schedules);
    final days = _dayOrder.where((d) => grouped.containsKey(d)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Jadwal ${widget.child.name ?? ''}"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: provider.isLoading && provider.schedules.isEmpty
          ? const LoadingIndicator()
          : days.isEmpty
              ? const AdminEmptyState(
                  icon: Icons.schedule_outlined,
                  color: Color(0xFF5B8DEF),
                  message: "Belum ada jadwal untuk kelas anak ini")
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: days.length,
                  itemBuilder: (context, dayIndex) {
                    final day = days[dayIndex];
                    final items = grouped[day]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                  width: 4,
                                  height: 16,
                                  color: const Color(0xFF5B8DEF),
                                  margin: const EdgeInsets.only(right: 8)),
                              Text(_dayLabel[day] ?? day,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...items.map((s) => Card(
                                elevation: 0,
                                color: AppColors.surface,
                                margin: const EdgeInsets.only(bottom: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side:
                                        BorderSide(color: AppColors.fieldLine)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(s.startTime,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF5B8DEF))),
                                      Text(s.endTime,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textMuted)),
                                    ],
                                  ),
                                  title: Text(s.subjectName ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                  subtitle: Text(s.teacherName ?? '',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                                ),
                              )),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
