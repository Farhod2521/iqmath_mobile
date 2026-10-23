import 'dart:io';
import 'dart:typed_data';

import 'package:my_flutter_template/features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'package:my_flutter_template/features/profile/data/models/faq_response.dart';
import 'package:my_flutter_template/features/profile/data/models/user_update_request.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_flutter_template/features/profile/data/models/user_update_response.dart';

import '../../../../../constants/constants.dart';
import '../../../../../core/error/exceptions.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  const ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<UserUpdateResponse> updateUser(UserUpdateRequest request) async {
    try {
      final response = await dio.post(
        "${Constants.authUrl}${Urls.UPDATE_USER}",
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserUpdateResponse.fromJson(response.data);
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioError catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<FaqResponse> getFAQ() async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}${Urls.FAQ}",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return FaqResponse.fromJson(response.data['data']);
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioError catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<String> uploadImage(Uint8List file) async {
    try {
      final response = await dio.post(
        "${Constants.baseUrl}${Urls.UPLOADIMAGE}",
        data: FormData.fromMap(
          {
            "file": MultipartFile.fromBytes(
              file,
              filename: "avatar.jpg",
            ),
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data']['filename'];
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioError catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }

  @override
  Future<None> deleteUser(String userId) async {
    try {
      final response = await dio.delete(
        "${Constants.authUrl}${Urls.USERINFO}/$userId",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const None();
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioError catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }
}
