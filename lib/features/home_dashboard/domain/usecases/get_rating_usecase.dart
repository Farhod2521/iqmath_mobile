import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/rating_model.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/repository/home_dashboard_repository.dart';

class GetRatingUseCase implements UseCase<RatingResponseModel, NoParams> {
  final HomeDashboardRepository repository;

  GetRatingUseCase(this.repository);

  @override
  Future<Either<Failure, RatingResponseModel>> call(NoParams params) {
    return repository.getRating();
  }
}
