import 'package:dio/dio.dart';
import 'package:my_flutter_template/constants/constants.dart';
import 'package:my_flutter_template/core/error/exceptions.dart';
import 'package:my_flutter_template/features/battle/data/data_source/remote/battle_remote_data_source.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';

class BattleRemoteDataSourceImpl implements BattleRemoteDataSource {
  final Dio dio;

  BattleRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BattleSubjectModel>> getSubjects() async {
    try {
      final response =
          await dio.get("${Constants.baseUrl}${Urls.BATTLE_SUBJECTS}");
      final data = response.data;
      final list = (data is Map<String, dynamic> ? data['results'] : data)
              as List<dynamic>? ??
          [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(BattleSubjectModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<List<BattleGradeStatModel>> getGradeStats() async {
    try {
      final response =
          await dio.get("${Constants.baseUrl}${Urls.BATTLE_GRADE_STATS}");
      final data = response.data;
      final list = (data is Map<String, dynamic> ? data['results'] : data)
              as List<dynamic>? ??
          [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(BattleGradeStatModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<BattleRatingModel> getMyRating() async {
    try {
      final response =
          await dio.get("${Constants.baseUrl}${Urls.BATTLE_RATING_ME}");
      return BattleRatingModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<int> createRoom({
    required int gradeId,
    required List<int> subjectIds,
    required int questionCount,
    required int secondsPerQuestion,
  }) async {
    try {
      final response = await dio.post(
        "${Constants.baseUrl}${Urls.BATTLE_ROOM_CREATE}",
        data: {
          'grade_id': gradeId,
          'subject_ids': subjectIds,
          'question_count': questionCount,
          'seconds_per_question': secondsPerQuestion,
        },
      );
      final roomId = response.data?['room']?['id'];
      if (roomId == null) {
        throw ServerException(
          title: 'Xatolik',
          message: "Xona yaratib bo'lmadi",
        );
      }
      return roomId is int ? roomId : int.parse(roomId.toString());
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<int> joinRoom(String code) async {
    try {
      final response = await dio.post(
        "${Constants.baseUrl}${Urls.BATTLE_ROOM_JOIN}",
        data: {'code': code},
      );
      final roomId = response.data?['room']?['id'];
      if (roomId == null) {
        throw ServerException(
          title: 'Xatolik',
          message: "Xonaga qo'shilib bo'lmadi",
        );
      }
      return roomId is int ? roomId : int.parse(roomId.toString());
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<BattleHistoryResponseModel> getHistory() async {
    try {
      final response =
          await dio.get("${Constants.baseUrl}${Urls.BATTLE_HISTORY}");
      return BattleHistoryResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<List<BattleEloHistoryPointModel>> getEloHistory() async {
    try {
      final response =
          await dio.get("${Constants.baseUrl}${Urls.BATTLE_ELO_HISTORY}");
      final data = response.data;
      final list = (data is Map<String, dynamic> ? data['results'] : data)
              as List<dynamic>? ??
          [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(BattleEloHistoryPointModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<List<BattleLeaderboardEntryModel>> getLeaderboard({
    int topCount = 50,
  }) async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}${Urls.BATTLE_LEADERBOARD}",
        queryParameters: {'top_count': topCount},
      );
      final data = response.data;
      final list = (data is Map<String, dynamic> ? data['results'] : data)
              as List<dynamic>? ??
          [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(BattleLeaderboardEntryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }
}
