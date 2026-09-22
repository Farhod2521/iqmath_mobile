import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/confirm_request_entity.dart';
import '../entities/confirm_response_entity.dart';
import '../repository/auth_repository.dart';

class ConfirmUseCase extends UseCase<ConfirmResponseEntity, ConfirmParams> {
  final AuthRepository authRepository;

  ConfirmUseCase(this.authRepository);

  @override
  Future<Either<Failure, ConfirmResponseEntity>> call(
      ConfirmParams params) async {
    return await authRepository.confirm(
      params.confirmRequestEntity,
      params.reset,
    );
  }
}

class ConfirmParams {
  final ConfirmRequestEntity confirmRequestEntity;
  final bool reset;

  ConfirmParams(
    this.confirmRequestEntity,
    this.reset,
  );
}
