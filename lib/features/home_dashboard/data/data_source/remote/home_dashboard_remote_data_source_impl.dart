import 'package:dio/dio.dart';
import 'package:my_flutter_template/constants/constants.dart';
import 'package:my_flutter_template/core/error/exceptions.dart';
import 'package:my_flutter_template/features/home_dashboard/data/data_source/remote/home_dashboard_remote_data_source.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/home_dashboard_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/rating_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/student_score_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/study_stats_model.dart';

class HomeDashboardRemoteDataSourceImpl implements HomeDashboardRemoteDataSource {
  final Dio dio;

  HomeDashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<HomeDashboardModel> getHomeDashboard({int? classId}) async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}${Urls.HOME_DASHBOARD}",
        queryParameters: {
          if (classId != null) 'class_id': classId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return HomeDashboardModel.fromJson(response.data);
      }
      throw ServerException.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<StudentScoreModel> getMyScore() async {
    try {
      final response = await dio.get("${Constants.baseUrl}${Urls.MY_SCORE}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StudentScoreModel.fromJson(response.data);
      }
      throw ServerException.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<RatingResponseModel> getRating() async {
    try {
      final response = await dio.get("${Constants.baseUrl}${Urls.RATING}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return RatingResponseModel.fromJson(response.data);
      }
      throw ServerException.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<StudyStatsResponseModel> getStudyStatsByDate({
    required String dateFrom,
    required String dateTo,
    required int pageSize,
  }) async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}${Urls.STUDY_STATS_BY_DATE}",
        queryParameters: {
          'date_from': dateFrom,
          'date_to': dateTo,
          'page_size': pageSize,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StudyStatsResponseModel.fromJson(response.data);
      }
      throw ServerException.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }
}
