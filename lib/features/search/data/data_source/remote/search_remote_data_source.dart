import '../../models/search_restaurants_response.dart';

abstract class SearchRemoteDataSource {
  Future<SearchRestaurantsResponse> getSearchRestaurants({String? query, int? limit, int? offset});
}