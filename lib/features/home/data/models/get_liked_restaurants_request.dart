/// limit : 0
/// offset : 0
/// search : "string"
/// user_id : "string"

class GetLikedRestaurantsRequest {
  GetLikedRestaurantsRequest({
    this.limit,
    this.offset,
    this.search,
    this.userId,
  });

  GetLikedRestaurantsRequest.fromJson(dynamic json) {
    limit = json['limit'];
    offset = json['offset'];
    search = json['search'];
    userId = json['user_id'];
  }

  num? limit;
  num? offset;
  String? search;
  String? userId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (limit != null) {
      map['limit'] = limit;
    }
    if (offset != null) {
      map['offset'] = offset;
    }
    if (search != null) {
      map['search'] = search;
    }
    if (userId != null) {
      map['user_id'] = userId;
    }
    return map;
  }
}
