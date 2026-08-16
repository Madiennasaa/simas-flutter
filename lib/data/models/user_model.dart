/// Merepresentasikan response `user` dari POST /auth/login dan GET /auth/me.
/// Field student/teacher/parent nullable karena cuma salah satu yang keisi
/// tergantung role user-nya.
class UserModel {
  final int id;
  final String username;
  final String name;
  final String role; // 'admin' | 'teacher' | 'student' | 'parent' | 'headmaster'
  final String? phoneNumber;

  // Diambil dari JWT payload (lihat authService.js backend), bukan dari body /auth/me.
  // Dipakai buat query yang butuh ID relasi langsung tanpa lookup ulang.
  final int? studentId;
  final int? teacherId;
  final int? parentId;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.studentId,
    this.teacherId,
    this.parentId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // /auth/login balikin `id`, /auth/me balikin isi token mentah yang field-nya `userId`.
      // Ditampung dua-duanya biar model ini bisa dipakai buat parsing keduanya.
      id: json["id"] ?? json["userId"],
      username: json["username"] ?? "",
      name: json["name"],
      role: json["role"],
      phoneNumber: json["phoneNumber"] ?? json["phone_number"],
      studentId: json["studentId"],
      teacherId: json["teacherId"],
      parentId: json["parentId"],
    );
  }

  bool get isAdmin => role == "admin";
  bool get isTeacher => role == "teacher";
  bool get isStudent => role == "student";
  bool get isParent => role == "parent";
  bool get isHeadmaster => role == "headmaster";
}
