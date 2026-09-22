import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';
import 'package:my_flutter_template/features/battle/domain/usecases/battle_usecases.dart';

part 'battle_history_event.dart';

part 'battle_history_state.dart';

class BattleHistoryBloc extends Bloc<BattleHistoryEvent, BattleHistoryState>
    with BaseBlocMixin {
  final GetBattleHistoryUseCase getBattleHistoryUseCase;
  final GetBattleEloHistoryUseCase getBattleEloHistoryUseCase;

  BattleHistoryBloc({
    required this.getBattleHistoryUseCase,
    required this.getBattleEloHistoryUseCase,
  }) : super(BattleHistoryState.initial()) {
    on<LoadBattleHistoryEvent>(_onLoad);
  }

  FutureOr<void> _onLoad(
    LoadBattleHistoryEvent event,
    Emitter<BattleHistoryState> emit,
  ) async {
    emit(state.copyWith(status: BattleHistoryStatus.loading));

    final historyResult = await getBattleHistoryUseCase(NoParams());
    final eloResult = await getBattleEloHistoryUseCase(NoParams());

    BattleHistoryResponseModel? history;
    List<BattleEloHistoryPointModel> eloHistory = [];
    ({String title, String message})? errorMessage;

    historyResult.fold(
      (error) => errorMessage = getErrorMessage(error),
      (data) => history = data,
    );
    eloResult.fold((error) => null, (data) => eloHistory = data);

    emit(
      state.copyWith(
        status: history != null
            ? BattleHistoryStatus.loaded
            : BattleHistoryStatus.error,
        history: history,
        eloHistory: eloHistory,
        errorMessage: errorMessage,
      ),
    );
  }
}
