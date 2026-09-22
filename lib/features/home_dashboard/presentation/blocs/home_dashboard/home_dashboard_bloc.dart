import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/home_dashboard_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/rating_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/student_score_model.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/study_stats_model.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_home_dashboard_usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_my_score_usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_rating_usecase.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_study_stats_usecase.dart';

part 'home_dashboard_event.dart';

part 'home_dashboard_state.dart';

class HomeDashboardBloc extends Bloc<HomeDashboardEvent, HomeDashboardState>
    with BaseBlocMixin {
  final GetHomeDashboardUseCase getHomeDashboardUseCase;
  final GetMyScoreUseCase getMyScoreUseCase;
  final GetRatingUseCase getRatingUseCase;
  final GetStudyStatsUseCase getStudyStatsUseCase;

  HomeDashboardBloc({
    required this.getHomeDashboardUseCase,
    required this.getMyScoreUseCase,
    required this.getRatingUseCase,
    required this.getStudyStatsUseCase,
  }) : super(HomeDashboardState.initial()) {
    on<LoadHomeDashboardEvent>(_onLoad);
    on<ChangeCalendarMonthEvent>(_onChangeCalendarMonth);
  }

  FutureOr<void> _onLoad(
    LoadHomeDashboardEvent event,
    Emitter<HomeDashboardState> emit,
  ) async {
    emit(state.copyWith(status: HomeDashboardStatus.loading));

    // Futures boshlab qo'yiladi, keyin ketma-ket await qilinadi —
    // shu bilan parallel bajarilishini saqlab qolamiz (turlari har xil
    // bo'lgani uchun Future.wait ishlatib bo'lmaydi).
    final dashboardFuture =
        getHomeDashboardUseCase(GetHomeDashboardParams(classId: event.classId));
    final scoreFuture = getMyScoreUseCase(NoParams());
    final ratingFuture = getRatingUseCase(NoParams());

    final dashboardResult = await dashboardFuture;
    final scoreResult = await scoreFuture;
    final ratingResult = await ratingFuture;

    HomeDashboardModel? dashboard;
    StudentScoreModel? score;
    RatingResponseModel? rating;
    ({String title, String message})? errorMessage;

    dashboardResult.fold(
      (error) => errorMessage = getErrorMessage(error),
      (data) => dashboard = data,
    );
    scoreResult.fold(
      (error) => null,
      (data) => score = data,
    );
    ratingResult.fold(
      (error) => null,
      (data) => rating = data,
    );

    emit(
      state.copyWith(
        status: dashboard != null
            ? HomeDashboardStatus.success
            : HomeDashboardStatus.error,
        dashboard: dashboard,
        score: score ?? state.score,
        rating: rating ?? state.rating,
        errorMessage: errorMessage,
      ),
    );

    add(ChangeCalendarMonthEvent(state.calendarMonth));
  }

  FutureOr<void> _onChangeCalendarMonth(
    ChangeCalendarMonthEvent event,
    Emitter<HomeDashboardState> emit,
  ) async {
    emit(state.copyWith(
      calendarMonth: event.month,
      calendarStatus: HomeDashboardStatus.loading,
    ));

    final firstDay = DateTime(event.month.year, event.month.month, 1);
    final lastDay = DateTime(event.month.year, event.month.month + 1, 0);
    final daysInMonth = lastDay.day;

    final result = await getStudyStatsUseCase(
      GetStudyStatsParams(
        dateFrom: _formatDate(firstDay),
        dateTo: _formatDate(lastDay),
        pageSize: daysInMonth,
      ),
    );

    result.fold(
      (error) => emit(state.copyWith(
        calendarStatus: HomeDashboardStatus.error,
      )),
      (data) => emit(state.copyWith(
        calendarStatus: HomeDashboardStatus.success,
        studyStats: data,
      )),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}
