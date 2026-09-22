import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/student_score_model.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/repository/home_dashboard_repository.dart';

class GetMyScoreUseCase implements UseCase<StudentScoreModel, NoParams> {
  final HomeDashboardRepository repository;

  GetMyScoreUseCase(this.repository);

  @override
  Future<Either<Failure, StudentScoreModel>> call(NoParams params) {
    return repository.getMyScore();
  }
}
