import 'package:equatable/equatable.dart';
import 'package:my_flutter_template/features/auth/data/models/confirm_request_model.dart';

class ConfirmRequestEntity extends Equatable {
  final String phone;
  final String smsCode;

  const ConfirmRequestEntity({
    required this.phone,
    required this.smsCode,
  });

  @override
  List<Object> get props => [phone, smsCode];

  /// Entity → Model
  ConfirmRequestModel toModel() {
    return ConfirmRequestModel(
      phone: phone,
      smsCode: smsCode,
    );
  }

  /// Model → Entity
  factory ConfirmRequestEntity.fromModel(ConfirmRequestModel model) {
    return ConfirmRequestEntity(
      phone: model.phone ?? '',
      smsCode: model.smsCode ?? '',
    );
  }
}
