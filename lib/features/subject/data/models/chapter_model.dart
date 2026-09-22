import 'dart:ui';

class ChapterModel {
  final int id;
  final String nameUz;
  final String nameRu;
  final int subject;
  final double progress;

  ChapterModel({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.subject,
    required this.progress,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'],
      nameUz: json['name_uz'] ?? '',
      nameRu: json['name_ru'] ?? '',
      subject: json['subject'],
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  double get progressPercent => (progress);

  Color get progressColor {
    if (progress == 0) return const Color(0xFFE5E5EA);
    if (progress < 30) return const Color(0xFFFF3B30);
    if (progress < 70) return const Color(0xFFFF9500);
    return const Color(0xFF34C759);
  }
}
