import 'package:equatable/equatable.dart';
import 'package:my_flutter_template/features/auth/data/models/register_response_model.dart';

class RegisterResponseEntity extends Equatable {
  final String? message;

  const RegisterResponseEntity({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

extension RegisterResponseModelX on RegisterResponseModel {
  RegisterResponseEntity get toEntity => RegisterResponseEntity(
    message: message,
  );
}
