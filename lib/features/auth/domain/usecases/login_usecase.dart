import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/auth/domain/entities/login_request_entity.dart';
import 'package:my_flutter_template/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../entities/login_response_entity.dart';

class LoginUseCase extends UseCase<LoginResponseEntity, LoginParams> {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  @override
  Future<Either<Failure, LoginResponseEntity>> call(LoginParams params) async {
    return await authRepository.login(params.loginRequestEntity);
  }
}

class LoginParams {
  final LoginRequestEntity loginRequestEntity;

  LoginParams(this.loginRequestEntity);
}
