import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/class_subject_model.dart';
import 'material_list_view.dart';
import 'assignment_list_view.dart';
import 'grade_input_view.dart';
import 'attendance_input_view.dart';

/// Hub navigasi buat guru setelah pilih salah satu kelas+mapel yang dia
/// ajar — dari sini masuk ke Materi, Tugas, Nilai, atau Absensi untuk
/// kelas+mapel itu spesifik.
class ClassSubjectDetailView extends StatelessWidget {
  final ClassSubjectModel classSubject;

  const ClassSubjectDetailView({super.key, required this.classSubject});

  @override
  Widget build(BuildContext context) {
    final items = [
      _HubItem(
        icon: Icons.menu_book_outlined,
        label: "Materi",
        color: AppColors.accentGreen,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MaterialListView(classSubject: classSubject))),
      ),
      _HubItem(
        icon: Icons.assignment_outlined,
        label: "Tugas",
        color: const Color(0xFF5B8DEF),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AssignmentListView(classSubject: classSubject))),
      ),
      _HubItem(
        icon: Icons.grade_outlined,
        label: "Nilai",
        color: const Color(0xFFF5A623),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => GradeInputView(classSubject: classSubject))),
      ),
      _HubItem(
        icon: Icons.checklist_rtl_outlined,
        label: "Absensi",
        color: const Color(0xFFEF6C6C),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AttendanceInputView(classSubject: classSubject))),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
            "${classSubject.subjectName} • Kelas ${classSubject.className}"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.3,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: item.onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.textPrimary.withOpacity(0.05),
                        offset: const Offset(0, 4),
                        blurRadius: 12)
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: item.color.withOpacity(0.12),
                          shape: BoxShape.circle),
                      child: Icon(item.icon, size: 26, color: item.color),
                    ),
                    const SizedBox(height: 10),
                    Text(item.label,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HubItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _HubItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}
