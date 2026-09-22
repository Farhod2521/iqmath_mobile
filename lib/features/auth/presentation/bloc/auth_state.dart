part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final AuthStateStatus stateStatus;
  final AuthRegisterStatus registerStatus;
  final ConfirmStatus confirmStatus;
  final AuthStatus status;
  final String? phoneNumber;
  final String? smsCode;
  final String? firstName;
  final String? surname;
  final String? smsId;
  final bool isUserExists;
  final bool isPageScrolling;
  final ({String title, String message})? errorMessage;
  final ConfirmResponseEntity? confirmResponseEntity;
  final String? role;

  const AuthState({
    this.status = AuthStatus.phoneNumber,
    this.stateStatus = AuthStateStatus.initial,
    this.registerStatus = AuthRegisterStatus.initial,
    this.confirmStatus = ConfirmStatus.initial,
    this.isUserExists = false,
    this.isPageScrolling = false,
    this.phoneNumber,
    this.smsCode,
    this.firstName,
    this.surname,
    this.smsId,
    this.errorMessage,
    this.confirmResponseEntity,
    this.role,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthStateStatus? stateStatus,
    AuthRegisterStatus? registerStatus,
    ConfirmStatus? confirmStatus,
    String? phoneNumber,
    String? smsCode,
    String? firstName,
    String? surname,
    bool? isUserExists,
    bool? isPageScrolling,
    ({String title, String message})? errorMessage,
    String? smsId,
    ConfirmResponseEntity? confirmResponseEntity,
    String? role,
  }) {
    return AuthState(
      status: status ?? this.status,
      stateStatus: stateStatus ?? AuthStateStatus.initial,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      smsCode: smsCode ?? this.smsCode,
      firstName: firstName ?? this.firstName,
      confirmStatus: confirmStatus ?? this.confirmStatus,
      surname: surname ?? this.surname,
      smsId: smsId ?? this.smsId,
      isPageScrolling: isPageScrolling ?? this.isPageScrolling,
      isUserExists: isUserExists ?? this.isUserExists,
      errorMessage: errorMessage ?? this.errorMessage,
      registerStatus: registerStatus ?? AuthRegisterStatus.initial,
      confirmResponseEntity:
          confirmResponseEntity ?? this.confirmResponseEntity,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        status,
        stateStatus,
        phoneNumber,
        smsCode,
        firstName,
        confirmStatus,
        surname,
        smsId,
        isUserExists,
        isPageScrolling,
        errorMessage,
        registerStatus,
        confirmResponseEntity,
        role,
      ];
}

enum AuthStateStatus { initial, loading, success, error }

enum AuthRegisterStatus { initial, loading, success, error }

enum ConfirmStatus { initial, loading, success, error }

enum AuthStatus { phoneNumber, smsCode, nameEnter }

extension ConfirmStatusX on ConfirmStatus {
  bool get isInitial => this == ConfirmStatus.initial;

  bool get isLoading => this == ConfirmStatus.loading;

  bool get isSuccess => this == ConfirmStatus.success;

  bool get isError => this == ConfirmStatus.error;
}

extension AuthRegisterStatusX on AuthRegisterStatus {
  bool get isInitial => this == AuthRegisterStatus.initial;

  bool get isLoading => this == AuthRegisterStatus.loading;

  bool get isSuccess => this == AuthRegisterStatus.success;

  bool get isError => this == AuthRegisterStatus.error;
}

extension AuthStateStatusX on AuthStateStatus {
  bool get isInitial => this == AuthStateStatus.initial;

  bool get isLoading => this == AuthStateStatus.loading;

  bool get isSuccess => this == AuthStateStatus.success;

  bool get isError => this == AuthStateStatus.error;
}

extension AuthStatusX on AuthStatus {
  bool get isPhoneNumber => this == AuthStatus.phoneNumber;

  bool get isSmsCode => this == AuthStatus.smsCode;

  bool get isNameEnter => this == AuthStatus.nameEnter;

  int get toIndex {
    switch (this) {
      case AuthStatus.phoneNumber:
        return 0;
      case AuthStatus.nameEnter:
        return 1;
      case AuthStatus.smsCode:
        return 2;
    }
  }
}

extension AuthStatusY on int? {
  AuthStatus? get page {
    switch (this) {
      case 0:
        return AuthStatus.phoneNumber;
      case 1:
        return AuthStatus.nameEnter;
      case 2:
        return AuthStatus.smsCode;
    }
    return null;
  }
}
