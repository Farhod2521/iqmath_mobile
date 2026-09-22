import 'dart:typed_data';

import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/features/profile/data/models/user_update_response.dart';
import 'package:my_flutter_template/features/profile/domain/entities/faq_response_entity.dart';
import 'package:my_flutter_template/features/profile/domain/entities/user_update_request_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserUpdateResponse>> updateUser(UserUpdateRequestEntity request);

  Future<Either<Failure, FaqResponseEntity>> getFaq();

  Future<Either<Failure, String>> uploadImage(Uint8List file);

  Future<Either<Failure, None>> deleteUser(String userId);
}
