import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';

part 'screen_lock_event.dart';

part 'screen_lock_state.dart';

class ScreenLockBloc extends Bloc<ScreenLockEvent, ScreenLockState> {
  ScreenLockBloc() : super(const ScreenLockCreateState()) {
    on<ScreenLockNumberTapped>(_numberTappedHandler);
    on<ScreenLockArrowBackTapped>(_arrowBackTappedHandler);
    on<ScreenLockResetEvent>(_resetHandler);
    on<ScreenLockSetStatusEvent>(_setStatusHandler);
    on<ScreenLockSetErrorEvent>(_setErrorHandler);
    on<ScreenLockSetBioMetrics>(_setBioMetricsHandler);
  }

  FutureOr<void> _numberTappedHandler(
      ScreenLockNumberTapped event, Emitter<ScreenLockState> emit) {
    switch (event.status) {
      case ScreenLockStatus.create:
        _createNumberTapped(event, emit);
      case ScreenLockStatus.check:
        _checkNumberTapped(event, emit);
      case ScreenLockStatus.update:
        _updateNumberTapped(event, emit);
    }
  }

  FutureOr<void> _arrowBackTappedHandler(
      ScreenLockArrowBackTapped event, Emitter<ScreenLockState> emit) {
    switch (event.status) {
      case ScreenLockStatus.create:
        _createArrowBackTapped(event, emit);
      case ScreenLockStatus.check:
        _checkArrowBackTapped(event, emit);
      case ScreenLockStatus.update:
        _updateArrowBackTapped(event, emit);
    }
  }

  FutureOr<void> _resetHandler(
      ScreenLockResetEvent event, Emitter<ScreenLockState> emit) {
    switch (event.status) {
      case ScreenLockStatus.create:
        _createReset(event, emit);
      case ScreenLockStatus.check:
        _checkReset(event, emit);
      case ScreenLockStatus.update:
        _updateReset(event, emit);
    }
  }

  void _createArrowBackTapped(
      ScreenLockArrowBackTapped event, Emitter<ScreenLockState> emit) {
    final createState = state as ScreenLockCreateState;
    if ((createState.pinCode?.length ?? 0) == 4) {
      if (createState.confirmPinCode?.isNotEmpty ?? false) {
        List<int> confirmPinCode = List.from(createState.confirmPinCode ?? []);
        confirmPinCode.removeLast();
        emit(
          createState.copyWith(
            confirmPinCode: confirmPinCode,
          ),
        );
      }
    } else if ((createState.pinCode?.isNotEmpty ?? false) &&
        createState.confirmPinCode == null) {
      List<int> pinCode = List.from(createState.pinCode ?? []);
      pinCode.removeLast();
      emit(
        createState.copyWith(
          pinCode: pinCode,
        ),
      );
    }
  }

  void _checkArrowBackTapped(
      ScreenLockArrowBackTapped event, Emitter<ScreenLockState> emit) {
    final checkState = state as ScreenLockCheckState;
    List<int> pinCode = List.from(checkState.pinCode ?? []);
    if (pinCode.isNotEmpty) {
      pinCode.removeLast();
      emit(
        checkState.copyWith(
          pinCode: pinCode,
        ),
      );
    }
  }

  void _updateArrowBackTapped(
      ScreenLockArrowBackTapped event, Emitter<ScreenLockState> emit) {
    final updateState = state as ScreenLockUpdateState;
    if ((updateState.newPinCode?.length ?? 0) == 4 &&
        (updateState.oldPinCode?.length ?? 0) == 4) {
      if (updateState.confirmPinCode?.isNotEmpty ?? false) {
        List<int> confirmPinCode = List.from(updateState.confirmPinCode ?? []);
        confirmPinCode.removeLast();
        emit(
          updateState.copyWith(
            confirmPinCode: confirmPinCode,
          ),
        );
      }
    } else if ((updateState.oldPinCode?.length ?? 0) == 4 &&
        updateState.confirmPinCode == null) {
      if (updateState.newPinCode?.isNotEmpty ?? false) {
        List<int> newPinCode = List.from(updateState.newPinCode ?? []);
        newPinCode.removeLast();
        emit(
          updateState.copyWith(
            newPinCode: newPinCode,
          ),
        );
      }
    } else if ((updateState.oldPinCode?.isNotEmpty ?? false) &&
        updateState.newPinCode == null &&
        updateState.confirmPinCode == null) {
      List<int> oldPinCode = List.from(updateState.oldPinCode ?? []);
      oldPinCode.removeLast();
      emit(
        updateState.copyWith(
          oldPinCode: oldPinCode,
        ),
      );
    }
  }

  void _createReset(ScreenLockResetEvent event, Emitter<ScreenLockState> emit) {
    final createState = state as ScreenLockCreateState;
    emit(
      ScreenLockCreateState(
        isCorrectPin: createState.isCorrectPin,
      ),
    );
  }

  void _checkReset(ScreenLockResetEvent event, Emitter<ScreenLockState> emit) {
    emit(
      const ScreenLockCheckState(
        pinCode: null,
      ),
    );
  }

