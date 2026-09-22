import 'package:my_flutter_template/features/home/data/models/banners_response.dart';
import 'package:my_flutter_template/features/home/data/models/get_all_branches_response.dart';
import 'package:my_flutter_template/features/home/data/models/get_liked_restaurants_request.dart';
import 'package:my_flutter_template/features/home/data/models/get_single_branch_response.dart';
import 'package:my_flutter_template/features/home/data/models/menu_products.dart';
import 'package:my_flutter_template/features/home/data/models/product_response.dart';
import 'package:my_flutter_template/features/home/data/models/want_restaurant_request.dart';
import 'package:dartz/dartz.dart';

import '../../models/get_all_categories_response.dart';
import '../../models/like_restaurant_request.dart';

abstract class HomeRemoteDataSource {

  Future<ProductResponse> getProduct(
    num? limit,
    num? skip,
  );
}
