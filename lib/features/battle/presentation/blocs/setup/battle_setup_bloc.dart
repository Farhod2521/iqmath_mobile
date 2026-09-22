import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';
import 'package:my_flutter_template/features/battle/domain/usecases/battle_usecases.dart';

part 'battle_setup_event.dart';

part 'battle_setup_state.dart';

class BattleSetupBloc extends Bloc<BattleSetupEvent, BattleSetupState>
    with BaseBlocMixin {
  final GetBattleSubjectsUseCase getBattleSubjectsUseCase;
  final GetBattleGradeStatsUseCase getBattleGradeStatsUseCase;
  final GetBattleRatingUseCase getBattleRatingUseCase;
  final CreateBattleRoomUseCase createBattleRoomUseCase;
  final JoinBattleRoomUseCase joinBattleRoomUseCase;

  BattleSetupBloc({
    required this.getBattleSubjectsUseCase,
    required this.getBattleGradeStatsUseCase,
    required this.getBattleRatingUseCase,
    required this.createBattleRoomUseCase,
    required this.joinBattleRoomUseCase,
  }) : super(BattleSetupState.initial()) {
    on<LoadBattleSetupEvent>(_onLoad);
    on<SelectGradeEvent>(_onSelectGrade);
    on<ToggleSubjectEvent>(_onToggleSubject);
    on<ChangeQuestionCountEvent>(_onChangeQuestionCount);
    on<ChangeSecondsPerQuestionEvent>(_onChangeSecondsPerQuestion);
    on<ChangeJoinCodeEvent>(_onChangeJoinCode);
    on<CreateBattleRoomEvent>(_onCreateRoom);
    on<JoinBattleRoomEvent>(_onJoinRoom);
  }

  FutureOr<void> _onLoad(
    LoadBattleSetupEvent event,
    Emitter<BattleSetupState> emit,
  ) async {
    emit(state.copyWith(status: BattleSetupStatus.loading));

    final subjectsFuture = getBattleSubjectsUseCase(NoParams());
    final gradeStatsFuture = getBattleGradeStatsUseCase(NoParams());
    final ratingFuture = getBattleRatingUseCase(NoParams());

    final subjectsResult = await subjectsFuture;
    final gradeStatsResult = await gradeStatsFuture;
    final ratingResult = await ratingFuture;

    List<BattleSubjectModel>? subjects;
    List<BattleGradeStatModel>? gradeStats;
    BattleRatingModel? rating;
    ({String title, String message})? errorMessage;

    subjectsResult.fold(
      (error) => errorMessage = getErrorMessage(error),
      (data) => subjects = data,
    );
    gradeStatsResult.fold((error) => null, (data) => gradeStats = data);
    ratingResult.fold((error) => null, (data) => rating = data);

    emit(
      state.copyWith(
        status: subjects != null
            ? BattleSetupStatus.loaded
            : BattleSetupStatus.error,
        subjects: subjects ?? [],
        gradeStats: gradeStats ?? [],
        rating: rating,
        errorMessage: errorMessage,
      ),
    );
  }

  FutureOr<void> _onSelectGrade(
    SelectGradeEvent event,
    Emitter<BattleSetupState> emit,
  ) {
    final subjectsForGrade = state.subjects
        .where((s) => s.className == event.grade)
        .toList();
    emit(
      state.copyWith(
        selectedGrade: event.grade,
        // Bitta fan bo'lsa — avtomatik tanlanadi (veb bilan bir xil xatti-harakat)
        selectedSubjectIds: subjectsForGrade.length == 1
            ? {subjectsForGrade.first.id}
            : <int>{},
      ),
    );
  }

  FutureOr<void> _onToggleSubject(
    ToggleSubjectEvent event,
    Emitter<BattleSetupState> emit,
  ) {
    final updated = Set<int>.from(state.selectedSubjectIds);
    if (updated.contains(event.subjectId)) {
      updated.remove(event.subjectId);
    } else {
      updated.add(event.subjectId);
    }
    emit(state.copyWith(selectedSubjectIds: updated));
  }

  FutureOr<void> _onChangeQuestionCount(
    ChangeQuestionCountEvent event,
    Emitter<BattleSetupState> emit,
  ) {
    emit(state.copyWith(questionCount: event.count));
  }

  FutureOr<void> _onChangeSecondsPerQuestion(
    ChangeSecondsPerQuestionEvent event,
    Emitter<BattleSetupState> emit,
  ) {
    emit(state.copyWith(secondsPerQuestion: event.seconds));
  }

  FutureOr<void> _onChangeJoinCode(
    ChangeJoinCodeEvent event,
    Emitter<BattleSetupState> emit,
  ) {
    emit(state.copyWith(joinCode: event.code));
  }

  FutureOr<void> _onCreateRoom(
    CreateBattleRoomEvent event,
    Emitter<BattleSetupState> emit,
  ) async {
    if (state.selectedGrade == null || state.selectedSubjectIds.isEmpty) {
      return;
    }
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    // Veb ilovada "grade_id" nomlangan bo'lsa-da, aslida sinf raqamining
    // o'zi (masalan "7-sinf" uchun 7) yuboriladi — alohida Class/Grade
    // jadvali ID'si emas.
    final result = await createBattleRoomUseCase(
      CreateBattleRoomParams(
        gradeId: int.tryParse(state.selectedGrade ?? '') ?? 0,
        subjectIds: state.selectedSubjectIds.toList(),
        questionCount: state.questionCount,
        secondsPerQuestion: state.secondsPerQuestion,
      ),
    );

    result.fold(
      (error) => emit(
        state.copyWith(isSubmitting: false, errorMessage: getErrorMessage(error)),
      ),
      (roomId) => emit(state.copyWith(isSubmitting: false, readyRoomId: roomId)),
    );
  }

  FutureOr<void> _onJoinRoom(
    JoinBattleRoomEvent event,
    Emitter<BattleSetupState> emit,
  ) async {
    if (state.joinCode.trim().isEmpty) return;
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final result =
        await joinBattleRoomUseCase(state.joinCode.trim().toUpperCase());

    result.fold(
      (error) => emit(
        state.copyWith(isSubmitting: false, errorMessage: getErrorMessage(error)),
      ),
      (roomId) => emit(state.copyWith(isSubmitting: false, readyRoomId: roomId)),
    );
  }
}
