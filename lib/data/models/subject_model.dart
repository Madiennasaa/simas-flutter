class SubjectModel {
  final int id;
  final String subjectName;
  final String type; // 'general' | 'mulok'
  final double kkm;

  SubjectModel({
    required this.id,
    required this.subjectName,
    required this.type,
    required this.kkm,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json["id"],
      subjectName: json["subjectName"],
      type: json["type"],
      kkm: double.tryParse(json["kkm"].toString()) ?? 70,
    );
  }
}
