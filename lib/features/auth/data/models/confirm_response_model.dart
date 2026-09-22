import 'package:equatable/equatable.dart';

class ConfirmResponseModel extends Equatable {
  const ConfirmResponseModel({
    this.message,
    this.login,
    this.password,
    this.accessToken,
    this.expiresIn,
    this.role,
    this.profile,
  });

  ConfirmResponseModel.fromJson(dynamic json)
      : message = json['message'],
        login = json['login'],
        password = json['password'],
        accessToken = json['access_token'],
        expiresIn = json['expires_in'],
        role = json['role'],
        profile = json['profile'] != null
            ? Profile.fromJson(json['profile'])
            : null;

  final String? message;
  final String? login;
  final String? password;
  final String? accessToken;
  final num? expiresIn;
  final String? role;
  final Profile? profile;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'login': login,
      'password': password,
      'access_token': accessToken,
      'expires_in': expiresIn,
      'role': role,
      if (profile != null) 'profile': profile?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    message,
    login,
    password,
    accessToken,
    expiresIn,
    role,
    profile,
  ];
}

class Profile extends Equatable {
  const Profile({
    this.studentId,
    this.fullName,
    this.status,
  });

  Profile.fromJson(dynamic json)
      : studentId = json['student_id'],
        fullName = json['full_name'],
        status = json['status'];

  final int? studentId;
  final String? fullName;
  final bool? status;

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'full_name': fullName,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [studentId, fullName, status];
}
