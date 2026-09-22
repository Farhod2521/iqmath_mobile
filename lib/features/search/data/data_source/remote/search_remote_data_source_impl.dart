import 'package:my_flutter_template/features/search/data/data_source/remote/search_remote_data_source.dart';
import 'package:my_flutter_template/features/search/data/models/search_restaurants_response.dart';
import 'package:dio/dio.dart';

import '../../../../../constants/constants.dart';
import '../../../../../core/error/exceptions.dart';

class SearchRemoteDataSourceImpl extends SearchRemoteDataSource {
  final Dio dio;

  SearchRemoteDataSourceImpl(this.dio);

  @override
  Future<SearchRestaurantsResponse> getSearchRestaurants(
      {String? query, int? limit, int? offset}) async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}${Urls.ALLBRANCHES}",
        queryParameters: limit != null && offset != null && query != null
            ? {
                "limit": limit,
                "offset": offset,
                "search": query,
              }
            : null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SearchRestaurantsResponse.fromJson(response.data["data"]);
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioError catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }
}
