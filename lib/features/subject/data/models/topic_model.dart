import 'package:flutter/cupertino.dart';

class TopicModel {
  final int id;
  final String nameUz;
  final String nameRu;
  final int chapter;
  final String videoUrlUz;
  final String videoUrlRu;
  final String contentUz;
  final String contentRu;
  final bool isLocked;
  final bool isOpen;
  final double score;
  final double progress; // 0.0 to 1.0

  TopicModel({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.chapter,
    required this.videoUrlUz,
    required this.videoUrlRu,
    required this.contentUz,
    required this.contentRu,
    required this.isLocked,
    required this.isOpen,
    required this.score,
    this.progress = 0.0,
  });

  // Progress as percentage
  double get progressPercent => (progress);

  // Get color based on progress and lock status
  Color get progressColor {
    if (isLocked) {
      return CupertinoColors.systemGrey;
    }
    if (score == 0) {
      return CupertinoColors.systemBlue;
    }
    if (score < 25) {
      return CupertinoColors.systemRed;
    }
    if (score < 50) {
      return CupertinoColors.systemOrange;
    }
    if (score < 100) {
      return CupertinoColors.systemYellow;
    }
    return CupertinoColors.systemGreen;
  }

  // Factory constructor from JSON
  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] ?? 0,
      nameUz: json['name_uz'] ?? '',
      nameRu: json['name_ru'] ?? '',
      chapter: json['chapter'] ?? 0,
      videoUrlUz: json['video_url_uz'] ?? '',
      videoUrlRu: json['video_url_ru'] ?? '',
      contentUz: json['content_uz'] ?? '',
      contentRu: json['content_ru'] ?? '',
      isLocked: json['is_locked'] ?? false,
      isOpen: json['is_open'] ?? false,
      score: (json['score'] ?? 0.0).toDouble(),
      progress: 0.0, // You'll need to get this from user progress data
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_uz': nameUz,
      'name_ru': nameRu,
      'chapter': chapter,
      'video_url_uz': videoUrlUz,
      'video_url_ru': videoUrlRu,
      'content_uz': contentUz,
      'content_ru': contentRu,
      'is_locked': isLocked,
      'is_open': isOpen,
      'score': score,
    };
  }

  // Copy with method for updating specific fields
  TopicModel copyWith({
    int? id,
    String? nameUz,
    String? nameRu,
    int? chapter,
    String? videoUrlUz,
    String? videoUrlRu,
    String? contentUz,
    String? contentRu,
    bool? isLocked,
    bool? isOpen,
    double? score,
    double? progress,
  }) {
    return TopicModel(
      id: id ?? this.id,
      nameUz: nameUz ?? this.nameUz,
      nameRu: nameRu ?? this.nameRu,
      chapter: chapter ?? this.chapter,
      videoUrlUz: videoUrlUz ?? this.videoUrlUz,
      videoUrlRu: videoUrlRu ?? this.videoUrlRu,
      contentUz: contentUz ?? this.contentUz,
      contentRu: contentRu ?? this.contentRu,
      isLocked: isLocked ?? this.isLocked,
      isOpen: isOpen ?? this.isOpen,
      score: score ?? this.score,
      progress: progress ?? this.progress,
    );
  }
}