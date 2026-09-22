// Model classes
class DiagnosticHistoryResponse {
  final List<SubjectData> subjects;

  DiagnosticHistoryResponse({required this.subjects});

  factory DiagnosticHistoryResponse.fromJson(List<dynamic> json) {
    return DiagnosticHistoryResponse(
      subjects: json.map((item) => SubjectData.fromJson(item)).toList(),
    );
  }
}

class SubjectData {
  final int id;
  final String nameUz;
  final String nameRu;
  final String className;
  final String classUz;
  final String classRu;
  final String imageUz;
  final String imageRu;
  final double progressPercent;
  final List<ProgressHistory> progressHistory;
  final String? lastDate;
  final bool hasTakenDiagnostic;
  final List<RepeatedTopic> repeatedTopics;

  SubjectData({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.className,
    required this.classUz,
    required this.classRu,
    required this.imageUz,
    required this.imageRu,
    required this.progressPercent,
    required this.progressHistory,
    this.lastDate,
    required this.hasTakenDiagnostic,
    required this.repeatedTopics,
  });

  factory SubjectData.fromJson(Map<String, dynamic> json) {
    return SubjectData(
      id: json['id'] ?? 0,
      nameUz: json['name_uz'] ?? '',
      nameRu: json['name_ru'] ?? '',
      className: json['class_name'] ?? '',
      classUz: json['class_uz'] ?? '',
      classRu: json['class_ru'] ?? '',
      imageUz: json['image_uz'] ?? '',
      imageRu: json['image_ru'] ?? '',
      progressPercent: (json['progress_percent'] ?? 0.0).toDouble(),
      progressHistory: (json['progress_history'] as List<dynamic>?)
          ?.map((item) => ProgressHistory.fromJson(item))
          .toList() ??
          [],
      lastDate: json['last_date'],
      hasTakenDiagnostic: json['has_taken_diagnostic'] ?? false,
      repeatedTopics: (json['repeated_topics'] as List<dynamic>?)
          ?.map((item) => RepeatedTopic.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class ProgressHistory {
  final String? date;
  final double score;

  ProgressHistory({
    this.date,
    required this.score,
  });

  factory ProgressHistory.fromJson(Map<String, dynamic> json) {
    return ProgressHistory(
      date: json['date'],
      score: (json['score'] ?? 0.0).toDouble(),
    );
  }
}

class RepeatedTopic {
  final int id;
  final String nameUz;
  final String nameRu;
  final int repeatCount;

  RepeatedTopic({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.repeatCount,
  });

  factory RepeatedTopic.fromJson(Map<String, dynamic> json) {
    return RepeatedTopic(
      id: json['id'] ?? 0,
      nameUz: json['name_uz'] ?? '',
      nameRu: json['name_ru'] ?? '',
      repeatCount: json['repeat_count'] ?? 0,
    );
  }
}