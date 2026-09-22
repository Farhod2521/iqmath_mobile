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
import 'package:my_flutter_template/features/subject/data/models/subject_response.dart';

import '../../domain/repository/subject_repository.dart';
import '../data_source/remote/subject_remote_data_source.dart';

class SubjectRepositoryImpl extends SubjectRepository {
  final SubjectRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SubjectRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SubjectResponse>>> getSubjects() async {
    try {
      final response = await remoteDataSource.getSubjects();
      return Right(response);
    } catch (e) {
      return Left(
        ServerFailure(
          message: (e is ServerException) ? e.message : 'Something went wrong!',
          title: (e is ServerException) ? e.title : 'Error',
        ),
      );
    }
  }
}
