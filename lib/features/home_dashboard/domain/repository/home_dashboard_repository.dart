import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/home_dashboard_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/rating_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/student_score_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/study_stats_model.dart';

abstract class HomeDashboardRepository {
  Future<Either<Failure, HomeDashboardModel>> getHomeDashboard({int? classId});

  Future<Either<Failure, StudentScoreModel>> getMyScore();

  Future<Either<Failure, RatingResponseModel>> getRating();

  Future<Either<Failure, StudyStatsResponseModel>> getStudyStatsByDate({
    required String dateFrom,
    required String dateTo,
    required int pageSize,
  });
}
