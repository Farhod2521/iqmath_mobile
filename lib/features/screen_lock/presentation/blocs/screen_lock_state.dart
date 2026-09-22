part of 'screen_lock_bloc.dart';

abstract class ScreenLockState extends Equatable {
  const ScreenLockState();
}

class ScreenLockCheckState extends ScreenLockState {
  final bool isCorrectPin;
  final List<int>? pinCode;
  final bool isBiometricsEnabled;
  final int failedAttempts;

  const ScreenLockCheckState({
    this.isCorrectPin = true,
    this.pinCode,
    this.isBiometricsEnabled = false,
    this.failedAttempts = 0,
  });

  ScreenLockCheckState copyWith({
    bool? isCorrectPin,
    List<int>? pinCode,
    bool? isBiometricsEnabled,
    int? failedAttempts,
  }) {
    return ScreenLockCheckState(
      isCorrectPin: isCorrectPin ?? this.isCorrectPin,
      pinCode: pinCode ?? this.pinCode,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }

  int get remainingAttempts => 5 - failedAttempts;

  @override
  List<Object?> get props => [
        isCorrectPin,
        pinCode,
        isBiometricsEnabled,
        failedAttempts,
      ];
}

class ScreenLockCreateState extends ScreenLockState {
  final List<int>? confirmPinCode;
  final bool isCorrectPin;
  final List<int>? pinCode;
  final bool isBiometricsEnabled;

  const ScreenLockCreateState({
    this.confirmPinCode,
    this.isCorrectPin = true,
    this.pinCode,
    this.isBiometricsEnabled = true,
  });

  ScreenLockCreateState copyWith({
    List<int>? confirmPinCode,
    bool? isCorrectPin,
    List<int>? pinCode,
    bool? isBiometricsEnabled,
  }) {
    return ScreenLockCreateState(
      confirmPinCode: confirmPinCode ?? this.confirmPinCode,
      isCorrectPin: isCorrectPin ?? this.isCorrectPin,
      pinCode: pinCode ?? this.pinCode,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        confirmPinCode,
        isCorrectPin,
        pinCode,
        isBiometricsEnabled,
      ];
}

class ScreenLockUpdateState extends ScreenLockState {
  final List<int>? confirmPinCode;
  final bool isCorrectPin;
  final List<int>? oldPinCode;
  final List<int>? newPinCode;

  const ScreenLockUpdateState({
    this.confirmPinCode,
    this.isCorrectPin = true,
    this.oldPinCode,
    this.newPinCode,
  });

  ScreenLockUpdateState copyWith({
    List<int>? confirmPinCode,
    bool? isCorrectPin,
    List<int>? oldPinCode,
    List<int>? newPinCode,
  }) {
    return ScreenLockUpdateState(
      confirmPinCode: confirmPinCode ?? this.confirmPinCode,
      isCorrectPin: isCorrectPin ?? this.isCorrectPin,
      oldPinCode: oldPinCode ?? this.oldPinCode,
      newPinCode: newPinCode ?? this.newPinCode,
    );
  }

  @override
  List<Object?> get props => [
        confirmPinCode,
        isCorrectPin,
        oldPinCode,
        newPinCode,
      ];
}

enum ScreenLockStatus { create, check, update }

extension ScreenLockStatusX on ScreenLockStatus {
  bool get isCreate => this == ScreenLockStatus.create;

  bool get isCheck => this == ScreenLockStatus.check;

  bool get isReenter => this == ScreenLockStatus.update;
}
