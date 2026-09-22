import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/search/domain/entities/search_restaurants_entity.dart';
import 'package:my_flutter_template/features/search/domain/repository/search_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../data_source/remote/search_remote_data_source.dart';

class SearchRepositoryImpl extends SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, SearchRestaurantsEntity>> getSearchRestaurants(
      {String? query, int? limit, int? offset}) async {
    try {
      final response = await remoteDataSource.getSearchRestaurants(
        limit: limit,
        offset: offset,
        query: query,
      );
      return Right(response.toEntity());
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
