import 'package:my_flutter_template/features/home/data/models/menu_products.dart';

/// count : 0
/// products : [{"active":true,"category_id":"string","description":"string","gallery":["string"],"id":"string","image":"string","menu_id":"string","price":0,"short_description":"string","title":"string","weight":0}]

class GetMenuProductsResponse extends MenuProducts {
  GetMenuProductsResponse({
    this.count,
    this.products,
  });

  GetMenuProductsResponse.fromJson(dynamic json) {
    count = json['count'];
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products?.add(Products.fromJson(v));
      });
    }
  }

  num? count;
  List<Products>? products;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['count'] = count;
    if (products != null) {
      map['products'] = products?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// active : true
/// category_id : "string"
/// description : "string"
/// gallery : ["string"]
/// id : "string"
/// image : "string"
/// menu_id : "string"
/// price : 0
/// short_description : "string"
/// title : "string"
/// weight : 0

class Products {
  Products({
    this.active,
    this.categoryId,
    this.description,
    this.gallery,
    this.id,
    this.image,
    this.menuId,
    this.price,
    this.shortDescription,
    this.title,
    this.weight,
  });

  Products.fromJson(dynamic json) {
    active = json['active'];
    categoryId = json['category_id'];
    description = json['description'];
    gallery = json['gallery'] != null ? json['gallery'].cast<String>() : [];
    id = json['id'];
    image = json['image'];
    menuId = json['menu_id'];
    price = json['price'];
    shortDescription = json['short_description'];
    title = json['title'];
    weight = json['weight'];
  }

  bool? active;
  String? categoryId;
  String? description;
  List<String>? gallery;
  String? id;
  String? image;
  String? menuId;
  num? price;
  String? shortDescription;
  String? title;
  num? weight;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['active'] = active;
    map['category_id'] = categoryId;
    map['description'] = description;
    map['gallery'] = gallery;
    map['id'] = id;
    map['image'] = image;
    map['menu_id'] = menuId;
    map['price'] = price;
    map['short_description'] = shortDescription;
    map['title'] = title;
    map['weight'] = weight;
    return map;
  }
}
