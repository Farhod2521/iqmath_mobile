import 'package:equatable/equatable.dart';
import 'package:my_flutter_template/features/auth/data/models/confirm_response_model.dart';

class ConfirmResponseEntity extends Equatable {
  final String message;
  final String login;
  final String password;
  final String accessToken;
  final num expiresIn;
  final String role;
  final ProfileEntity profile;

  const ConfirmResponseEntity({
    required this.message,
    required this.login,
    required this.password,
    required this.accessToken,
    required this.expiresIn,
    required this.role,
    required this.profile,
  });

  @override
  List<Object> get props => [
    message,
    login,
    password,
    accessToken,
    expiresIn,
    role,
    profile,
  ];
}

/// Profile Entity
class ProfileEntity extends Equatable {
  final int studentId;
  final String fullName;
  final bool status;

  const ProfileEntity({
    required this.studentId,
    required this.fullName,
    required this.status,
  });

  @override
  List<Object> get props => [studentId, fullName, status];
}

/// Mapping extension: Model → Entity
extension ConfirmResponseModelX on ConfirmResponseModel {
  ConfirmResponseEntity get toEntity {
    return ConfirmResponseEntity(
      message: message ?? '',
      login: login ?? '',
      password: password ?? '',
      accessToken: accessToken ?? '',
      expiresIn: expiresIn ?? 0,
      role: role ?? '',
      profile: ProfileEntity(
        studentId: profile?.studentId ?? 0,
        fullName: profile?.fullName ?? '',
        status: profile?.status ?? false,
      ),
    );
  }
}
