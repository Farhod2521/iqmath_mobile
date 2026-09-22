/// banners : [{"id":"096667c5-1470-427f-b846-ad1d6cfd9644","title":"string","branch_id":"string","created_at":"Wed Aug 16 2023 15:10:32 GMT+0000 (Coordinated Universal Time)","is_active":true,"product_id":"string","image_url":"asd","product_title":"","branch_title":""},{"id":"3b6efa2e-530f-4862-84f7-325cc7cebd65","title":"Some New Title","branch_id":"8397e855-130f-11ee-8937-02420a000040","created_at":"Wed Aug 16 2023 16:41:22 GMT+0000 (Coordinated Universal Time)","is_active":true,"product_id":"","image_url":"https://cdn.restapp.uz/images/651672fe-39dc-48c0-a62d-592c6b228bdc.jpg","product_title":"","branch_title":"Caravan"}]
/// count : 2

class BannersResponse {
  BannersResponse({
      this.banners, 
      this.count,});

  BannersResponse.fromJson(dynamic json) {
    if (json['banners'] != null) {
      banners = [];
      json['banners'].forEach((v) {
        banners?.add(Banners.fromJson(v));
      });
    }
    count = json['count'];
  }
  List<Banners>? banners;
  num? count;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (banners != null) {
      map['banners'] = banners?.map((v) => v.toJson()).toList();
    }
    map['count'] = count;
    return map;
  }

}

/// id : "096667c5-1470-427f-b846-ad1d6cfd9644"
/// title : "string"
/// branch_id : "string"
/// created_at : "Wed Aug 16 2023 15:10:32 GMT+0000 (Coordinated Universal Time)"
/// is_active : true
/// product_id : "string"
/// image_url : "asd"
/// product_title : ""
/// branch_title : ""

class Banners {
  Banners({
      this.id, 
      this.title, 
      this.branchId, 
      this.createdAt, 
      this.isActive, 
      this.productId, 
      this.imageUrl, 
      this.productTitle, 
      this.branchTitle,});

  Banners.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    branchId = json['branch_id'];
    createdAt = json['created_at'];
    isActive = json['is_active'];
    productId = json['product_id'];
    imageUrl = json['image_url'];
    productTitle = json['product_title'];
    branchTitle = json['branch_title'];
  }
  String? id;
  String? title;
  String? branchId;
  String? createdAt;
  bool? isActive;
  String? productId;
  String? imageUrl;
  String? productTitle;
  String? branchTitle;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['branch_id'] = branchId;
    map['created_at'] = createdAt;
    map['is_active'] = isActive;
    map['product_id'] = productId;
    map['image_url'] = imageUrl;
    map['product_title'] = productTitle;
    map['branch_title'] = branchTitle;
    return map;
  }

}