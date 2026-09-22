import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';
import 'package:my_flutter_template/features/battle/domain/repository/battle_repository.dart';

class GetBattleSubjectsUseCase
    implements UseCase<List<BattleSubjectModel>, NoParams> {
  final BattleRepository repository;

  GetBattleSubjectsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BattleSubjectModel>>> call(NoParams params) {
    return repository.getSubjects();
  }
}

class GetBattleGradeStatsUseCase
    implements UseCase<List<BattleGradeStatModel>, NoParams> {
  final BattleRepository repository;

  GetBattleGradeStatsUseCase(this.repository);

  @override
  Future<Either<Failure, List<BattleGradeStatModel>>> call(NoParams params) {
    return repository.getGradeStats();
  }
}

class GetBattleRatingUseCase implements UseCase<BattleRatingModel, NoParams> {
  final BattleRepository repository;

  GetBattleRatingUseCase(this.repository);

  @override
  Future<Either<Failure, BattleRatingModel>> call(NoParams params) {
    return repository.getMyRating();
  }
}

class CreateBattleRoomParams {
  final int gradeId;
  final List<int> subjectIds;
  final int questionCount;
  final int secondsPerQuestion;

  CreateBattleRoomParams({
    required this.gradeId,
    required this.subjectIds,
    required this.questionCount,
    required this.secondsPerQuestion,
  });
}

class CreateBattleRoomUseCase implements UseCase<int, CreateBattleRoomParams> {
  final BattleRepository repository;

  CreateBattleRoomUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(CreateBattleRoomParams params) {
    return repository.createRoom(
      gradeId: params.gradeId,
      subjectIds: params.subjectIds,
      questionCount: params.questionCount,
      secondsPerQuestion: params.secondsPerQuestion,
    );
  }
}

class JoinBattleRoomUseCase implements UseCase<int, String> {
  final BattleRepository repository;

  JoinBattleRoomUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(String code) {
    return repository.joinRoom(code);
  }
}

class GetBattleHistoryUseCase
    implements UseCase<BattleHistoryResponseModel, NoParams> {
  final BattleRepository repository;

  GetBattleHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, BattleHistoryResponseModel>> call(NoParams params) {
    return repository.getHistory();
  }
}

class GetBattleEloHistoryUseCase
    implements UseCase<List<BattleEloHistoryPointModel>, NoParams> {
  final BattleRepository repository;

  GetBattleEloHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<BattleEloHistoryPointModel>>> call(
      NoParams params) {
    return repository.getEloHistory();
  }
}

class GetBattleLeaderboardUseCase
    implements UseCase<List<BattleLeaderboardEntryModel>, NoParams> {
  final BattleRepository repository;

  GetBattleLeaderboardUseCase(this.repository);

  @override
  Future<Either<Failure, List<BattleLeaderboardEntryModel>>> call(
      NoParams params) {
    return repository.getLeaderboard();
  }
}
