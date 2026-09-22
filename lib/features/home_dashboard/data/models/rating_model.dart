class RatingEntryModel {
  final String fullName;
  final num value;

  RatingEntryModel({required this.fullName, required this.value});

  factory RatingEntryModel.fromJson(Map<String, dynamic> json, String valueKey) {
    return RatingEntryModel(
      fullName: json['full_name']?.toString() ?? '',
      value: json[valueKey] ?? 0,
    );
  }
}

class RatingCategoryModel {
  final List<RatingEntryModel> top3;
  final int? myRank;
  final num myValue;

  RatingCategoryModel({
    required this.top3,
    required this.myRank,
    required this.myValue,
  });

  factory RatingCategoryModel.fromJson(
      Map<String, dynamic>? json, String valueKey) {
    if (json == null) {
      return RatingCategoryModel(top3: [], myRank: null, myValue: 0);
    }
    return RatingCategoryModel(
      top3: (json['top_3'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => RatingEntryModel.fromJson(e, valueKey))
          .toList(),
      myRank: json['my_rank'],
      myValue: json['my_value'] ?? 0,
    );
  }
}

class RatingResponseModel {
  final RatingCategoryModel score;

  RatingResponseModel({required this.score});

  factory RatingResponseModel.fromJson(Map<String, dynamic> json) {
    final data =
        (json['data'] is Map<String, dynamic>) ? json['data'] as Map<String, dynamic> : json;

    return RatingResponseModel(
      score: RatingCategoryModel.fromJson(
          data['score'] as Map<String, dynamic>?, 'score'),
    );
  }

  factory RatingResponseModel.empty() =>
      RatingResponseModel(score: RatingCategoryModel.fromJson(null, 'score'));
}
