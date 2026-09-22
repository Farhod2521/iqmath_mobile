part of 'faq_bloc.dart';

abstract class FaqEvent extends Equatable {
  const FaqEvent();
}

class FaqInitialEvent extends FaqEvent {
  const FaqInitialEvent();

  @override
  List<Object?> get props => [];
}
