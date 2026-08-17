class ScheduleModel {
  final int id;
  final int classSubjectId;
  final String day; // senin..sabtu
  final String startTime; // "HH:MM:SS"
  final String endTime;
  final String? className;
  final String? subjectName;
  final String? teacherName;

  ScheduleModel({
    required this.id,
    required this.classSubjectId,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.className,
    this.subjectName,
    this.teacherName,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final cs = json["classSubject"];
    // Backend kirim startTime/endTime sebagai ISO datetime (tanggal 1970-01-01),
    // ambil bagian jamnya aja.
    String extractTime(String iso) => iso.substring(11, 16);

    return ScheduleModel(
      id: json["id"],
      classSubjectId: json["classSubjectId"],
      day: json["day"],
      startTime: extractTime(json["startTime"]),
      endTime: extractTime(json["endTime"]),
      className: cs?["class"]?["className"],
      subjectName: cs?["subject"]?["subjectName"],
      teacherName: cs?["teacher"]?["user"]?["name"],
    );
  }
}
