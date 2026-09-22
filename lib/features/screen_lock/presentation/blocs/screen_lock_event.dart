part of 'screen_lock_bloc.dart';

abstract class ScreenLockEvent extends Equatable {
  const ScreenLockEvent();
}

class ScreenLockNumberTapped extends ScreenLockEvent {
  final int number;
  final ScreenLockStatus status;

  const ScreenLockNumberTapped({required this.number, required this.status});

  @override
  List<Object> get props => [number, status];
}

class ScreenLockArrowBackTapped extends ScreenLockEvent {
  final ScreenLockStatus status;

  const ScreenLockArrowBackTapped(this.status);

  @override
  List<Object> get props => [status];
}

class ScreenLockSetBioMetrics extends ScreenLockEvent {
  final bool isBioMetrics;

  const ScreenLockSetBioMetrics(this.isBioMetrics);

  @override
  List<Object> get props => [isBioMetrics];
}

class ScreenLockSetStatusEvent extends ScreenLockEvent {
  final ScreenLockStatus status;

  const ScreenLockSetStatusEvent({required this.status});

  @override
  List<Object> get props => [status];
}

class ScreenLockResetEvent extends ScreenLockEvent {
  final ScreenLockStatus status;

  const ScreenLockResetEvent(this.status);

  @override
  List<Object> get props => [status];
}

class ScreenLockSetErrorEvent extends ScreenLockEvent {
  final ScreenLockStatus status;
  final bool isCorrectPin;

  const ScreenLockSetErrorEvent(
      {required this.isCorrectPin, required this.status});

  @override
  List<Object> get props => [isCorrectPin, status];
}
