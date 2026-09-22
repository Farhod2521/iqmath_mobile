import 'package:equatable/equatable.dart';

class ConfirmRequestModel extends Equatable {
  const ConfirmRequestModel({
    this.smsCode,
    this.phone,
  });

  ConfirmRequestModel.fromJson(dynamic json)
      : smsCode = json['sms_code'],
        phone = json['phone'];

  final String? smsCode;
  final String? phone;

  Map<String, dynamic> toJson() {
    return {
      'sms_code': smsCode,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [smsCode, phone];
}
