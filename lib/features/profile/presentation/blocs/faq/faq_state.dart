part of 'faq_bloc.dart';

class FaqState extends Equatable {
  final FaqStatus status;
  final List<FaqsSubEntity>? faqs;
  final ({String title, String message})? errorMessage;

  const FaqState({
    this.status = FaqStatus.idle,
    this.faqs,
    this.errorMessage,
  });

  FaqState copyWith({
    FaqStatus? status,
    List<FaqsSubEntity>? faqs,
    ({String title, String message})? errorMessage,
  }) {
    return FaqState(
      status: status ?? FaqStatus.idle,
      faqs: faqs ?? this.faqs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, faqs];
}

enum FaqStatus { idle, loading, success, error }

extension FaqStatusX on FaqStatus {
  bool get isIdle => this == FaqStatus.idle;

  bool get isLoading => this == FaqStatus.loading;

  bool get isSuccess => this == FaqStatus.success;

  bool get isError => this == FaqStatus.error;
}
