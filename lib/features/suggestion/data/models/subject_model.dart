class SubjectSuggestion {
  final int id;
  final String nameUz;
  final String className;
  final String classUz;
  final String imageUz;
  final double progressPercent;
  final bool hasTakenDiagnostic;

  SubjectSuggestion({
    required this.id,
    required this.nameUz,
    required this.className,
    required this.classUz,
    required this.imageUz,
    required this.progressPercent,
    required this.hasTakenDiagnostic,
  });

  factory SubjectSuggestion.fromJson(Map<String, dynamic> json) {
    return SubjectSuggestion(
      id: json['id'] ?? 0,
      nameUz: json['name_uz'] ?? '',
      className: json['class_name'] ?? '',
      classUz: json['class_uz'] ?? '',
      imageUz: json['image_uz'] ?? '',
      progressPercent: (json['progress_percent'] ?? 0.0).toDouble(),
      hasTakenDiagnostic: json['has_taken_diagnostic'] ?? false,
    );
  }
}