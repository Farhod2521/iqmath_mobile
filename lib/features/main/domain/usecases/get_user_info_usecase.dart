import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/main/domain/entities/user_response_entity.dart';
import 'package:my_flutter_template/features/main/domain/repository/main_repository.dart';
import 'package:dartz/dartz.dart';

class GetUserInfoUseCase extends UseCase<UserResponseEntity, NoParams> {
  final MainRepository repository;

  GetUserInfoUseCase(this.repository);

  @override
  Future<Either<Failure, UserResponseEntity>> call(
      NoParams params) async {
    return await repository.getUserInfo();
  }
}
