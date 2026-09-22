part of 'home_dashboard_bloc.dart';

abstract class HomeDashboardEvent extends Equatable {
  const HomeDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDashboardEvent extends HomeDashboardEvent {
  final int? classId;

  const LoadHomeDashboardEvent({this.classId});

  @override
  List<Object?> get props => [classId];
}

class ChangeCalendarMonthEvent extends HomeDashboardEvent {
  final DateTime month;

  const ChangeCalendarMonthEvent(this.month);

  @override
  List<Object?> get props => [month];
}
