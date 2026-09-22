import 'package:my_flutter_template/features/main/data/data_source/remote/main_remote_data_source.dart';
import 'package:my_flutter_template/features/main/data/models/user_response.dart';
import 'package:dio/dio.dart';

import '../../../../../constants/constants.dart';
import '../../../../../core/error/exceptions.dart';

class MainRemoteDataSourceImpl implements MainRemoteDataSource {
  final Dio dio;

  MainRemoteDataSourceImpl(this.dio);

  @override
  Future<UserResponse> getUserInfo() async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}${Urls.USERINFO}",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserResponse.fromJson(response.data);
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioError catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }
}
