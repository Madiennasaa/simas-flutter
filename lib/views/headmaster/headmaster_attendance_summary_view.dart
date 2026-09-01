import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/academic_year_provider.dart';
import '../widgets/loading_indicator.dart';

class HeadmasterAttendanceSummaryView extends StatefulWidget {
  const HeadmasterAttendanceSummaryView({super.key});

  @override
  State<HeadmasterAttendanceSummaryView> createState() =>
      _HeadmasterAttendanceSummaryViewState();
}

class _HeadmasterAttendanceSummaryViewState
    extends State<HeadmasterAttendanceSummaryView> {
  int? _selectedClassId;
  int? _selectedAcademicYearId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final classProvider = context.read<ClassProvider>();
      final ayProvider = context.read<AcademicYearProvider>();
      if (classProvider.classes.isEmpty) await classProvider.fetchAll();
      if (ayProvider.years.isEmpty) await ayProvider.fetchAll();
      setState(() {
        _selectedAcademicYearId = ayProvider.active?.id;
        if (classProvider.classes.isNotEmpty)
          _selectedClassId = classProvider.classes.first.id;
      });
      _fetch();
    });
  }

  void _fetch() {
    if (_selectedClassId != null && _selectedAcademicYearId != null) {
      context
          .read<AttendanceProvider>()
          .fetchClassSummary(_selectedClassId!, _selectedAcademicYearId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();
    final ayProvider = context.watch<AcademicYearProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final summary = attendanceProvider.summary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Ringkasan Kehadiran"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedClassId,
                    decoration: const InputDecoration(
                        labelText: 'Kelas',
                        isDense: true,
                        border: OutlineInputBorder()),
                    items: classProvider.classes
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text('Kelas ${c.className}')))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedClassId = v);
                      _fetch();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedAcademicYearId,
                    decoration: const InputDecoration(
                        labelText: 'Tahun Ajaran',
                        isDense: true,
                        border: OutlineInputBorder()),
                    items: ayProvider.years
                        .map((y) =>
                            DropdownMenuItem(value: y.id, child: Text(y.label)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedAcademicYearId = v);
                      _fetch();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: attendanceProvider.isLoading
                ? const LoadingIndicator()
                : summary == null
                    ? const Center(
                        child: Text("Pilih kelas & tahun ajaran",
                            style: TextStyle(color: AppColors.textMuted)))
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.success.withOpacity(0.18)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "${summary['persentaseHadir']}%",
                                    style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.success),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Persentase Kehadiran",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _StatBox(
                                    label: "Hadir",
                                    value: summary['hadir'].toString(),
                                    color: AppColors.success),
                                const SizedBox(width: 8),
                                _StatBox(
                                    label: "Sakit",
                                    value: summary['sakit'].toString(),
                                    color: const Color(0xFFF5A623)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _StatBox(
                                    label: "Izin",
                                    value: summary['izin'].toString(),
                                    color: const Color(0xFF5B8DEF)),
                                const SizedBox(width: 8),
                                _StatBox(
                                    label: "Alpha",
                                    value: summary['alpha'].toString(),
                                    color: AppColors.error),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text("Total ${summary['total']} catatan absensi",
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.fieldLine),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
