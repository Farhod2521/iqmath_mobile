import 'package:my_flutter_template/features/home/domain/entities/menu_products.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/search_products_response.dart';

class SearchProductsResponseEntity extends MenuProductsEntity {
  SearchProductsResponseEntity({
    this.products,
    this.count,
  });

  final List<ProductsSubEntity>? products;
  final num? count;

  @override
  List<Object?> get props => [products, count];
}

class ProductsSubEntity extends Equatable {
  const ProductsSubEntity({
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

  final String? id;
  final String? title;
  final String? image;
  final List<String>? gallery;
  final String? shortDescription;
  final String? description;
  final num? weight;
  final num? price;
  final String? categoryId;
  final String? menuId;
  final bool? active;
  final CategorySubEntity? category;

  @override
  List<Object?> get props => [
        id,
        title,
        image,
        gallery,
        shortDescription,
        description,
        weight,
        price,
        categoryId,
        menuId,
        active,
        category,
      ];
}

class CategorySubEntity extends Equatable {
  const CategorySubEntity({
    this.id,
    this.title,
    this.menuId,
    this.active,
    this.createdAt,
  });

  final String? id;
  final String? title;
  final String? menuId;
  final bool? active;
  final String? createdAt;

  @override
  List<Object?> get props => [
        id,
        title,
        menuId,
        active,
        createdAt,
      ];
}

extension SearchProductsResponseX on SearchProductsResponse {
  SearchProductsResponseEntity get toEntity => SearchProductsResponseEntity(
        products: products
            ?.map(
              (e) => ProductsSubEntity(
                id: e.id,
                title: e.title,
                image: e.image,
                gallery: e.gallery,
                shortDescription: e.shortDescription,
                active: e.active,
                menuId: e.menuId,
                description: e.description,
                category: CategorySubEntity(
                  id: e.category?.id,
                  title: e.category?.title,
                  menuId: e.category?.menuId,
                  active: e.category?.active,
                  createdAt: e.category?.createdAt,
                ),
                categoryId: e.categoryId,
                price: e.price,
                weight: e.weight,
              ),
            )
            .toList(),
        count: count,
      );
}
