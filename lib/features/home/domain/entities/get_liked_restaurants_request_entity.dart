import 'package:my_flutter_template/features/home/data/models/get_liked_restaurants_request.dart';
import 'package:equatable/equatable.dart';

class GetLikedRestaurantsRequestEntity extends Equatable {
  const GetLikedRestaurantsRequestEntity({
    this.limit,
    this.offset,
    this.search,
    this.userId,
  });

  final num? limit;
  final num? offset;
  final String? search;
  final String? userId;

  @override
  List<Object?> get props => [
        limit,
        offset,
        search,
        userId,
      ];
}

extension GetLikedRestaurantsRequestEntityX
    on GetLikedRestaurantsRequestEntity {
  GetLikedRestaurantsRequest get toModel {
    return GetLikedRestaurantsRequest(
      limit: limit,
      offset: offset,
      search: search,
      userId: userId,
    );
  }
}
