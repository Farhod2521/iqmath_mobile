import 'package:equatable/equatable.dart';

class RegisterRequestModel extends Equatable {
  RegisterRequestModel({
    this.fullName,
    this.phone,
    this.role,
    this.className,
    this.referralCode,
    this.lang,
    this.device,
  });

  RegisterRequestModel.fromJson(dynamic json) {
    fullName = json['full_name'];
    phone = json['phone'];
    role = json['role'];
    className = json['class_name'];
    referralCode = json['referral_code'];
    lang = json['lang'];
    device = json['device'];
  }

  String? fullName;
  String? phone;
  String? role;
  String? className;
  String? referralCode;
  String? lang;
  String? device;

  Map<String, dynamic> toJson() {
    return {
      if (_isValid(fullName)) 'full_name': fullName,
      if (_isValid(phone)) 'phone': phone,
      if (_isValid(role)) 'role': role,
      if (_isValid(className)) 'class_name': className,
      if (_isValid(referralCode)) 'referral_code': referralCode,
      if (_isValid(lang)) 'lang': lang,
      if (_isValid(device)) 'device': device,
    };
  }

  bool _isValid(String? value) {
    return value != null &&
        value.isNotEmpty &&
        value != 'null' &&
        value.toLowerCase() != 'null';
  }

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
