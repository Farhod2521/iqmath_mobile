import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/auth/domain/entities/register_request_entity.dart';
import 'package:my_flutter_template/features/auth/domain/entities/register_response_entity.dart';
import 'package:my_flutter_template/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/usecase/usecase.dart';

class RegisterUseCase extends UseCase<RegisterResponseEntity, RegisterParams> {
  final AuthRepository authRepository;

  RegisterUseCase(this.authRepository);

  @override
  Future<Either<Failure, RegisterResponseEntity>> call(
      RegisterParams params) async {
    return await authRepository.register(params.registerRequestEntity);
  }
}

class RegisterParams {
  final RegisterRequestEntity registerRequestEntity;

  RegisterParams(this.registerRequestEntity);
}
