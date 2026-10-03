part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthSetStatus extends AuthEvent {
  final AuthStatus status;

  const AuthSetStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class AuthLoginEvent extends AuthEvent {
  final String phoneNumber;
  final String password;

  /// Qurilmalar chegarasida tanlangan, chiqarib yuboriladigan qurilma.
  final String? replaceDeviceId;

  const AuthLoginEvent({
    required this.phoneNumber,
    required this.password,
    this.replaceDeviceId,
  });

  @override
  List<Object?> get props => [phoneNumber, password, replaceDeviceId];
}

class AuthRegisterEvent extends AuthEvent {
  final String fullName;
  final String phone;
  final String role;
  final String className;
  final String referralCode;
  final String lang;

  const AuthRegisterEvent({
    required this.fullName,
    required this.phone,
    required this.role,
    required this.className,
    required this.referralCode,
    required this.lang,
  });

  @override
  List<Object?> get props => [
        fullName,
        phone,
        role,
        className,
        referralCode,
        lang,
      ];
}

class ConfirmEvent extends AuthEvent {
  final String phone;
  final String smsCode;
  final bool reset;

  const ConfirmEvent({
    required this.phone,
    required this.smsCode,
    required this.reset,
  });

  @override
  List<Object?> get props => [
        phone,
        smsCode,
        reset,
      ];
}
