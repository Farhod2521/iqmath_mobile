import 'dart:async';

import 'package:my_flutter_template/constants/constants.dart';
import 'package:my_flutter_template/core/error/exceptions.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/home/data/models/banners_response.dart';
import 'package:my_flutter_template/features/home/data/models/get_all_branches_response.dart';
import 'package:my_flutter_template/features/home/data/models/get_all_categories_response.dart';
import 'package:my_flutter_template/features/home/data/models/get_liked_restaurants_request.dart';
import 'package:my_flutter_template/features/home/data/models/get_menu_products_response.dart';
import 'package:my_flutter_template/features/home/data/models/get_single_branch_response.dart';
import 'package:my_flutter_template/features/home/data/models/like_restaurant_request.dart';
import 'package:my_flutter_template/features/home/data/models/menu_products.dart';
import 'package:my_flutter_template/features/home/data/models/product_response.dart';
import 'package:my_flutter_template/features/home/data/models/want_restaurant_request.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/platform/network_info.dart';
import '../../../../../injector_container.dart';
import '../../models/search_products_response.dart';
import 'home_remote_data_source.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;
  final NetworkInfo networkInfo;

  HomeRemoteDataSourceImpl({required this.dio, required this.networkInfo});

  @override
  Future<ProductResponse> getProduct(num? limit, num? skip) async {
    try {
      final response = await dio.get(
        "${Constants.baseUrl}${Urls.PRODUCTS}",
        queryParameters: limit != null && skip != null
            ? {
                "limit": limit,
                "skip": skip,
              }
            : null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return compute(
          (message) => Future.value(ProductResponse.fromJson(message)),
          response.data,
        );
      } else {
        throw ServerException.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw ServerException.fromJson(e.response?.data);
    }
  }
}
