import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/profile/data/models/user_update_response.dart';
import 'package:my_flutter_template/features/profile/domain/entities/user_update_request_entity.dart';
import 'package:my_flutter_template/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateUserInfoUseCase extends UseCase<UserUpdateResponse, UserUpdateParams> {
  final ProfileRepository repository;

  UpdateUserInfoUseCase(this.repository);

  @override
  Future<Either<Failure, UserUpdateResponse>> call(UserUpdateParams params) async {
    return await repository.updateUser(params.request);
  }
}

class UserUpdateParams {
  final UserUpdateRequestEntity request;

  UserUpdateParams(this.request);
}
