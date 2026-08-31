import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/class_subject_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/academic_year_provider.dart';
import '../widgets/loading_indicator.dart';

/// Halaman assign guru ke kelas + mapel pada tahun ajaran tertentu.
/// Tidak ada mode edit (sesuai backend: cuma create & delete) — kalau
/// salah assign, hapus lalu buat penugasan baru.
class ClassSubjectListView extends StatefulWidget {
  /// Kalau diisi (dari shortcut "Kelola Penugasan" di halaman Guru), daftar
  /// otomatis difilter ke guru ini dan namanya ditampilkan di AppBar.
  final int? filterTeacherId;
  final String? filterTeacherName;

  const ClassSubjectListView(
      {super.key, this.filterTeacherId, this.filterTeacherName});

  @override
  State<ClassSubjectListView> createState() => _ClassSubjectListViewState();
}

class _ClassSubjectListViewState extends State<ClassSubjectListView> {
  int? _filterAcademicYearId;

  Future<void> _fetch() {
    return context.read<ClassSubjectProvider>().fetchAll(
          academicYearId: _filterAcademicYearId,
          teacherId: widget.filterTeacherId,
        );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ayProvider = context.read<AcademicYearProvider>();
      if (ayProvider.academicYears.isEmpty) {
        await ayProvider.fetchAll();
      }
      // Default filter ke tahun ajaran yang lagi aktif, biar relevan.
      final active = ayProvider.academicYears.where((y) => y.isActive).toList();
      setState(() =>
          _filterAcademicYearId = active.isNotEmpty ? active.first.id : null);
      _fetch();

      // Data pendukung buat form (kelas, mapel, guru).
      if (context.read<ClassProvider>().classes.isEmpty)
        context.read<ClassProvider>().fetchAll();
      if (context.read<SubjectProvider>().subjects.isEmpty)
        context.read<SubjectProvider>().fetchAll();
      if (context.read<TeacherProvider>().teachers.isEmpty)
        context.read<TeacherProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassSubjectProvider>();
    final ayProvider = context.watch<AcademicYearProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.filterTeacherName != null
            ? "Penugasan: ${widget.filterTeacherName}"
            : "Penugasan Guru"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: DropdownButtonFormField<int>(
              value: _filterAcademicYearId,
              decoration: const InputDecoration(
                labelText: 'Tahun Ajaran',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: ayProvider.academicYears
                  .map((y) =>
                      DropdownMenuItem(value: y.id, child: Text(y.label)))
                  .toList(),
              onChanged: (v) {
                setState(() => _filterAcademicYearId = v);
                _fetch();
              },
            ),
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAssignForm(context, provider: provider),
        backgroundColor: AppColors.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(ClassSubjectProvider provider) {
    if (provider.isLoading && provider.classSubjects.isEmpty)
      return const LoadingIndicator();

    if (provider.errorMessage != null && provider.classSubjects.isEmpty) {
      return _ErrorState(
        message: provider.errorMessage!,
        onRetry: _fetch,
      );
    }

    if (provider.classSubjects.isEmpty) {
      return const Center(
        child: Text("Belum ada penugasan guru pada tahun ajaran ini",
            style: TextStyle(color: AppColors.textMuted)),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.classSubjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final cs = provider.classSubjects[index];
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
                backgroundColor: const Color(0xFFA78BFA).withOpacity(0.12),
                child: const Icon(Icons.assignment_ind_outlined,
                    size: 18, color: Color(0xFFA78BFA)),
              ),
              title: Text(
                cs.subjectName ?? 'Mapel #${cs.subjectId}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              subtitle: Text(
                "Kelas ${cs.className ?? cs.classId} • ${cs.teacherName ?? 'Guru #${cs.teacherId}'}",
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Hapus penugasan guru ini?'),
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
                    final ok = await provider.remove(cs.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Penugasan dihapus'
                          : (provider.errorMessage ?? 'Gagal menghapus')),
                    ));
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _openAssignForm(BuildContext context,
      {required ClassSubjectProvider provider}) {
    int? selectedClassId;
    int? selectedSubjectId;
    int? selectedTeacherId = widget.filterTeacherId;
    int? selectedAcademicYearId = _filterAcademicYearId;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Tambah Penugasan Guru',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Consumer<AcademicYearProvider>(builder: (context, ayp, __) {
                      return DropdownButtonFormField<int>(
                        value: selectedAcademicYearId,
                        decoration:
                            const InputDecoration(labelText: 'Tahun Ajaran'),
                        items: ayp.academicYears
                            .map((y) => DropdownMenuItem(
                                value: y.id, child: Text(y.label)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => selectedAcademicYearId = v),
                      );
                    }),
                    const SizedBox(height: 8),
                    Consumer<ClassProvider>(builder: (context, cp, __) {
                      return DropdownButtonFormField<int>(
                        value: selectedClassId,
                        decoration: const InputDecoration(labelText: 'Kelas'),
                        items: cp.classes
                            .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text('Kelas ${c.className}')))
                            .toList(),
                        onChanged: (v) => setState(() => selectedClassId = v),
                      );
                    }),
                    const SizedBox(height: 8),
                    Consumer<SubjectProvider>(builder: (context, sp, __) {
                      return DropdownButtonFormField<int>(
                        value: selectedSubjectId,
                        decoration:
                            const InputDecoration(labelText: 'Mata Pelajaran'),
                        items: sp.subjects
                            .map((s) => DropdownMenuItem(
                                value: s.id, child: Text(s.subjectName)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedSubjectId = v),
                      );
                    }),
                    const SizedBox(height: 8),
                    Consumer<TeacherProvider>(builder: (context, tp, __) {
                      return DropdownButtonFormField<int>(
                        value: selectedTeacherId,
                        decoration:
                            const InputDecoration(labelText: 'Guru Pengampu'),
                        items: tp.teachers
                            .map((t) => DropdownMenuItem(
                                value: t.id, child: Text(t.name)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedTeacherId = v),
                      );
                    }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedClassId == null ||
                              selectedSubjectId == null ||
                              selectedTeacherId == null ||
                              selectedAcademicYearId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Semua field wajib dipilih')));
                            return;
                          }
                          final ok = await provider.create(
                            classId: selectedClassId!,
                            subjectId: selectedSubjectId!,
                            teacherId: selectedTeacherId!,
                            academicYearId: selectedAcademicYearId!,
                          );
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text(ok
                                ? 'Penugasan berhasil dibuat'
                                : (provider.errorMessage ?? 'Gagal')),
                          ));
                        },
                        child: const Text('Simpan'),
                      ),
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
