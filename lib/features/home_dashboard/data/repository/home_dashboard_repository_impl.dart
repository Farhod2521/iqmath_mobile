import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/exceptions.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/home_dashboard/data/data_source/remote/home_dashboard_remote_data_source.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/home_dashboard_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/rating_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/student_score_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/study_stats_model.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/repository/home_dashboard_repository.dart';

class HomeDashboardRepositoryImpl implements HomeDashboardRepository {
  final HomeDashboardRemoteDataSource remoteDataSource;

  HomeDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, HomeDashboardModel>> getHomeDashboard({int? classId}) async {
    try {
      final response = await remoteDataSource.getHomeDashboard(classId: classId);
      return Right(response);
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, StudentScoreModel>> getMyScore() async {
    try {
      final response = await remoteDataSource.getMyScore();
      return Right(response);
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, RatingResponseModel>> getRating() async {
    try {
      final response = await remoteDataSource.getRating();
      return Right(response);
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, StudyStatsResponseModel>> getStudyStatsByDate({
    required String dateFrom,
    required String dateTo,
    required int pageSize,
  }) async {
    try {
      final response = await remoteDataSource.getStudyStatsByDate(
        dateFrom: dateFrom,
        dateTo: dateTo,
        pageSize: pageSize,
      );
      return Right(response);
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
