import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/search/domain/entities/search_restaurants_entity.dart';
import 'package:my_flutter_template/features/search/domain/repository/search_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/usecase/usecase.dart';

class GetSearchRestaurants
    implements UseCase<SearchRestaurantsEntity, SearchRestaurantsParams> {
  final SearchRepository repository;

  GetSearchRestaurants(this.repository);

  @override
  Future<Either<Failure, SearchRestaurantsEntity>> call(
      SearchRestaurantsParams params) async {
    return await repository.getSearchRestaurants(
      query: params.query,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchRestaurantsParams {
  final String? query;
  final int? limit;
  final int? offset;

  SearchRestaurantsParams({this.query, this.limit, this.offset});
}
