import 'package:my_flutter_template/features/auth/data/models/login_request_model.dart';
import 'package:equatable/equatable.dart';

class LoginRequestEntity extends Equatable {
  final String phoneNumber;
  final String password;

  /// Qurilmalar chegarasiga yetilganda foydalanuvchi tanlagan, hisobdan
  /// chiqarib yuboriladigan qurilma (uning o'rniga shu qurilmadan kiriladi).
  final String? replaceDeviceId;

  const LoginRequestEntity({
    required this.phoneNumber,
    required this.password,
    this.replaceDeviceId,
  });

  @override
  List<Object?> get props => [
        phoneNumber,
        password,
        replaceDeviceId,
      ];
}

extension LoginRequestEntityExtension on LoginRequestEntity {
  LoginRequestModel get toModel => LoginRequestModel(
        phoneNumber: phoneNumber,
        password: password,
        replaceDeviceId: replaceDeviceId,
      );
}
