import 'package:equatable/equatable.dart';

/// phone_number : "+998111234567"
/// tag : "string"

class LoginRequestModel extends Equatable {
  LoginRequestModel({
    this.phoneNumber,
    this.password,
    this.replaceDeviceId,
  });

  LoginRequestModel.fromJson(dynamic json) {
    phoneNumber = json['phone'];
    password = json['password'];
    replaceDeviceId = json['replace_device_id'];
  }

  String? phoneNumber;
  String? password;
  String? replaceDeviceId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phone'] = phoneNumber;
    map['password'] = password;
    if (replaceDeviceId != null) map['replace_device_id'] = replaceDeviceId;
    return map;
  }

  @override
  List<Object?> get props => [phoneNumber, password, replaceDeviceId];
}
