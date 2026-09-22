/// branches : [{"description":"string","facebook_link":"string","id":"string","instagram_link":"string","lat":0,"long":0,"name":"string","organization_id":"string","phone_number":"string","photos":["string"],"telegram_link":"string"}]
/// count : 0

class GetAllBranchesResponse {
  GetAllBranchesResponse({
    this.branches,
    this.count,
  });

  GetAllBranchesResponse.fromJson(dynamic json) {
    if (json['branches'] != null) {
      branches = [];
      json['branches'].forEach((v) {
        branches?.add(Branches.fromJson(v));
      });
    }
    count = json['count'];
  }

  List<Branches>? branches;
  num? count;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (branches != null) {
      map['branches'] = branches?.map((v) => v.toJson()).toList();
    }
    map['count'] = count;
    return map;
  }
}

/// description : "string"
/// facebook_link : "string"
/// id : "string"
/// instagram_link : "string"
/// lat : 0
/// long : 0
/// name : "string"
/// organization_id : "string"
/// phone_number : "string"
/// photos : ["string"]
/// telegram_link : "string"
/// shift_from : "string"
/// shift_to : "string"
/// menu_id : "string"
/// "rate": 0,
/// "rate_count": 0,
/// address : "string"
/// "is_favourite": false

class Branches {
  Branches({
    this.description,
    this.facebookLink,
    this.id,
    this.instagramLink,
    this.lat,
    this.long,
    this.name,
    this.organizationId,
    this.phoneNumber,
    this.photos,
    this.telegramLink,
    this.shiftFrom,
    this.shiftTo,
    this.menuId,
    this.rate,
    this.rateCount,
    this.address,
    this.isFavourite,
    this.isLinked,
    this.avgPrice,
  });

  Branches.fromJson(dynamic json) {
    description = json['description'];
    facebookLink = json['facebook_link'];
    id = json['id'];
    instagramLink = json['instagram_link'];
    lat = json['lat'];
    long = json['long'];
    name = json['name'];
    organizationId = json['organization_id'];
    phoneNumber =
        json['phone_number'] != null ? json['phone_number'].cast<String>() : [];
    photos = json['photos'] != null ? json['photos'].cast<String>() : [];
    telegramLink = json['telegram_link'];
    shiftFrom = json['shift_from'];
    shiftTo = json['shift_to'];
    menuId = json['menu_id'];
    rate = json['rate'];
    rateCount = json['rate_count'];
    address = json['address'];
    isFavourite = json['is_favourite'];
    isLinked = json['is_linked'];
    avgPrice = json['avg_price'];
  }

  String? description;
  String? facebookLink;
  String? id;
  String? instagramLink;
  num? lat;
  num? long;
  String? name;
  String? organizationId;
  List<String>? phoneNumber;
  List<String>? photos;
  String? telegramLink;
  String? shiftFrom;
  String? shiftTo;
  String? menuId;
  num? rate;
  num? rateCount;
  String? address;
  bool? isFavourite;
  bool? isLinked;
  num? avgPrice;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['description'] = description;
    map['facebook_link'] = facebookLink;
    map['id'] = id;
    map['instagram_link'] = instagramLink;
    map['lat'] = lat;
    map['long'] = long;
    map['name'] = name;
    map['organization_id'] = organizationId;
    map['phone_number'] = phoneNumber;
    map['photos'] = photos;
    map['telegram_link'] = telegramLink;
    map['shift_from'] = shiftFrom;
    map['shift_to'] = shiftTo;
    map['menu_id'] = menuId;
    map['rate'] = rate;
    map['rate_count'] = rateCount;
    map['address'] = address;
    map['is_favourite'] = isFavourite;
    map['is_linked'] = isLinked;
    map['avg_price'] = avgPrice;
    return map;
  }
}
