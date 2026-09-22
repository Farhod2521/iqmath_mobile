import 'package:equatable/equatable.dart';

import '../../data/models/login_response_model.dart';

class LoginResponseEntity extends Equatable {
  final num id;
  final String fullName;
  final String phone;
  final String role;
  final bool status;
  final String accessToken;
  final String refreshToken;
  final num expiresIn;

  const LoginResponseEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.status,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        role,
        status,
        accessToken,
        refreshToken,
        expiresIn,
      ];
}

extension LoginResponseModelX on LoginResponseModel {
  LoginResponseEntity get toEntity {
    return LoginResponseEntity(
      id: id ?? 0,
      fullName: fullName ?? '',
      phone: phone ?? '',
      role: role ?? '',
      status: status ?? false,
      accessToken: accessToken ?? '',
      refreshToken: refreshToken ?? '',
      expiresIn: expiresIn ?? 0,
    );
  }
}
