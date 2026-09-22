/// branch_id : "string"
/// user_id : "string"

class WantRestaurantRequest {
  WantRestaurantRequest({
      this.branchId, 
      this.userId,});

  WantRestaurantRequest.fromJson(dynamic json) {
    branchId = json['branch_id'];
    userId = json['user_id'];
  }
  String? branchId;
  String? userId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['branch_id'] = branchId;
    map['user_id'] = userId;
    return map;
  }

}