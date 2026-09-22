/// branch_id : "string"
/// user_id : "string"

class LikeRestaurantRequest {
  LikeRestaurantRequest({
    required this.isLiked,
    this.branchId,
    this.userId,
  });

  String? branchId;
  String? userId;
  bool isLiked;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['branch_id'] = branchId;
    map['user_id'] = userId;
    return map;
  }
}
