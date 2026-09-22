import 'package:my_flutter_template/features/auth/data/models/login_request_model.dart';
import 'package:equatable/equatable.dart';

class LoginRequestEntity extends Equatable {
  final String phoneNumber;
  final String password;

  const LoginRequestEntity({
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object> get props => [
        phoneNumber,
        password,
      ];
}

extension LoginRequestEntityExtension on LoginRequestEntity {
  LoginRequestModel get toModel => LoginRequestModel(
        phoneNumber: phoneNumber,
        password: password,
      );
}
