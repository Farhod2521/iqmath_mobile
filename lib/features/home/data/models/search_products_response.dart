import 'package:my_flutter_template/features/home/data/models/menu_products.dart';

/// products : [{"id":"cf768de7-81e8-4f8c-b04d-bd3318eac007","title":"Каре ягненка ","image":"https://cdn.restapp.uz/images/3b6c6c81-2dff-4b75-b244-59b7ec3d3835.jpg","gallery":["https://cdn.restapp.uz/images/c82ba305-9c94-41c9-b606-55b3288371cd.jpeg"],"short_description":"Каре ягненка - это изысканное и ароматное мясо, которое придает особый шарм любому столу и удовлетворяет самых требовательных гурманов.","description":"Мясо каре ягненка обладает нежной текстурой и слегка сладковатым вкусом. Оно обычно приготавливается путем жарки, запекания или гриля, чтобы сохранить его сочность и придать нежный розовый оттенок. Каре ягненка часто подают с различными соусами, специями или гарнирами, чтобы дополнить его вкус.","weight":170,"price":165000,"category_id":"c4a0a736-0e8e-4bb6-b723-471d55e79ea2","menu_id":"fd7ed1d1-2493-45c7-b78a-c4435949538e","active":false,"category":{"id":"c4a0a736-0e8e-4bb6-b723-471d55e79ea2","title":"Вторые блюда","menu_id":"fd7ed1d1-2493-45c7-b78a-c4435949538e","active":true,"created_at":"Sun Jun 25 2023 04:23:31 GMT+0000 (Coordinated Universal Time)"}}]
/// count : 2

class SearchProductsResponse extends MenuProducts {
  SearchProductsResponse({
    this.products,
    this.count,
  });

  SearchProductsResponse.fromJson(dynamic json) {
    if (json['products'] != null) {
      products = [];
      json['products'].forEach((v) {
        products?.add(Products.fromJson(v));
      });
    }
    count = json['count'];
  }

  List<Products>? products;
  num? count;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (products != null) {
      map['products'] = products?.map((v) => v.toJson()).toList();
    }
    map['count'] = count;
    return map;
  }
}

/// id : "cf768de7-81e8-4f8c-b04d-bd3318eac007"
/// title : "Каре ягненка "
/// image : "https://cdn.restapp.uz/images/3b6c6c81-2dff-4b75-b244-59b7ec3d3835.jpg"
/// gallery : ["https://cdn.restapp.uz/images/c82ba305-9c94-41c9-b606-55b3288371cd.jpeg"]
/// short_description : "Каре ягненка - это изысканное и ароматное мясо, которое придает особый шарм любому столу и удовлетворяет самых требовательных гурманов."
/// description : "Мясо каре ягненка обладает нежной текстурой и слегка сладковатым вкусом. Оно обычно приготавливается путем жарки, запекания или гриля, чтобы сохранить его сочность и придать нежный розовый оттенок. Каре ягненка часто подают с различными соусами, специями или гарнирами, чтобы дополнить его вкус."
/// weight : 170
/// price : 165000
/// category_id : "c4a0a736-0e8e-4bb6-b723-471d55e79ea2"
/// menu_id : "fd7ed1d1-2493-45c7-b78a-c4435949538e"
/// active : false
/// category : {"id":"c4a0a736-0e8e-4bb6-b723-471d55e79ea2","title":"Вторые блюда","menu_id":"fd7ed1d1-2493-45c7-b78a-c4435949538e","active":true,"created_at":"Sun Jun 25 2023 04:23:31 GMT+0000 (Coordinated Universal Time)"}

class Products {
  Products({
    this.id,
    this.title,
    this.image,
    this.gallery,
    this.shortDescription,
    this.description,
    this.weight,
    this.price,
    this.categoryId,
    this.menuId,
    this.active,
    this.category,
  });

  Products.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    gallery = json['gallery'] != null ? json['gallery'].cast<String>() : [];
    shortDescription = json['short_description'];
    description = json['description'];
    weight = json['weight'];
    price = json['price'];
    categoryId = json['category_id'];
    menuId = json['menu_id'];
    active = json['active'];
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  String? id;
  String? title;
  String? image;
  List<String>? gallery;
  String? shortDescription;
  String? description;
  num? weight;
  num? price;
  String? categoryId;
  String? menuId;
  bool? active;
  Category? category;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['image'] = image;
    map['gallery'] = gallery;
    map['short_description'] = shortDescription;
    map['description'] = description;
    map['weight'] = weight;
    map['price'] = price;
    map['category_id'] = categoryId;
    map['menu_id'] = menuId;
    map['active'] = active;
    if (category != null) {
      map['category'] = category?.toJson();
    }
    return map;
  }
}

/// id : "c4a0a736-0e8e-4bb6-b723-471d55e79ea2"
/// title : "Вторые блюда"
/// menu_id : "fd7ed1d1-2493-45c7-b78a-c4435949538e"
/// active : true
/// created_at : "Sun Jun 25 2023 04:23:31 GMT+0000 (Coordinated Universal Time)"

class Category {
  Category({
    this.id,
    this.title,
    this.menuId,
    this.active,
    this.createdAt,
  });

  Category.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    menuId = json['menu_id'];
    active = json['active'];
    createdAt = json['created_at'];
  }

  String? id;
  String? title;
  String? menuId;
  bool? active;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['menu_id'] = menuId;
    map['active'] = active;
    map['created_at'] = createdAt;
    return map;
  }
}
