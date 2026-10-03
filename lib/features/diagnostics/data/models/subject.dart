/// `GET /func_student/my-diagnost-subjects/` elementi.
class Subject {
  final int id;
  final String nameUz;
  final String className;
  final String classUz;
  final String imageUz;
  final String imageRu;
  final double progressPercent; // oxirgi diagnostika natijasi (0-100)
  final bool hasTakenDiagnostic;
  final String classRu;
  final String nameRu;
  final int attemptsCount;
  final String? lastTakenAt; // "dd.MM.yyyy"
  final int weakTopicsCount;

  Subject({
    required this.id,
    required this.nameUz,
    required this.className,
    required this.classUz,
    required this.imageUz,
    required this.progressPercent,
    required this.hasTakenDiagnostic,
    required this.classRu,
    required this.nameRu,
    required this.imageRu,
    this.attemptsCount = 0,
    this.lastTakenAt,
    this.weakTopicsCount = 0,
  });

  /// Natija foizi butun son ko'rinishida (0-100).
  int get score => progressPercent.round().clamp(0, 100);

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      nameUz: json['name_uz'] ?? '',
      className: json['class_name']?.toString() ?? '',
      classUz: json['class_uz'] ?? '',
      imageUz: json['image_uz'] ?? '',
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
      hasTakenDiagnostic: json['has_taken_diagnostic'] ?? false,
      classRu: json['class_ru'] ?? '',
      nameRu: json['name_ru'] ?? '',
      imageRu: json['image_ru'] ?? '',
      attemptsCount: (json['attempts_count'] as num?)?.toInt() ?? 0,
      lastTakenAt: json['last_taken_at']?.toString(),
      weakTopicsCount: (json['weak_topics_count'] as num?)?.toInt() ?? 0,
    );
  }
}
