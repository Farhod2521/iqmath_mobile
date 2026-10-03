import 'package:equatable/equatable.dart';

import '../device/device_model.dart';

abstract class Failure extends Equatable {}

class ServerFailure extends Failure {
  final String message;
  final String title;

  ServerFailure({required this.message, required this.title});

  @override
  List<Object?> get props => [message, title];
}

class NoInternetFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class DeviceLimitFailure extends Failure {
  final DeviceLimitInfo info;

  DeviceLimitFailure(this.info);

  @override
  List<Object?> get props => [info];
}

class CacheFailure extends Failure {
  final String message;
  final String title;

  CacheFailure({required this.message, required this.title});

  @override
  List<Object?> get props => [message, title];
}
