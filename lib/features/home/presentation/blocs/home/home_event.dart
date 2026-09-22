part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomeGetProductsEvent extends HomeEvent {
  final int? limit;
  final int? skip;

  const HomeGetProductsEvent({
    this.limit,
    this.skip,
  });

  @override
  List<Object?> get props => [limit, skip];
}
