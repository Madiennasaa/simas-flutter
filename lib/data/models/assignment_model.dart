class AssignmentModel {
  final int id;
  final int classSubjectId;
  final String title;
  final String? description;
  final String? attachmentUrl;
  final DateTime? dueDate;
  final DateTime createdAt;

  AssignmentModel({
    required this.id,
    required this.classSubjectId,
    required this.title,
    this.description,
    this.attachmentUrl,
    this.dueDate,
    required this.createdAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json["id"],
      classSubjectId: json["classSubjectId"],
      title: json["title"],
      description: json["description"],
      attachmentUrl: json["attachmentUrl"],
      dueDate: json["dueDate"] != null ? DateTime.parse(json["dueDate"]) : null,
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }

  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now());
}
