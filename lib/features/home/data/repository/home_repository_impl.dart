import 'package:my_flutter_template/core/error/exceptions.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/platform/network_info.dart';
import 'package:my_flutter_template/features/home/data/data_source/local/home_local_data_source.dart';
import 'package:my_flutter_template/features/home/data/models/get_menu_products_response.dart';
import 'package:my_flutter_template/features/home/data/models/product_response.dart';
import 'package:my_flutter_template/features/home/data/models/search_products_response.dart';
import 'package:my_flutter_template/features/home/domain/entities/banners_response_entity.dart';

import 'package:my_flutter_template/features/home/domain/entities/get_all_branches_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/get_all_categories_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/get_liked_restaurants_request_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/get_menu_products_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/get_single_branch_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/like_restaurant_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/menu_products.dart';
import 'package:my_flutter_template/features/home/domain/entities/search_products_response_entity.dart';
import 'package:my_flutter_template/features/home/domain/entities/want_restaurant_request_entity.dart';

import 'package:dartz/dartz.dart';

import '../../domain/repository/home_repository.dart';
import '../data_source/remote/home_remote_data_source.dart';

class HomeRepositoryImpl extends HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource homeLocalDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.homeLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProductResponse>> getProducts(
      num? limit, num? skip, bool isCache) async {
    if (!isCache) {
      try {
        final response = await remoteDataSource.getProduct(limit, skip);
        homeLocalDataSource.setProductList(response, skip ?? 0);
        return Right(response.toEntity());
      } catch (e) {
        return Left(
          ServerFailure(
            message:
                (e is ServerException) ? e.message : 'Something went wrong!',
            title: (e is ServerException) ? e.title : 'Error',
          ),
        );
      }
    } else {
      try {
        final response = await homeLocalDataSource.getProductList(skip ?? 0);
        return Right(response.toEntity());
      } catch (e) {
        return Left(
          CacheFailure(
            message:
                (e is CacheException) ? e.message : 'Something went wrong!',
            title: (e is CacheException) ? e.title : 'Error',
          ),
        );
      }
    }
  }
}
