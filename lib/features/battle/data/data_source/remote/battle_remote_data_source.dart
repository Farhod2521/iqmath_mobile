import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';

abstract class BattleRemoteDataSource {
  Future<List<BattleSubjectModel>> getSubjects();

  Future<List<BattleGradeStatModel>> getGradeStats();

  Future<BattleRatingModel> getMyRating();

  /// Muvaffaqiyatli bo'lsa yaratilgan xonaning ID raqamini qaytaradi.
  Future<int> createRoom({
    required int gradeId,
    required List<int> subjectIds,
    required int questionCount,
    required int secondsPerQuestion,
  });

  /// Muvaffaqiyatli bo'lsa qo'shilingan xonaning ID raqamini qaytaradi.
  Future<int> joinRoom(String code);

  Future<BattleHistoryResponseModel> getHistory();

  Future<List<BattleEloHistoryPointModel>> getEloHistory();

  Future<List<BattleLeaderboardEntryModel>> getLeaderboard({int topCount = 50});
}
