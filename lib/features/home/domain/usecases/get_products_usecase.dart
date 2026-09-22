import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/home/data/models/product_response.dart';
import 'package:my_flutter_template/features/home/domain/repository/home_repository.dart';

class GetProductsUseCase extends UseCase<ProductResponse, Params> {
  final HomeRepository homeRepository;

  GetProductsUseCase(this.homeRepository);

  @override
  Future<Either<Failure, ProductResponse>> call(Params params) async {
    return await homeRepository.getProducts(
      params.limit,
      params.skip,
      params.isCache,
    );
  }
}

class Params {
  final int limit;
  final int skip;

  final bool isCache;

  Params(this.limit, this.skip, {this.isCache = false});
}
