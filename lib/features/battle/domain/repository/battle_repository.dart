import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';

abstract class BattleRepository {
  Future<Either<Failure, List<BattleSubjectModel>>> getSubjects();

  Future<Either<Failure, List<BattleGradeStatModel>>> getGradeStats();

  Future<Either<Failure, BattleRatingModel>> getMyRating();

  Future<Either<Failure, int>> createRoom({
    required int gradeId,
    required List<int> subjectIds,
    required int questionCount,
    required int secondsPerQuestion,
  });

  Future<Either<Failure, int>> joinRoom(String code);

  Future<Either<Failure, BattleHistoryResponseModel>> getHistory();

  Future<Either<Failure, List<BattleEloHistoryPointModel>>> getEloHistory();

  Future<Either<Failure, List<BattleLeaderboardEntryModel>>> getLeaderboard({
    int topCount,
  });
}
