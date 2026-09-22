/// id : "a52283bb-e761-11ed-b638-02420a000030"
/// name : "Muhamamdaziz restaruant"
/// organization_id : "e56440aa-a806-4c8a-b2ae-420591039eff"
/// phone_number : "998994912830"
/// description : "new restaurant for clients"
/// long : 69.162122
/// lat : 41.263916
/// photos : ["https://cdn.restapp.uz/images/253cfb34-d652-44a7-b680-4f3e3332529a.png","https://cdn.restapp.uz/images/a73a9068-617e-411f-9425-2598aa8d20c2.jpeg"]
/// instagram_link : "https://www.instagram.com/muhammadaziz_789/saved/"
/// facebook_link : "https://www.facebook.com/muhammadaziz789"
/// telegram_link : "https://t.me/abdukarim_mirzayev_kanali"
/// shift_from : "10:00:00.000000"
/// shift_to : "16:00:00.000000"
/// menu_id : ""
/// Tags : null
/// user_bonus_amount : 0
/// "rate": 0,
/// "rate_count": 0,

class GetSingleBranchResponse {
  GetSingleBranchResponse({
    this.id,
    this.name,
    this.organizationId,
    this.phoneNumber,
    this.description,
    this.long,
    this.lat,
    this.photos,
    this.instagramLink,
    this.facebookLink,
    this.telegramLink,
    this.shiftFrom,
    this.shiftTo,
    this.menuId,
    this.tags,
    this.userBonusAmount,
    this.userBonusAmountTotal,
    this.isFavorite,
    this.isLinked,
    this.rate,
    this.rateCount,
    this.avgPrice,
  });

  GetSingleBranchResponse.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    organizationId = json['organization_id'];
    phoneNumber =
        json['phone_number'] != null ? json['phone_number'].cast<String>() : [];
    description = json['description'];
    long = json['long'];
    lat = json['lat'];
    photos = json['photos'] != null ? json['photos'].cast<String>() : [];
    instagramLink = json['instagram_link'];
    facebookLink = json['facebook_link'];
    telegramLink = json['telegram_link'];
    shiftFrom = json['shift_from'];
    shiftTo = json['shift_to'];
    menuId = json['menu_id'];
    tags = json['Tags'];
    userBonusAmount = json['user_bonus_amount'];
    userBonusAmountTotal = json['user_bonus_amount_total'];
    isFavorite = json['is_favourite'];
    isLinked = json['is_linked'];
    rate = json['rate'];
    rateCount = json['rate_count'];
    avgPrice = json['avg_price'];
  }

  String? id;
  String? name;
  String? organizationId;
  List<String>? phoneNumber;
  String? description;
  num? long;
  num? lat;
  List<String>? photos;
  String? instagramLink;
  String? facebookLink;
  String? telegramLink;
  String? shiftFrom;
  String? shiftTo;
  String? menuId;
  dynamic tags;
  num? userBonusAmount;
  num? userBonusAmountTotal;
  bool? isFavorite;
  bool? isLinked;
  num? rate;
  num? rateCount;
  num? avgPrice;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['organization_id'] = organizationId;
    map['phone_number'] = phoneNumber;
    map['description'] = description;
    map['long'] = long;
    map['lat'] = lat;
    map['photos'] = photos;
    map['instagram_link'] = instagramLink;
    map['facebook_link'] = facebookLink;
    map['telegram_link'] = telegramLink;
    map['shift_from'] = shiftFrom;
    map['shift_to'] = shiftTo;
    map['menu_id'] = menuId;
    map['Tags'] = tags;
    map['user_bonus_amount'] = userBonusAmount;
    map['user_bonus_amount_total'] = userBonusAmountTotal;
    map['is_favourite'] = isFavorite;
    map['is_linked'] = isLinked;
    map['rate'] = rate;
    map['rate_count'] = rateCount;
    map['avg_price'] = avgPrice;
    return map;
  }
}
