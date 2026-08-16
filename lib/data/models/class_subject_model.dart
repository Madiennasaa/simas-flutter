class ClassSubjectModel {
  final int id;
  final int classId;
  final String? className;
  final int subjectId;
  final String? subjectName;
  final int teacherId;
  final String? teacherName;
  final int academicYearId;

  ClassSubjectModel({
    required this.id,
    required this.classId,
    this.className,
    required this.subjectId,
    this.subjectName,
    required this.teacherId,
    this.teacherName,
    required this.academicYearId,
  });

  factory ClassSubjectModel.fromJson(Map<String, dynamic> json) {
    return ClassSubjectModel(
      id: json["id"],
      classId: json["classId"],
      className: json["class"]?["className"],
      subjectId: json["subjectId"],
      subjectName: json["subject"]?["subjectName"],
      teacherId: json["teacherId"],
      teacherName: json["teacher"]?["user"]?["name"],
      academicYearId: json["academicYearId"],
    );
  }
}
