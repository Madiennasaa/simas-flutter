class AcademicYearModel {
  final int id;
  final String year;
  final String semester; // 'odd' | 'even'
  final bool isActive;
  final bool isLocked;

  AcademicYearModel({
    required this.id,
    required this.year,
    required this.semester,
    required this.isActive,
    required this.isLocked,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> json) {
    return AcademicYearModel(
      id: json["id"],
      year: json["year"],
      semester: json["semester"],
      isActive: json["isActive"] ?? false,
      isLocked: json["isLocked"] ?? false,
    );
  }

  String get label => "$year - ${semester == 'odd' ? 'Ganjil' : 'Genap'}";
}
