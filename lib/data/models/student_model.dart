class StudentModel {
  final int id;
  final int userId;
  final String name;
  final String username;
  final String? phoneNumber;
  final String nisn;
  final int classId;
  final String? className;

  StudentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.username,
    this.phoneNumber,
    required this.nisn,
    required this.classId,
    this.className,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final user = json["user"] ?? {};
    return StudentModel(
      id: json["id"],
      userId: json["userId"],
      name: user["name"] ?? "",
      username: user["username"] ?? "",
      phoneNumber: user["phoneNumber"],
      nisn: json["nisn"],
      classId: json["classId"],
      className: json["class"]?["className"],
    );
  }
}
