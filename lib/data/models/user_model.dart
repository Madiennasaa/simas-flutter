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
      id: (json["id"] ?? json["userId"]) as int,
      username: (json["username"] ?? "") as String,
      name: (json["name"] ?? "") as String, // Tambah fallback "" biar gak crash
      role: (json["role"] ?? "") as String,
      phoneNumber: json["phoneNumber"] ?? json["phone_number"],
      
      // Ambil ID relasi: Cek dari JWT payload dulu, kalo gak ada baru intip dari object nested login!
      studentId: json["studentId"] ?? json["student"]?["id"],
      teacherId: json["teacherId"] ?? json["teacher"]?["id"],
      parentId: json["parentId"] ?? json["parent"]?["id"],
    );
  }

  bool get isAdmin => role == "admin";
  bool get isTeacher => role == "teacher";
  bool get isStudent => role == "student";
  bool get isParent => role == "parent";
  bool get isHeadmaster => role == "headmaster";
}
