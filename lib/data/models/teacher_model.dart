class TeacherModel {
  final int id;
  final int userId;
  final String name;
  final String username;
  final String? phoneNumber;
  final String? nip;
  final String teacherType; // 'homeroom' | 'subject_specialist'

  TeacherModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.username,
    this.phoneNumber,
    this.nip,
    required this.teacherType,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    final user = json["user"] ?? {};
    return TeacherModel(
      id: json["id"],
      userId: json["userId"],
      name: user["name"] ?? "",
      username: user["username"] ?? "",
      phoneNumber: user["phoneNumber"],
      nip: json["nip"],
      teacherType: json["teacherType"],
    );
  }
}
