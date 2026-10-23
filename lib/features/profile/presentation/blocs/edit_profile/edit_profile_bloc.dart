import 'dart:async';
import 'dart:typed_data';

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
    try {
      // Rasm o'lchamini tanlashda kichraytiramiz — katta kamera rasmlari xotirani to'ldirib,
      // Android ilovani yopib qo'ymasligi uchun
      photo = await picker.pickImage(
        source: event.isFromGallery ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90,
      );
    } catch (_) {
      // Ruxsat berilmagan / kamera yo'q — jim qaytamiz
      return;
    }
    if (photo == null) return;

    final bytes = await photo.readAsBytes();
    Uint8List uploadBytes = bytes;
    try {
      // JPEG: HEIC siqish ko'p Android qurilmalarda (HEVC kodeki yo'q) ilovani yopib qo'yardi
      uploadBytes = await FlutterImageCompress.compressWithList(
        bytes,
        format: CompressFormat.jpeg,
        quality: 85,
        minHeight: 512,
        minWidth: 512,
      );
    } catch (_) {
      uploadBytes = bytes; // siqib bo'lmasa — asl rasm (server o'zi kichraytiradi)
    }

    emit(state.copyWith(status: EditProfileStatus.loading, profileImageUrl: photo.path));
    final response = await uploadImageUseCase(UploadImageParams(uploadBytes));
    response.fold(
      (failure) => emit(
        state.copyWith(
          status: EditProfileStatus.error,
          errorMessage: getErrorMessage(failure),
        ),
      ),
      (success) {
        sl<LocalSource>().setAvatarUrl(success);
        emit(
          state.copyWith(
            status: EditProfileStatus.idle,
            changeProfileImageUrl: success,
            profileImageUrl: photo?.path,
          ),
        );
      },
    );
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
