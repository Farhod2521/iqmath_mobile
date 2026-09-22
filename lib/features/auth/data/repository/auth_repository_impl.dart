import 'dart:developer';

import 'package:my_flutter_template/core/error/exceptions.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/platform/network_info.dart';
import 'package:my_flutter_template/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:my_flutter_template/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:my_flutter_template/features/auth/domain/entities/confirm_request_entity.dart';
import 'package:my_flutter_template/features/auth/domain/entities/confirm_response_entity.dart';
import 'package:my_flutter_template/features/auth/domain/entities/login_request_entity.dart';
import 'package:my_flutter_template/features/auth/domain/entities/login_response_entity.dart';
import 'package:my_flutter_template/features/auth/domain/entities/register_request_entity.dart';
import 'package:my_flutter_template/features/auth/domain/entities/register_response_entity.dart';
import 'package:my_flutter_template/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ConfirmResponseEntity>> confirm(
    ConfirmRequestEntity confirmRequestEntity,
    bool reset,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NoInternetFailure());
    } else {
      try {
        final result = await authRemoteDataSource.confirm(
          confirmRequestEntity.toModel(),
          reset,
        );
        return Right(result.toEntity);
      } on ServerException catch (e) {
        return Left(
          ServerFailure(
            message: e.message,
            title: e.title,
          ),
        );
      } on NoInternetException {
        return Left(NoInternetFailure());
      } on CacheException catch (e) {
        return Left(
          CacheFailure(
            message: e.toString(),
            title: 'Cache Error',
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, LoginResponseEntity>> login(
      LoginRequestEntity loginRequestEntity) async {
    if (!await networkInfo.isConnected) {
      return Left(NoInternetFailure());
    } else {
      try {
        final result = await authRemoteDataSource.login(
          loginRequestEntity.toModel,
        );
        return Right(result.toEntity);
      } on ServerException catch (e) {
        return Left(
          ServerFailure(
            message: e.message,
            title: e.title,
          ),
        );
      } on NoInternetException {
        return Left(NoInternetFailure());
      } on CacheException catch (e) {
        return Left(
          CacheFailure(
            message: e.toString(),
            title: 'Cache Error',
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, RegisterResponseEntity>> register(
      RegisterRequestEntity registerRequestEntity) async {
    if (!await networkInfo.isConnected) {
      return Left(NoInternetFailure());
    } else {
      try {
        final result = await authRemoteDataSource.register(
          registerRequestEntity.toModel,
        );
        return Right(result.toEntity);
      } on ServerException catch (e) {
        return Left(
          ServerFailure(
            message: e.message,
            title: e.title,
          ),
        );
      } on NoInternetException {
        return Left(NoInternetFailure());
      } on CacheException catch (e) {
        return Left(
          CacheFailure(
            message: e.toString(),
            title: 'Cache Error',
          ),
        );
      }
    }
  }
}
