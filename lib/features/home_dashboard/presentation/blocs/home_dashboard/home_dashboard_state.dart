part of 'home_dashboard_bloc.dart';

enum HomeDashboardStatus { initial, loading, success, error }

class HomeDashboardState extends Equatable {
  final HomeDashboardStatus status;
  final HomeDashboardModel? dashboard;
  final StudentScoreModel? score;
  final RatingResponseModel? rating;
  final ({String title, String message})? errorMessage;

  final DateTime calendarMonth;
  final HomeDashboardStatus calendarStatus;
  final StudyStatsResponseModel? studyStats;

  const HomeDashboardState({
    required this.status,
    required this.dashboard,
    required this.score,
    required this.rating,
    required this.errorMessage,
    required this.calendarMonth,
    required this.calendarStatus,
    required this.studyStats,
  });

  factory HomeDashboardState.initial() {
    final now = DateTime.now();
    return HomeDashboardState(
      status: HomeDashboardStatus.initial,
      dashboard: null,
      score: null,
      rating: null,
      errorMessage: null,
      calendarMonth: DateTime(now.year, now.month, 1),
      calendarStatus: HomeDashboardStatus.initial,
      studyStats: null,
    );
  }

  HomeDashboardState copyWith({
    HomeDashboardStatus? status,
    HomeDashboardModel? dashboard,
    StudentScoreModel? score,
    RatingResponseModel? rating,
    ({String title, String message})? errorMessage,
    DateTime? calendarMonth,
    HomeDashboardStatus? calendarStatus,
    StudyStatsResponseModel? studyStats,
  }) {
    return HomeDashboardState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      score: score ?? this.score,
      rating: rating ?? this.rating,
      errorMessage: errorMessage ?? this.errorMessage,
      calendarMonth: calendarMonth ?? this.calendarMonth,
      calendarStatus: calendarStatus ?? this.calendarStatus,
      studyStats: studyStats ?? this.studyStats,
    );
  }

  @override
  List<Object?> get props => [
        status,
        dashboard,
        score,
        rating,
        errorMessage,
        calendarMonth,
        calendarStatus,
        studyStats,
      ];
}
