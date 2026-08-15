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
  static const String attendanceMe = "/attendance/me";
  static String attendanceChild(int studentId) => "/attendance/child/$studentId";
  static String attendanceSummary(int classId) => "/attendance/summary/$classId";
}