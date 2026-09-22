import 'package:my_flutter_template/features/home/data/models/get_all_categories_response.dart';
import 'package:equatable/equatable.dart';

class GetAllCategoriesEntity {
  List<CategorySubEntity>? categories;
  int? count;

  GetAllCategoriesEntity({
    this.categories,
    this.count,
  });
}

class CategorySubEntity extends Equatable {
  String? id;
  String? menuId;
  bool? active;
  String? title;

  CategorySubEntity({
    this.id,
    this.menuId,
    this.active,
    this.title,
  });

  @override
  List<Object?> get props => [id, menuId, active, title];
}

extension GetAllCategoriesEntityExtension on GetAllCategoriesResponse {
  GetAllCategoriesEntity get toEntity {
    return GetAllCategoriesEntity(
      categories: categories
          ?.map(
            (category) => CategorySubEntity(
              menuId: category.menuId,
              id: category.id,
              active: category.active,
              title: category.title,
            ),
          )
          .toList(),
      count: count?.toInt(),
    );
  }
}
