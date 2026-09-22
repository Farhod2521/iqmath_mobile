import 'package:my_flutter_template/features/search/domain/entities/search_restaurants_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

abstract class SearchRepository {
  Future<Either<Failure, SearchRestaurantsEntity>> getSearchRestaurants(
      {String? query, int? limit, int? offset});
}
