import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/main/domain/entities/user_response_entity.dart';
import 'package:dartz/dartz.dart';

abstract class MainRepository {
  Future<Either<Failure, UserResponseEntity>> getUserInfo();
}
