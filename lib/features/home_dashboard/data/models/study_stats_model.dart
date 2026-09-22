class StudyStatsDayModel {
  final DateTime date;
  final bool completed;

  StudyStatsDayModel({required this.date, required this.completed});

  factory StudyStatsDayModel.fromJson(Map<String, dynamic> json) {
    return StudyStatsDayModel(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      completed: json['completed'] == true,
    );
  }
}

class StudyStatsResponseModel {
  final List<StudyStatsDayModel> results;

  StudyStatsResponseModel({required this.results});

  factory StudyStatsResponseModel.fromJson(Map<String, dynamic> json) {
    final data =
        (json['data'] is Map<String, dynamic>) ? json['data'] as Map<String, dynamic> : json;
    final rawResults = data['results'] as List<dynamic>? ?? [];

    return StudyStatsResponseModel(
      results: rawResults
          .whereType<Map<String, dynamic>>()
          .map(StudyStatsDayModel.fromJson)
          .toList(),
    );
  }

  factory StudyStatsResponseModel.empty() =>
      StudyStatsResponseModel(results: []);
}
