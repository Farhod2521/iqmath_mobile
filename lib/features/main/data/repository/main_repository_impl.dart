import 'package:my_flutter_template/core/error/failure.dart';

import 'package:my_flutter_template/features/main/domain/entities/user_response_entity.dart';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repository/main_repository.dart';
import '../data_source/remote/main_remote_data_source.dart';

class MainRepositoryImpl implements MainRepository {
  final MainRemoteDataSource remoteDataSource;

  MainRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserResponseEntity>> getUserInfo() async {
    try {
      final response = await remoteDataSource.getUserInfo();
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
}
