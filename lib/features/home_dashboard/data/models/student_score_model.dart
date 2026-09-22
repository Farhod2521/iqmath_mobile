class StudentScoreModel {
  final String student;
  final num sum;
  final num score;
  final num coin;

  StudentScoreModel({
    required this.student,
    required this.sum,
    required this.score,
    required this.coin,
  });

  factory StudentScoreModel.fromJson(Map<String, dynamic> json) {
    final data =
        (json['data'] is Map<String, dynamic>) ? json['data'] as Map<String, dynamic> : json;

    return StudentScoreModel(
      student: data['student']?.toString() ?? '',
      sum: data['sum'] ?? 0,
      score: data['score'] ?? 0,
      coin: data['coin'] ?? 0,
    );
  }

  factory StudentScoreModel.empty() => StudentScoreModel(
        student: '',
        sum: 0,
        score: 0,
        coin: 0,
      );
}
