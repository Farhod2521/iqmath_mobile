import 'package:equatable/equatable.dart';

/// phone_number : "+998111234567"
/// tag : "string"

class LoginRequestModel extends Equatable {
  LoginRequestModel({
    this.phoneNumber,
    this.password,
  });

  LoginRequestModel.fromJson(dynamic json) {
    phoneNumber = json['phone'];
    password = json['password'];
  }

  String? phoneNumber;
  String? password;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phone'] = phoneNumber;
    map['password'] = password;
    return map;
  }

  @override
  List<Object?> get props => [phoneNumber, password];
}
