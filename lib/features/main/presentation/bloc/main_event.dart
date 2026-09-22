part of 'main_bloc.dart';

abstract class MainEvent extends Equatable {
  const MainEvent();
}

class MainInitialEvent extends MainEvent {
  const MainInitialEvent();

  @override
  List<Object?> get props => [];
}

class MainPageChangeEvent extends MainEvent {
  final MainPages page;

  const MainPageChangeEvent(this.page);

  @override
  List<Object?> get props => [page];
}

class MainSearchRoutesObserverEvent extends MainEvent {
  final String route;

  const MainSearchRoutesObserverEvent(this.route);

  @override
  List<Object?> get props => [route];
}
