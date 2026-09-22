import 'package:equatable/equatable.dart';
import 'package:my_flutter_template/features/profile/data/models/user_update_request.dart';

class UserUpdateRequestEntity extends Equatable {
  const UserUpdateRequestEntity({
    this.fullName,
    this.email,
    this.address,
  });

  final String? fullName;
  final String? email;
  final String? address;

  @override
  List<Object?> get props => [
    fullName,
    email,
    address,
  ];
}

extension UserUpdateRequestEntityX on UserUpdateRequestEntity {
  UserUpdateRequest get toModel => UserUpdateRequest(
    fullName: fullName,
    email: email,
    address: address,
  );
}
