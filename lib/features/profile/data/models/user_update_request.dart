class UserUpdateRequest {
  UserUpdateRequest({
    this.fullName,
    this.email,
    this.address,
  });

  UserUpdateRequest.fromJson(dynamic json) {
    fullName = json['full_name'];
    email = json['email'];
    address = json['address'];
  }

  String? fullName;
  String? email;
  String? address;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['full_name'] = fullName;
    if (email != null) map['email'] = email;
    if (address != null) map['address'] = address;
    return map;
  }
}
