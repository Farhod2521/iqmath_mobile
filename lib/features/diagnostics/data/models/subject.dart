class Subject {
  final int id;
  final String nameUz;
  final String className;
  final String classUz;
  final String imageUz;
  final String imageRu;
  final double progressPercent;
  final bool hasTakenDiagnostic;
  final String classRu;
  final String nameRu;

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
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      nameUz: json['name_uz'] ?? '',
      className: json['class_name'] ?? '',
      classUz: json['class_uz'] ?? '',
      imageUz: json['image_uz'] ?? '',
      progressPercent: (json['progress_percent'] ?? 0.0).toDouble(),
      hasTakenDiagnostic: json['has_taken_diagnostic'] ?? false,
      classRu: json['class_ru'] ?? '',
      nameRu: json['name_ru'] ?? '',
      imageRu: json['image_ru'] ?? '',
    );
  }
}