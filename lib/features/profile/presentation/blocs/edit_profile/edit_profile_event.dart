part of 'edit_profile_bloc.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();
}

class EditProfileChangeImage extends EditProfileEvent {
  final bool isFromGallery;

  const EditProfileChangeImage({required this.isFromGallery});

  @override
  List<Object?> get props => [isFromGallery];
}

class EditProfileChangeInfoEvent extends EditProfileEvent {
  final String? firstName;
  final String? email;
  final String? address;
  final String? phoneNumber;

  const EditProfileChangeInfoEvent({
    this.firstName,
    this.email,
    this.address,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        firstName,
        email,
        address,
        phoneNumber,
      ];
}
