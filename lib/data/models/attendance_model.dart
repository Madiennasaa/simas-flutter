class AttendanceModel {
  final int id;
  final int studentId;
  final String? studentName;
  final int classSubjectId;
  final String? subjectName;
  final DateTime date;
  final String status; // 'hadir' | 'sakit' | 'izin' | 'alpha'
  final String? proofUrl;
  final String? note;

  AttendanceModel({
    required this.id,
    required this.studentId,
    this.studentName,
    required this.classSubjectId,
    this.subjectName,
    required this.date,
    required this.status,
    this.proofUrl,
    this.note,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json["id"],
      studentId: json["studentId"],
      studentName: json["student"]?["user"]?["name"],
      classSubjectId: json["classSubjectId"],
      subjectName: json["classSubject"]?["subject"]?["subjectName"],
      date: DateTime.parse(json["date"]),
      status: json["status"],
      proofUrl: json["proofUrl"],
      note: json["note"],
    );
  }
}

/// Dipakai buat kirim satu baris absensi dalam payload bulkCreate.
class AttendanceRecordInput {
  final int studentId;
  final String status;
  final String? note;
  final String? proofUrl;

  AttendanceRecordInput({required this.studentId, required this.status, this.note, this.proofUrl});

  Map<String, dynamic> toJson() => {
        "studentId": studentId,
        "status": status,
        if (note != null) "note": note,
        if (proofUrl != null) "proofUrl": proofUrl,
      };
}
