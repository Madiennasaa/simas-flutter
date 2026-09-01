/// Merepresentasikan response `user` dari POST /auth/login dan GET /auth/me.
/// Field student/teacher/parent nullable karena cuma salah satu yang keisi
/// tergantung role user-nya.
class UserModel {
  final int id;
  final String username;
  final String name;
  final String
      role; // 'admin' | 'teacher' | 'student' | 'parent' | 'headmaster'
  final String? phoneNumber;

  // Diambil dari JWT payload (lihat authService.js backend), bukan dari body /auth/me.
  // Dipakai buat query yang butuh ID relasi langsung tanpa lookup ulang.
  final int? studentId;
  final int? teacherId;
  final int? parentId;

  // Khusus role student: kelas dia sendiri, dipakai buat filter jadwal,
  // materi, tugas, dan absensi tanpa perlu lookup /students (yang tidak
  // bisa diakses siswa).
  final int? classId;
  final String? className;

  // Khusus role parent: daftar anak (id siswa + kelasnya), dipakai buat
  // pilih anak mana yang mau dilihat datanya.
  final List<ParentChild>? children;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.studentId,
    this.teacherId,
    this.parentId,
    this.classId,
    this.className,
    this.children,
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
      classId: json["classId"],
      className: json["className"],
      children: (json["children"] as List?)
          ?.map((c) => ParentChild.fromJson(c))
          .toList(),
    );
  }

  bool get isAdmin => role == "admin";
  bool get isTeacher => role == "teacher";
  bool get isStudent => role == "student";
  bool get isParent => role == "parent";
  bool get isHeadmaster => role == "headmaster";
}

class ParentChild {
  final int id;
  final int classId;
  final String? name;
  final String? className;

  ParentChild(
      {required this.id, required this.classId, this.name, this.className});

  factory ParentChild.fromJson(Map<String, dynamic> json) {
    return ParentChild(
      id: json["id"],
      classId: json["classId"],
      name: json["name"],
      className: json["className"],
    );
  }
}
