import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:equatable/equatable.dart';

import '../../../../../injector_container.dart';
import '../../../domain/usecases/delete_user_usecase.dart';

part 'security_event.dart';

part 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState>
    with BaseBlocMixin {
  final DeleteUserUseCase deleteUserUseCase;

  SecurityBloc({required this.deleteUserUseCase})
      : super(const SecurityState()) {
    on<SecurityDeleteUserEvent>(_deleteUserHandler);
  }

  FutureOr<void> _deleteUserHandler(
      SecurityDeleteUserEvent event, Emitter<SecurityState> emit) async {
    emit(state.copyWith(status: SecurityStatus.loading));
    String userId = sl<LocalSource>().getUserId() ?? 'empty';
    final response = await deleteUserUseCase(
      DeleteUserParams(userId),
    );
    response.fold(
      (failure) => emit(
        state.copyWith(
          status: SecurityStatus.error,
          errorMessage: getErrorMessage(failure),
        ),
      ),
      (success) => emit(
        state.copyWith(
          status: SecurityStatus.success,
        ),
      ),
    );
  }
}
