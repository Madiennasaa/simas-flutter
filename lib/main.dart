import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/academic_year_provider.dart';
import 'providers/class_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/student_provider.dart';
import 'providers/class_subject_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/material_provider.dart';
import 'providers/assignment_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/grade_provider.dart';
import 'views/auth/login_view.dart';
import 'views/widgets/loading_indicator.dart';
import 'views/admin/admin_dashboard_view.dart';
import 'views/teacher/teacher_dashboard_view.dart';
import 'views/student/student_dashboard_view.dart';
import 'views/parent/parent_dashboard_view.dart';
import 'views/headmaster/headmaster_dashboard_view.dart';

void main() {
  runApp(const SimasApp());
}

class SimasApp extends StatelessWidget {
  const SimasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => AcademicYearProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => ClassSubjectProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => MaterialProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => GradeProvider()),
      ],
      child: MaterialApp(
        title: "SIMAS",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        home: const _RootRouter(),
      ),
    );
  }
}

/// Nentuin halaman pertama yang dilihat user berdasarkan status auth:
/// masih ngecek token -> loading, belum login -> LoginView,
/// udah login -> langsung ke dashboard sesuai role (skip halaman login).
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    switch (authProvider.status) {
      case AuthStatus.checking:
        return const Scaffold(body: LoadingIndicator());

      case AuthStatus.unauthenticated:
        return const LoginView();

      case AuthStatus.authenticated:
        switch (authProvider.user?.role) {
          case "admin":
            return const AdminDashboardView();
          case "teacher":
            return const TeacherDashboardView();
          case "student":
            return const StudentDashboardView();
          case "parent":
            return const ParentDashboardView();
          case "headmaster":
            return const HeadmasterDashboardView();
          default:
            return const LoginView();
        }
    }
  }
}
