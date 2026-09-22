import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/home_dashboard_model.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/repository/home_dashboard_repository.dart';

class GetHomeDashboardUseCase
    implements UseCase<HomeDashboardModel, GetHomeDashboardParams> {
  final HomeDashboardRepository repository;

  GetHomeDashboardUseCase(this.repository);

  @override
  Future<Either<Failure, HomeDashboardModel>> call(
      GetHomeDashboardParams params) {
    return repository.getHomeDashboard(classId: params.classId);
  }
}

class GetHomeDashboardParams {
  final int? classId;

  GetHomeDashboardParams({this.classId});
}
