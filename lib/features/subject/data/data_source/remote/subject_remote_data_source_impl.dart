import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_flutter_template/features/subject/data/data_source/remote/subject_remote_data_source.dart';
import 'package:my_flutter_template/features/subject/data/models/subject_response.dart';

import '../../../../../constants/constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/platform/network_info.dart';

class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  final Dio dio;
  final NetworkInfo networkInfo;

  SubjectRemoteDataSourceImpl({required this.dio, required this.networkInfo});

  @override
  Future<List<SubjectResponse>> getSubjects() async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}${Urls.SUBJECTS}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> jsonList = response.data as List<dynamic>;

        // Oddiy parsing (compute siz)
        return jsonList
            .map((json) =>
                SubjectResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error: ${e.toString()}',
        title: 'Error',
      );
    }
  }
}
