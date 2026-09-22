import 'package:equatable/equatable.dart';

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

class CacheFailure extends Failure {
  final String message;
  final String title;

  CacheFailure({required this.message, required this.title});

  @override
  List<Object?> get props => [message, title];
}
