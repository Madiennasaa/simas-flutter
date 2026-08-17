class MaterialModel {
  final int id;
  final int classSubjectId;
  final String title;
  final String? description;
  final String linkUrl;
  final DateTime createdAt;

  MaterialModel({
    required this.id,
    required this.classSubjectId,
    required this.title,
    this.description,
    required this.linkUrl,
    required this.createdAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json["id"],
      classSubjectId: json["classSubjectId"],
      title: json["title"],
      description: json["description"],
      linkUrl: json["linkUrl"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
