import 'package:my_flutter_template/features/auth/data/models/confirm_response_model.dart';
import 'package:my_flutter_template/features/auth/data/models/login_response_model.dart';

import '../../models/confirm_request_model.dart';
import '../../models/login_request_model.dart';
import '../../models/register_request_model.dart';
import '../../models/register_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<ConfirmResponseModel> confirm(
    ConfirmRequestModel confirmRequestModel,
    bool reset,
  );

  Future<LoginResponseModel> login(LoginRequestModel loginRequestModel);

  Future<RegisterResponseModel> register(
      RegisterRequestModel registerRequestModel);
}
