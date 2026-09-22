import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:my_flutter_template/features/profile/data/models/user_update_response.dart';

import '../../models/faq_response.dart';
import '../../models/user_update_request.dart';

abstract class ProfileRemoteDataSource {
  Future<UserUpdateResponse> updateUser(UserUpdateRequest request);

  Future<FaqResponse> getFAQ();

  Future<String> uploadImage(Uint8List file);

  Future<None> deleteUser(String userId);
}
