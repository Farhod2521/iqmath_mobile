import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/core/error/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
