import 'package:my_flutter_template/features/home/data/models/get_menu_products_response.dart';
import 'package:equatable/equatable.dart';

import 'menu_products.dart';

class GetMenuProductsEntity extends MenuProductsEntity {
  final List<ProductSubEntity>? products;
  final int? count;

  GetMenuProductsEntity(this.products, this.count);

  @override
  List<Object?> get props => [products, count];
}

class ProductSubEntity extends Equatable {
  final bool? active;
  final String? categoryId;
  final String? description;
  final List<String>? gallery;
  final String? id;
  final String? image;
  final String? menuId;
  final num? price;
  final String? shortDescription;
  final String? title;
  final num? weight;

  const ProductSubEntity({
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

  @override
  List<Object?> get props => [
        active,
        categoryId,
        description,
        gallery,
        id,
        image,
        menuId,
        price,
        shortDescription,
        title,
        weight,
      ];
}

extension MenuProductsX on GetMenuProductsResponse {
  GetMenuProductsEntity get toEntity {
    return GetMenuProductsEntity(
      products
          ?.map(
            (product) => ProductSubEntity(
              menuId: product.menuId,
              title: product.title,
              description: product.description,
              shortDescription: product.shortDescription,
              price: product.price,
              weight: product.weight,
              image: product.image,
              gallery: product.gallery,
              categoryId: product.categoryId,
              active: product.active,
              id: product.id,
            ),
          )
          .toList(),
      count?.toInt(),
    );
  }
}
