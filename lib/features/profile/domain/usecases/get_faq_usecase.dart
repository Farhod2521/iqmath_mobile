import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/profile/domain/entities/faq_response_entity.dart';
import 'package:my_flutter_template/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetFaqUseCase extends UseCase<FaqResponseEntity, NoParams> {
  final ProfileRepository repository;

  GetFaqUseCase(this.repository);

  @override
  Future<Either<Failure, FaqResponseEntity>> call(NoParams params) async {
    return await repository.getFaq();
  }
}
