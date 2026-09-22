part of 'edit_profile_bloc.dart';

class EditProfileState extends Equatable {
  final EditProfileStatus status;
  final String? profileImageUrl;
  final String? changeProfileImageUrl;
  final ({String title, String message})? errorMessage;

  const EditProfileState({
    this.status = EditProfileStatus.idle,
    this.errorMessage,
    this.changeProfileImageUrl,
    this.profileImageUrl,
  });

  EditProfileState copyWith({
    String? profileImageUrl,
    EditProfileStatus? status,
    String? changeProfileImageUrl,
    ({String title, String message})? errorMessage,
  }) {
    return EditProfileState(
      status: status ?? EditProfileStatus.idle,
      errorMessage: errorMessage ?? this.errorMessage,
      changeProfileImageUrl:
          changeProfileImageUrl ?? this.changeProfileImageUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  List<Object?> get props =>
      [profileImageUrl, status, errorMessage, changeProfileImageUrl];
}

enum EditProfileStatus { idle, loading, success, error }

extension EditProfileStatusX on EditProfileStatus {
  bool get isIdle => this == EditProfileStatus.idle;

  bool get isLoading => this == EditProfileStatus.loading;

  bool get isSuccess => this == EditProfileStatus.success;

  bool get isError => this == EditProfileStatus.error;
}
