part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
}

class NotificationInitializeEvent extends NotificationEvent {
  const NotificationInitializeEvent();

  @override
  List<Object> get props => [];
}
