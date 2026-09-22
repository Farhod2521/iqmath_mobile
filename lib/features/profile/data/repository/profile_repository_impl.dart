import 'dart:typed_data';

import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'package:my_flutter_template/features/profile/data/models/user_update_response.dart';
import 'package:my_flutter_template/features/profile/domain/entities/faq_response_entity.dart';

import 'package:my_flutter_template/features/profile/domain/entities/user_update_request_entity.dart';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserUpdateResponse>> updateUser(
      UserUpdateRequestEntity request) async {
    try {
      final response = await remoteDataSource.updateUser(
        request.toModel,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, title: e.title),
      );
    } on CacheException catch (e) {
      return Left(
        CacheFailure(
          message: e.message,
          title: e.title,
        ),
      );
    } on NoInternetException catch (e) {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, FaqResponseEntity>> getFaq() async {
    try {
      final response = await remoteDataSource.getFAQ();
      return Right(response.toEntity);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, title: e.title),
      );
    } on CacheException catch (e) {
      return Left(
        CacheFailure(
          message: e.message,
          title: e.title,
        ),
      );
    } on NoInternetException catch (e) {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(Uint8List file) async {
    try {
      final response = await remoteDataSource.uploadImage(file);
      return Right(response);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, title: e.title),
      );
    } on CacheException catch (e) {
      return Left(
        CacheFailure(
          message: e.message,
          title: e.title,
        ),
      );
    } on NoInternetException catch (e) {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, None>> deleteUser(String userId) async {
    try {
      final response = await remoteDataSource.deleteUser(userId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, title: e.title),
      );
    } on CacheException catch (e) {
      return Left(
        CacheFailure(
          message: e.message,
          title: e.title,
        ),
      );
    } on NoInternetException catch (e) {
      return Left(NoInternetFailure());
    }
  }
}
