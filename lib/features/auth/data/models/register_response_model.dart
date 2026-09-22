import 'package:equatable/equatable.dart';

class RegisterResponseModel extends Equatable {
  RegisterResponseModel({
    this.message,
  });

  RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
  }

  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    return map;
  }

  @override
  List<Object?> get props => [message];
}
