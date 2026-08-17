import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return "http://localhost:3000/api"; 
    }
    return "http://10.0.2.2:3000/api"; 
  }

  static const String login = "/auth/login";
  static const String me = "/auth/me";

  static const String attendance = "/attendance";
  static const String attendanceBulk = "/attendance/bulk";
  static const String attendanceMe = "/attendance/me";
  static String attendanceChild(int studentId) => "/attendance/child/$studentId";
  static String attendanceSummary(int classId) => "/attendance/summary/$classId";

  static const String academicYears = "/academic-years";
  static String academicYearSetActive(int id) => "/academic-years/$id/set-active";

  static const String classes = "/classes";
  static const String subjects = "/subjects";
  static const String teachers = "/teachers";
  static const String students = "/students";
  static const String classSubjects = "/class-subjects";

  static const String schedules = "/schedules";
  static const String materials = "/materials";
  static const String assignments = "/assignments";
  static const String announcements = "/announcements";

  static const String grades = "/grades";
  static const String gradesMe = "/grades/me";
  static String gradesChild(int studentId) => "/grades/child/$studentId";
  static String gradesByClassSubject(int classSubjectId) => "/grades/class-subject/$classSubjectId";
}