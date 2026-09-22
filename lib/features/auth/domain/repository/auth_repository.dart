import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/auth/domain/entities/confirm_response_entity.dart';
import 'package:my_flutter_template/features/auth/domain/entities/login_request_entity.dart';
import 'package:my_flutter_template/features/auth/domain/entities/login_response_entity.dart';
import 'package:my_flutter_template/features/auth/domain/entities/register_request_entity.dart';
import 'package:dartz/dartz.dart';

import '../entities/confirm_request_entity.dart';
import '../entities/register_response_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, RegisterResponseEntity>> register(
      RegisterRequestEntity registerRequestEntity);

  Future<Either<Failure, LoginResponseEntity>> login(
      LoginRequestEntity loginRequestEntity);

  Future<Either<Failure, ConfirmResponseEntity>> confirm(
    ConfirmRequestEntity confirmRequestEntity,
    bool reset,
  );
}
