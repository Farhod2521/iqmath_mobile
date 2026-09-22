import 'package:my_flutter_template/features/main/data/models/user_response.dart';

abstract class MainRemoteDataSource {
  Future<UserResponse> getUserInfo();
}
