class SchoolClassModel {
  final int id;
  final String className;
  final int gradeLevel;
  final int? homeroomTeacherId;
  final String? homeroomTeacherName;
  final int studentCount;

  SchoolClassModel({
    required this.id,
    required this.className,
    required this.gradeLevel,
    this.homeroomTeacherId,
    this.homeroomTeacherName,
    this.studentCount = 0,
  });

  factory SchoolClassModel.fromJson(Map<String, dynamic> json) {
    return SchoolClassModel(
      id: json["id"],
      className: json["className"],
      gradeLevel: json["gradeLevel"],
      // phase removed
      homeroomTeacherId: json["homeroomTeacherId"],
      homeroomTeacherName: json["homeroomTeacher"]?["user"]?["name"],
      studentCount: json["_count"]?["students"] ?? 0,
    );
  }
}
