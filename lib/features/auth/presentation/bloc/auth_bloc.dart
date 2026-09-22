import 'dart:async';
import 'dart:developer';

import 'package:my_flutter_template/core/error/failure.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/features/auth/domain/entities/login_request_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injector_container.dart';
import '../../domain/entities/confirm_request_entity.dart';
import '../../domain/entities/confirm_response_entity.dart';
import '../../domain/entities/register_request_entity.dart';
import '../../domain/usecases/confirm_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> with BaseBlocMixin {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ConfirmUseCase confirmUseCase;

  AuthBloc(
      {required this.loginUseCase,
      required this.registerUseCase,
      required this.confirmUseCase})
      : super(const AuthState()) {
    on<AuthSetStatus>(setStatusHandler);
    on<AuthLoginEvent>(_loginHandler);
    on<AuthRegisterEvent>(_registerHandler);
    on<ConfirmEvent>(_confirmHandler);
  }

  FutureOr<void> setStatusHandler(event, emit) {
    emit(state.copyWith(status: event.status));
  }

  // FutureOr<void> _setSurnameHandler(
  //   AuthSetSurnameEvent event,
  //   Emitter<AuthState> emit,
  // ) {
  //   emit(state.copyWith(surname: event.surname));
  // }
  //
  // FutureOr<void> _setFirstNameHandler(
  //   AuthSetFirstNameEvent event,
  //   Emitter<AuthState> emit,
  // ) {
  //   emit(state.copyWith(firstName: event.firstName));
  // }
  //
  // FutureOr<void> _setPhoneNumberHandler(
  //   AuthSetPhoneNumberEvent event,
  //   Emitter<AuthState> emit,
  // ) {
  //   var newPhoneNumber = event.phoneNumber
  //       .replaceAll('(', '')
  //       .replaceAll(')', '')
  //       .replaceAll(' ', '')
  //       .replaceAll('-', '');
  //   emit(
  //     state.copyWith(
  //       phoneNumber: newPhoneNumber,
  //     ),
  //   );
  // }
  //
  // FutureOr<void> _setSmsCodeHandler(
  //   AuthSetSmsCodeEvent event,
  //   Emitter<AuthState> emit,
  // ) {
  //   var newSmsCode = event.smsCode.replaceAll('-', '');
  //   emit(
  //     state.copyWith(
  //       smsCode: newSmsCode,
  //     ),
  //   );
  // }
  //
  // Future<void> registerApi(Emitter<AuthState> emit) async {
  //   emit(state.copyWith(stateStatus: AuthStateStatus.loading));
  //   final response = await registerUseCase(
  //     RegisterParams(
  //       RegisterRequestEntity(
  //         lastName: state.surname ?? 'empty',
  //         firstName: state.firstName ?? 'empty',
  //         phoneNumber: "+998${state.phoneNumber}",
  //         password: '',
  //         login: "+998${state.phoneNumber}",
  //         tag: '',
  //         userType: 0,
  //       ),
  //     ),
  //   );
  //   response.fold(
  //     (error) {
  //       emit(
  //         state.copyWith(
  //           stateStatus: AuthStateStatus.error,
  //           errorMessage: getErrorMessage(error),
  //         ),
  //       );
  //     },
  //     (data) {
  //       emit(
  //         state.copyWith(
  //           stateStatus: AuthStateStatus.success,
  //           smsId: data.smsId,
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // FutureOr<void> _smsCodeButtonClickHandler(
  //   AuthSmsCodeButtonClickEvent event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   emit(state.copyWith(stateStatus: AuthStateStatus.loading));
  //   final response = await confirmUseCase(
  //     ConfirmParams(
  //       ConfirmRequestEntity(
  //         smsId: state.smsId ?? 'empty',
  //         code: state.smsCode ?? 'empty',
  //         phoneNumber: "+998${state.phoneNumber}",
  //       ),
  //     ),
  //   );
  //   response.fold(
  //     (error) {
  //       emit(
  //         state.copyWith(
  //           stateStatus: AuthStateStatus.error,
  //           errorMessage: getErrorMessage(error),
  //         ),
  //       );
  //     },
  //     (data) {
  //       final localSource = sl<LocalSource>();
  //       localSource.setAccessToken("Bearer ${data.accessToken}");
  //       localSource.setRefreshToken(data.refreshToken ?? 'empty');
  //       localSource.setFirstName(data.firstName ?? 'empty');
  //       localSource.setLastName(data.surname ?? 'empty');
  //       localSource.setUserId(data.userId ?? 'empty');
  //       localSource.setPhoneNumber(data.phoneNumber ?? 'empty');
  //       emit(
  //         state.copyWith(
  //           stateStatus: AuthStateStatus.success,
  //         ),
  //       );
  //     },
  //   );
  // }

  // FutureOr<void> _nameButtonClickHandler(
  //   AuthNameButtonClickEvent event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   if (state.firstName != null &&
  //       state.surname != null &&
  //       state.firstName!.isNotEmpty &&
  //       state.surname!.isNotEmpty) {
  //     await registerApi(emit);
  //   } else {
  //     emit(
  //       state.copyWith(
  //         stateStatus: AuthStateStatus.error,
  //       ),
  //     );
  //   }
  // }

  FutureOr<void> _loginHandler(
      AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(stateStatus: AuthStateStatus.loading));
    var newPhoneNumber = event.phoneNumber
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '')
        .replaceAll('-', '');
    final response = await loginUseCase(
      LoginParams(
        LoginRequestEntity(
          phoneNumber: "998$newPhoneNumber",
          password: event.password,
        ),
      ),
    );
    response.fold(
      (error) {
        emit(
          state.copyWith(
            stateStatus: AuthStateStatus.error,
            errorMessage: getErrorMessage(error),
          ),
        );
      },
      (data) {
        if (data.role == 'student' ||
            data.role == 'parent' ||
            data.role == 'tutor') {
          final localSource = sl<LocalSource>();
          localSource.setAccessToken("Bearer ${data.accessToken}");
          localSource.setRefreshToken(data.refreshToken);
          localSource.setRefreshToken(data.refreshToken ?? '');
          localSource.setPhoneNumber(event.phoneNumber ?? '');
          localSource.setUserPassword(event.password ?? '');
          localSource.setFirstName(data.fullName);
          localSource.setUserRole(data.role ?? '');
          localSource.setUserProfileID(data.id.toString());
          emit(
            state.copyWith(
              stateStatus: AuthStateStatus.success,
              role: data.role,
            ),
          );
        } else {
          emit(
            state.copyWith(
              stateStatus: AuthStateStatus.success,
              role: data.role,
            ),
          );
        }
      },
    );
  }

  FutureOr<void> _registerHandler(
      AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(registerStatus: AuthRegisterStatus.loading));
    var newPhoneNumber = event.phone
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '')
        .replaceAll('-', '');
    final response = await registerUseCase(
      RegisterParams(
        RegisterRequestEntity(
          fullName: event.fullName,
          phone: "998$newPhoneNumber",
          role: event.role,
          className: event.className,
          referralCode: '',
          lang: event.lang,
          device: 'mobile',
          // referralCode: event.referralCode,
        ),
      ),
    );
    response.fold(
      (error) {
        emit(
          state.copyWith(
            registerStatus: AuthRegisterStatus.error,
            errorMessage: getErrorMessage(error),
          ),
        );
      },
      (data) {
        emit(
          state.copyWith(
            registerStatus: AuthRegisterStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _confirmHandler(
      ConfirmEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(confirmStatus: ConfirmStatus.loading));
    var newPhoneNumber = event.phone
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');
    final response = await confirmUseCase(
      ConfirmParams(
        ConfirmRequestEntity(
          phone: "998$newPhoneNumber",
          smsCode: event.smsCode,
        ),
        event.reset,
      ),
    );
    response.fold(
      (error) {
        emit(
          state.copyWith(
            confirmStatus: ConfirmStatus.error,
            errorMessage: getErrorMessage(error),
          ),
        );
      },
      (data) {
        if (data.role == 'student' ||
            data.role == 'parent' ||
            data.role == 'tutor') {
          final localSource = sl<LocalSource>();
          localSource.setAccessToken("Bearer ${data.accessToken}");
          // localSource.setRefreshToken(data.refreshToken ?? 'empty');
          localSource.setPhoneNumber(data.login.replaceAll('998', '') ?? '');
          localSource
              .setUserPassword(data.password.replaceAll('998', '') ?? '');
          localSource.setUserId(data.profile.studentId.toString());
          localSource.setFirstName(data.profile.fullName);
          localSource.setUserRole(data.role);
          emit(
            state.copyWith(
              confirmStatus: ConfirmStatus.success,
              confirmResponseEntity: data,
              role: data.role,
            ),
          );
        } else {
          emit(
            state.copyWith(
              confirmStatus: ConfirmStatus.success,
              confirmResponseEntity: data,
              role: data.role,
            ),
          );
        }
      },
    );
  }
}
