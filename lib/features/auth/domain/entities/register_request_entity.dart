import 'package:equatable/equatable.dart';
import 'package:my_flutter_template/features/auth/data/models/register_request_model.dart';

class RegisterRequestEntity extends Equatable {
  final String fullName;
  final String phone;
  final String role;
  final String className;
  final String referralCode;
  final String lang;
  final String device;

  const RegisterRequestEntity({
    required this.fullName,
    required this.phone,
    required this.role,
    required this.className,
    required this.referralCode,
    required this.lang,
    required this.device,
  });

  @override
  List<Object?> get props => [
        fullName,
        phone,
        role,
        className,
        referralCode,
        lang,
        device,
      ];
}

extension RegisterRequestEntityX on RegisterRequestEntity {
  RegisterRequestModel get toModel => RegisterRequestModel(
        fullName: fullName,
        phone: phone,
        role: role,
        className: className,
        referralCode: referralCode,
        lang: lang,
        device: device,
      );
}
