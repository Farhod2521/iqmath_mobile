import 'dart:typed_data';

import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';

class UploadImageUseCase extends UseCase<String, UploadImageParams> {
  final ProfileRepository profileRepository;

  UploadImageUseCase(this.profileRepository);

  @override
  Future<Either<Failure, String>> call(UploadImageParams params) async {
    return await profileRepository.uploadImage(params.file);
  }
}

class UploadImageParams {
  final Uint8List file;

  UploadImageParams(this.file);
}
