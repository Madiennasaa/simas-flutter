class GradeModel {
  final int id;
  final int studentId;
  final String? studentName;
  final int classSubjectId;
  final String? subjectName;
  final int? assignmentId;
  final String? assignmentTitle;
  final String scoreType; // 'task_manual' | 'cbt' | 'uts' | 'uas'
  final double score;
  final String? note;

  GradeModel({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.classSubjectId,
    this.subjectName,
    this.assignmentId,
    this.assignmentTitle,
    required this.scoreType,
    required this.score,
    this.note,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json["id"],
      studentId: json["studentId"],
      studentName: json["student"]?["user"]?["name"],
      classSubjectId: json["classSubjectId"],
      subjectName: json["classSubject"]?["subject"]?["subjectName"],
      assignmentId: json["assignmentId"],
      assignmentTitle: json["assignment"]?["title"],
      scoreType: json["scoreType"],
      score: double.tryParse(json["score"].toString()) ?? 0,
      note: json["note"],
    );
  }
}

/// Dipakai buat kirim satu baris nilai dalam payload bulk create
class GradeRecordInput {
  final int studentId;
  final double score;
  final String? note;

  GradeRecordInput({required this.studentId, required this.score, this.note});

  Map<String, dynamic> toJson() => {
        "studentId": studentId,
        "score": score,
        if (note != null) "note": note,
      };
}
