import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/home/data/models/product_response.dart';
import 'package:my_flutter_template/features/home/domain/entities/banners_response_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/get_all_branches_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/get_all_categories_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/get_liked_restaurants_request_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/get_single_branch_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/like_restaurant_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/menu_products.dart';
import 'package:dartz/dartz.dart';

import '../entities/want_restaurant_request_entity.dart';

abstract class HomeRepository {

  Future<Either<Failure, ProductResponse>> getProducts(
    int? limit,
    int? skip,
    bool isCache,
  );
}
