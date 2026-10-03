import 'dart:developer';

import 'package:my_flutter_template/constants/constants.dart';
import 'package:my_flutter_template/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:my_flutter_template/features/auth/data/models/confirm_request_model.dart';
import 'package:my_flutter_template/features/auth/data/models/confirm_response_model.dart';
import 'package:my_flutter_template/features/auth/data/models/login_request_model.dart';
import 'package:my_flutter_template/features/auth/data/models/login_response_model.dart';
import 'package:my_flutter_template/features/auth/data/models/register_request_model.dart';
import 'package:my_flutter_template/features/auth/data/models/register_response_model.dart';
import 'package:dio/dio.dart';

import '../../../../../core/device/device_identity.dart';
import '../../../../../core/device/device_model.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/local_source/local_source.dart';
import '../../../../../injector_container.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  var requestOptions = Options(
    contentType: 'application/json',
    sendTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );

  @override
  Future<ConfirmResponseModel> confirm(
      ConfirmRequestModel confirmRequestModel, bool reset) async {
    try {
      final response = await dio.post(
        "${Constants.authUrl}${reset ? Urls.RESET : Urls.CONFIRM}",
        options: requestOptions,
        data: {
          ...confirmRequestModel.toJson(),
          ...DeviceIdentity.credentials(sl<LocalSource>()),
        },
      );
      if ((response.statusCode ?? 500) >= 200 &&
          (response.statusCode ?? 500) < 300) {
        log("Data: ${response.data['data']}");
        return ConfirmResponseModel.fromJson(response.data);
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioError catch (e) {
      if (e.response == null) {
        throw NoInternetException();
      }
      throw ServerException.fromJson(e.response?.data);
    } catch (e) {
      throw ServerException(message: e.toString(), title: 'Error');
    }
  }

  @override
  Future<LoginResponseModel> login(LoginRequestModel loginRequestModel) async {
    try {
      final response = await dio.post(
        "${Constants.authUrl}${Urls.LOGIN}",
        options: requestOptions,
        data: {
          ...loginRequestModel.toJson(),
          ...DeviceIdentity.credentials(sl<LocalSource>()),
        },
      );
      if ((response.statusCode ?? 500) >= 200 &&
          (response.statusCode ?? 500) < 300) {
        return LoginResponseModel.fromJson(response.data);
      } else if ((response.statusCode ?? 500) == 404) {
        return LoginResponseModel();
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return LoginResponseModel();
      }
      // 2 ta qurilma chegarasi — foydalanuvchi qurilmalardan birini tanlaydi
      if (e.response?.statusCode == 409 &&
          DeviceLimitInfo.matches(e.response?.data)) {
        throw DeviceLimitException(DeviceLimitInfo.fromJson(
            Map<String, dynamic>.from(e.response!.data as Map)));
      }
      if (e.response == null) {
        throw NoInternetException();
      }
      throw ServerException.fromJson(e.response?.data);
    } catch (e) {
      throw ServerException(message: e.toString(), title: 'Error');
    }
  }

  @override
  Future<RegisterResponseModel> register(
      RegisterRequestModel registerRequestModel) async {
    try {
      final response = await dio.post(
        "${Constants.authUrl}${Urls.REGISTER}",
        options: requestOptions,
        data: registerRequestModel.toJson(),
      );
      if ((response.statusCode ?? 500) >= 200 &&
          (response.statusCode ?? 500) < 300) {
        return RegisterResponseModel.fromJson(response.data);
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioError catch (e) {
      if (e.response == null) {
        throw NoInternetException();
      }
      if (e.response?.statusCode == 500) {
        throw ServerException(
            message:
                'Something went wrong  ${e.response?.statusCode} statusCode',
            title: 'Server Error');
      } else {
        throw ServerException.fromJson(e.response?.data);
      }
    } catch (e) {
      throw ServerException(message: e.toString(), title: 'Error');
    }
  }
}
