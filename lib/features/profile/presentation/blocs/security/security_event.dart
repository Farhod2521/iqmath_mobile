part of 'security_bloc.dart';

abstract class SecurityEvent extends Equatable {
  const SecurityEvent();
}

class SecurityDeleteUserEvent extends SecurityEvent {
  const SecurityDeleteUserEvent();

  @override
  List<Object> get props => [];
}
