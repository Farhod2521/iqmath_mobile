import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/exceptions.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/battle/data/data_source/remote/battle_remote_data_source.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';
import 'package:my_flutter_template/features/battle/domain/repository/battle_repository.dart';

class BattleRepositoryImpl implements BattleRepository {
  final BattleRemoteDataSource remoteDataSource;

  BattleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BattleSubjectModel>>> getSubjects() async {
    try {
      return Right(await remoteDataSource.getSubjects());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BattleGradeStatModel>>> getGradeStats() async {
    try {
      return Right(await remoteDataSource.getGradeStats());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, BattleRatingModel>> getMyRating() async {
    try {
      return Right(await remoteDataSource.getMyRating());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> createRoom({
    required int gradeId,
    required List<int> subjectIds,
    required int questionCount,
    required int secondsPerQuestion,
  }) async {
    try {
      final roomId = await remoteDataSource.createRoom(
        gradeId: gradeId,
        subjectIds: subjectIds,
        questionCount: questionCount,
        secondsPerQuestion: secondsPerQuestion,
      );
      return Right(roomId);
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> joinRoom(String code) async {
    try {
      return Right(await remoteDataSource.joinRoom(code));
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, BattleHistoryResponseModel>> getHistory() async {
    try {
      return Right(await remoteDataSource.getHistory());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BattleEloHistoryPointModel>>>
      getEloHistory() async {
    try {
      return Right(await remoteDataSource.getEloHistory());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BattleLeaderboardEntryModel>>> getLeaderboard({
    int topCount = 50,
  }) async {
    try {
      return Right(await remoteDataSource.getLeaderboard(topCount: topCount));
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  Failure _toFailure(Object e) {
    return ServerFailure(
      message: (e is ServerException) ? e.message : 'Something went wrong!',
      title: (e is ServerException) ? e.title : 'Error',
    );
  }
}
