class AnnouncementModel {
  final int id;
  final String title;
  final String content;
  final String targetRole; // 'all' | 'teacher' | 'student' | 'parent'
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.targetRole,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json["id"],
      title: json["title"],
      content: json["content"],
      targetRole: json["targetRole"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
