class ClassOptionModel {
  final int id;
  final String name;

  ClassOptionModel({required this.id, required this.name});

  factory ClassOptionModel.fromJson(Map<String, dynamic> json) {
    return ClassOptionModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class ContinueLearningModel {
  final int? subjectId;
  final int? chapterId;
  final int? topicId;
  final String subjectNameUz;
  final String subjectNameRu;
  final String chapterNameUz;
  final String chapterNameRu;
  final int? chapterOrder;
  final int topicsDoneInChapter;
  final int topicsTotalInChapter;
  final int percent;

  ContinueLearningModel({
    this.subjectId,
    this.chapterId,
    this.topicId,
    required this.subjectNameUz,
    required this.subjectNameRu,
    required this.chapterNameUz,
    required this.chapterNameRu,
    this.chapterOrder,
    required this.topicsDoneInChapter,
    required this.topicsTotalInChapter,
    required this.percent,
  });

  factory ContinueLearningModel.fromJson(Map<String, dynamic> json) {
    return ContinueLearningModel(
      subjectId: json['subject_id'],
      chapterId: json['chapter_id'],
      topicId: json['topic_id'],
      subjectNameUz: json['subject_name_uz']?.toString() ?? '',
      subjectNameRu: json['subject_name_ru']?.toString() ?? '',
      chapterNameUz: json['chapter_name_uz']?.toString() ?? '',
      chapterNameRu: json['chapter_name_ru']?.toString() ?? '',
      chapterOrder: json['chapter_order'],
      topicsDoneInChapter: json['topics_done_in_chapter'] ?? 0,
      topicsTotalInChapter: json['topics_total_in_chapter'] ?? 0,
      percent: json['percent'] ?? 0,
    );
  }

  String subjectName(String locale) =>
      locale == 'ru' ? subjectNameRu : subjectNameUz;

  String chapterName(String locale) =>
      locale == 'ru' ? chapterNameRu : chapterNameUz;
}

class HomeStatsModel {
  final int chapterCount;
  final int chaptersStartedCount;
  final int topicCount;
  final int completedTopicCount;
  final num averageScorePercent;
  final int questionCount;
  final int solvedQuestionsCount;

  HomeStatsModel({
    required this.chapterCount,
    required this.chaptersStartedCount,
    required this.topicCount,
    required this.completedTopicCount,
    required this.averageScorePercent,
    required this.questionCount,
    required this.solvedQuestionsCount,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return HomeStatsModel.empty();
    return HomeStatsModel(
      chapterCount: json['chapter_count'] ?? 0,
      chaptersStartedCount: json['chapters_started_count'] ?? 0,
      topicCount: json['topic_count'] ?? 0,
      completedTopicCount: json['completed_topic_count'] ?? 0,
      averageScorePercent: json['average_score_percent'] ?? 0,
      questionCount: json['question_count'] ?? 0,
      solvedQuestionsCount: json['solved_questions_count'] ?? 0,
    );
  }

  factory HomeStatsModel.empty() => HomeStatsModel(
        chapterCount: 0,
        chaptersStartedCount: 0,
        topicCount: 0,
        completedTopicCount: 0,
        averageScorePercent: 0,
        questionCount: 0,
        solvedQuestionsCount: 0,
      );
}

class RecentActivityItemModel {
  final int? topicId;
  final String topicNameUz;
  final String topicNameRu;
  final String subjectNameUz;
  final String subjectNameRu;
  final num score;
  final String completedAt;
  final int ballEarned;
  final int coinEarned;

  RecentActivityItemModel({
    this.topicId,
    required this.topicNameUz,
    required this.topicNameRu,
    required this.subjectNameUz,
    required this.subjectNameRu,
    required this.score,
    required this.completedAt,
    required this.ballEarned,
    required this.coinEarned,
  });

  factory RecentActivityItemModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityItemModel(
      topicId: json['topic_id'],
      topicNameUz: json['topic_name_uz']?.toString() ?? '',
      topicNameRu: json['topic_name_ru']?.toString() ?? '',
      subjectNameUz: json['subject_name_uz']?.toString() ?? '',
      subjectNameRu: json['subject_name_ru']?.toString() ?? '',
      score: json['score'] ?? 0,
      completedAt: json['completed_at']?.toString() ?? '',
      ballEarned: json['ball_earned'] ?? 0,
      coinEarned: json['coin_earned'] ?? 0,
    );
  }

  String topicName(String locale) => locale == 'ru' ? topicNameRu : topicNameUz;

  String subjectName(String locale) =>
      locale == 'ru' ? subjectNameRu : subjectNameUz;
}

class HomeDashboardModel {
  final List<ClassOptionModel> classes;
  final String currentClassName;
  final ContinueLearningModel? continueLearning;
  final HomeStatsModel stats;
  final List<RecentActivityItemModel> recentActivity;

  HomeDashboardModel({
    required this.classes,
    required this.currentClassName,
    required this.continueLearning,
    required this.stats,
    required this.recentActivity,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    final data =
        (json['data'] is Map<String, dynamic>) ? json['data'] as Map<String, dynamic> : json;

    return HomeDashboardModel(
      classes: (data['classes'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ClassOptionModel.fromJson)
          .toList(),
      currentClassName: data['current_class_name']?.toString() ?? '',
      continueLearning: data['continue_learning'] is Map<String, dynamic>
          ? ContinueLearningModel.fromJson(
              data['continue_learning'] as Map<String, dynamic>)
          : null,
      stats: HomeStatsModel.fromJson(data['stats'] as Map<String, dynamic>?),
      recentActivity: (data['recent_activity'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(RecentActivityItemModel.fromJson)
          .toList(),
    );
  }
}
