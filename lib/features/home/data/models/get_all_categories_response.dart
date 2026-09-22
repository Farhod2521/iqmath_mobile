/// categories : [{"active":true,"id":"string","menu_id":"string","title":"string"}]
/// count : 0

class GetAllCategoriesResponse {
  GetAllCategoriesResponse({
      this.categories, 
      this.count,});

  GetAllCategoriesResponse.fromJson(dynamic json) {
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach((v) {
        categories?.add(Categories.fromJson(v));
      });
    }
    count = json['count'];
  }
  List<Categories>? categories;
  num? count;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (categories != null) {
      map['categories'] = categories?.map((v) => v.toJson()).toList();
    }
    map['count'] = count;
    return map;
  }

}

/// active : true
/// id : "string"
/// menu_id : "string"
/// title : "string"

class Categories {
  Categories({
      this.active, 
      this.id, 
      this.menuId, 
      this.title,});

  Categories.fromJson(dynamic json) {
    active = json['active'];
    id = json['id'];
    menuId = json['menu_id'];
    title = json['title'];
  }
  bool? active;
  String? id;
  String? menuId;
  String? title;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['active'] = active;
    map['id'] = id;
    map['menu_id'] = menuId;
    map['title'] = title;
    return map;
  }

}