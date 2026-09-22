import 'package:my_flutter_template/features/home_dashboard/data/models/home_dashboard_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/rating_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/student_score_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/study_stats_model.dart';

abstract class HomeDashboardRemoteDataSource {
  Future<HomeDashboardModel> getHomeDashboard({int? classId});

  Future<StudentScoreModel> getMyScore();

  Future<RatingResponseModel> getRating();

  Future<StudyStatsResponseModel> getStudyStatsByDate({
    required String dateFrom,
    required String dateTo,
    required int pageSize,
  });
}
