import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteUserUseCase extends UseCase<None, DeleteUserParams> {
  final ProfileRepository repository;

  DeleteUserUseCase(this.repository);

  @override
  Future<Either<Failure, None>> call(DeleteUserParams params) {
    return repository.deleteUser(params.userId);
  }
}

class DeleteUserParams {
  final String userId;

  DeleteUserParams(this.userId);
}
