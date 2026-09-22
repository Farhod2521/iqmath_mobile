import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/study_stats_model.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/repository/home_dashboard_repository.dart';

class GetStudyStatsUseCase
    implements UseCase<StudyStatsResponseModel, GetStudyStatsParams> {
  final HomeDashboardRepository repository;

  GetStudyStatsUseCase(this.repository);

  @override
  Future<Either<Failure, StudyStatsResponseModel>> call(
      GetStudyStatsParams params) {
    return repository.getStudyStatsByDate(
      dateFrom: params.dateFrom,
      dateTo: params.dateTo,
      pageSize: params.pageSize,
    );
  }
}

class GetStudyStatsParams {
  final String dateFrom;
  final String dateTo;
  final int pageSize;

  GetStudyStatsParams({
    required this.dateFrom,
    required this.dateTo,
    required this.pageSize,
  });
}
