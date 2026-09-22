part of 'security_bloc.dart';

class SecurityState extends Equatable {
  final SecurityStatus status;
  final ({String title, String message})? errorMessage;

  const SecurityState({
    this.status = SecurityStatus.idle,
    this.errorMessage,
  });

  SecurityState copyWith({
    SecurityStatus? status,
    ({String title, String message})? errorMessage,
  }) {
    return SecurityState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

enum SecurityStatus {
  idle,
  loading,
  success,
  error,
}

extension SecurityStatusX on SecurityStatus {
  bool get isIdle => this == SecurityStatus.idle;

  bool get isLoading => this == SecurityStatus.loading;

  bool get isSuccess => this == SecurityStatus.success;

  bool get isError => this == SecurityStatus.error;
}
