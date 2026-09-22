import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notification_event.dart';

part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationState()) {
    on<NotificationEvent>(_initializeHandler);
  }

  FutureOr<void> _initializeHandler(
      NotificationEvent event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    await Future.delayed(const Duration(seconds: 2));
    emit(
      state.copyWith(
        notificationItems: notificationItems,
        status: NotificationStatus.success,
      ),
    );
  }
}