  void _updateReset(ScreenLockResetEvent event, Emitter<ScreenLockState> emit) {
    final updateState = state as ScreenLockUpdateState;
    emit(
      ScreenLockUpdateState(
        isCorrectPin: updateState.isCorrectPin,
      ),
    );
  }

  void _createNumberTapped(
      ScreenLockNumberTapped event, Emitter<ScreenLockState> emit) {
    final createState = state as ScreenLockCreateState;
    List<int> pinCode = List.from(createState.pinCode ?? []);
    if (pinCode.length < 4) {
      pinCode.add(event.number);
      emit(
        createState.copyWith(
          pinCode: pinCode,
        ),
      );
    } else if (createState.confirmPinCode == null ||
        createState.confirmPinCode!.length < 4) {
      List<int> confirmPinCode = List.from(createState.confirmPinCode ?? []);
      confirmPinCode.add(event.number);
      emit(
        createState.copyWith(
          confirmPinCode: confirmPinCode,
        ),
      );
    }
  }

  void _checkNumberTapped(
      ScreenLockNumberTapped event, Emitter<ScreenLockState> emit) {
    final checkState = state as ScreenLockCheckState;
    List<int> pinCode = List.from(checkState.pinCode ?? []);
    if (pinCode.length < 4) {
      pinCode.add(event.number);
    }
    emit(
      checkState.copyWith(
        pinCode: pinCode,
      ),
    );
  }

  void _updateNumberTapped(
      ScreenLockNumberTapped event, Emitter<ScreenLockState> emit) {
    final updateState = state as ScreenLockUpdateState;
    if (updateState.oldPinCode == null || updateState.oldPinCode!.length < 4) {
      List<int> oldPinCode = List.from(updateState.oldPinCode ?? []);
      oldPinCode.add(event.number);
      emit(
        updateState.copyWith(
          oldPinCode: oldPinCode,
        ),
      );
    } else if (updateState.newPinCode == null ||
        updateState.newPinCode!.length < 4) {
      List<int> newPinCode = List.from(updateState.newPinCode ?? []);
      newPinCode.add(event.number);
      emit(
        updateState.copyWith(
          newPinCode: newPinCode,
        ),
      );
    } else if (updateState.confirmPinCode == null ||
        updateState.confirmPinCode!.length < 4) {
      List<int> confirmPinCode = List.from(updateState.confirmPinCode ?? []);
      confirmPinCode.add(event.number);
      emit(
        updateState.copyWith(
          confirmPinCode: confirmPinCode,
        ),
      );
    }
  }

  FutureOr<void> _setStatusHandler(
      ScreenLockSetStatusEvent event, Emitter<ScreenLockState> emit) {
    switch (event.status) {
      case ScreenLockStatus.create:
        emit(const ScreenLockCreateState());
      case ScreenLockStatus.check:
        emit(const ScreenLockCheckState());
      case ScreenLockStatus.update:
        emit(const ScreenLockUpdateState());
    }
  }

  FutureOr<void> _setErrorHandler(
      ScreenLockSetErrorEvent event, Emitter<ScreenLockState> emit) {
    switch (event.status) {
      case ScreenLockStatus.create:
        final createState = state as ScreenLockCreateState;
        emit(
          createState.copyWith(
            isCorrectPin: event.isCorrectPin,
            confirmPinCode: event.isCorrectPin ? null : [],
          ),
        );
      case ScreenLockStatus.check:
        final checkState = state as ScreenLockCheckState;
        emit(
          checkState.copyWith(
            isCorrectPin: event.isCorrectPin,
            pinCode: [],
            failedAttempts: event.isCorrectPin
                ? checkState.failedAttempts
                : checkState.failedAttempts + 1,
          ),
        );
      case ScreenLockStatus.update:
        final updateState = state as ScreenLockUpdateState;
        if (updateState.confirmPinCode?.isNotEmpty ?? false) {
          emit(
            updateState.copyWith(
              isCorrectPin: event.isCorrectPin,
              confirmPinCode: event.isCorrectPin ? null : [],
            ),
          );
        } else if (updateState.newPinCode?.isNotEmpty ?? false) {
          emit(
            updateState.copyWith(
              isCorrectPin: event.isCorrectPin,
              newPinCode: event.isCorrectPin ? null : [],
            ),
          );
        } else {
          emit(
            updateState.copyWith(
              isCorrectPin: event.isCorrectPin,
              oldPinCode: event.isCorrectPin ? null : [],
            ),
          );
        }
    }
  }

  FutureOr<void> _setBioMetricsHandler(
      ScreenLockSetBioMetrics event, Emitter<ScreenLockState> emit) async {
    final localSource = sl<LocalSource>();
    localSource.setBiometricsOn(event.isBioMetrics);
    if (state is ScreenLockCheckState) {
      final checkState = state as ScreenLockCheckState;
      emit(
        checkState.copyWith(
          isBiometricsEnabled: event.isBioMetrics,
        ),
      );
    } else if (state is ScreenLockCreateState) {
      final createState = state as ScreenLockCreateState;
      emit(
        createState.copyWith(
          isBiometricsEnabled: event.isBioMetrics,
        ),
      );
    }
  }
}
