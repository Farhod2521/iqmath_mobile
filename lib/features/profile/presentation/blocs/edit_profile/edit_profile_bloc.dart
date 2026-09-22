import 'dart:async';

import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/features/profile/domain/entities/user_update_request_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../injector_container.dart';
import '../../../domain/usecases/update_user_info_usecase.dart';
import '../../../domain/usecases/upload_image_usecase.dart';

part 'edit_profile_event.dart';

part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState>
    with BaseBlocMixin {
  final UpdateUserInfoUseCase updateUserInfoUseCase;
  final UploadImageUseCase uploadImageUseCase;

  EditProfileBloc({
    required this.updateUserInfoUseCase,
    required this.uploadImageUseCase,
  }) : super(const EditProfileState()) {
    on<EditProfileChangeImage>(_changeImageHandler);
    on<EditProfileChangeInfoEvent>(_changeInfoHandler);
  }

  FutureOr<void> _changeImageHandler(
    EditProfileChangeImage event,
    Emitter<EditProfileState> emit,
  ) async {
    final ImagePicker picker = ImagePicker();
    XFile? photo;
    if (event.isFromGallery) {
      photo = await picker.pickImage(source: ImageSource.gallery);
    } else {
      photo = await picker.pickImage(source: ImageSource.camera);
    }
    final bytes = await photo?.readAsBytes();
    if (bytes != null) {
      final compressedPhotoBytes = await FlutterImageCompress.compressWithList(
        bytes,
        format: CompressFormat.heic,
        minHeight: 1080,
        minWidth: 375,
      );
      final response = await uploadImageUseCase(
        UploadImageParams(compressedPhotoBytes),
      );
      response.fold(
        (failure) => getErrorMessage(failure),
        (success) => emit(
          state.copyWith(
            changeProfileImageUrl: success,
            profileImageUrl: photo?.path,
          ),
        ),
      );
    }
  }

  FutureOr<void> _changeInfoHandler(
      EditProfileChangeInfoEvent event, Emitter<EditProfileState> emit) async {
    final localSource = sl<LocalSource>();
    emit(state.copyWith(status: EditProfileStatus.loading));
    final request = UserUpdateRequestEntity(
      address: event.address,
      fullName: event.firstName,
      email: event.email,
    );
    final response = await updateUserInfoUseCase(
      UserUpdateParams(request),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          status: EditProfileStatus.error,
          errorMessage: getErrorMessage(failure),
        ),
      ),
      (r) {
        localSource.setFirstName(event.firstName ?? '');
        localSource.setUserAddress(event.address ?? '');
        emit(
          state.copyWith(
            status: EditProfileStatus.success,
            errorMessage: (
              title: r.message,
              message: r.message,
            ),
          ),
        );
      },
    );
  }
}
