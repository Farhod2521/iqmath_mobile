import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/mixins/base_bloc_mixin.dart';
import 'package:my_flutter_template/core/usecase/usecase.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';
import 'package:my_flutter_template/features/battle/domain/usecases/battle_usecases.dart';

part 'battle_leaderboard_event.dart';

part 'battle_leaderboard_state.dart';

class BattleLeaderboardBloc
    extends Bloc<BattleLeaderboardEvent, BattleLeaderboardState>
    with BaseBlocMixin {
  final GetBattleLeaderboardUseCase getBattleLeaderboardUseCase;

  BattleLeaderboardBloc({required this.getBattleLeaderboardUseCase})
      : super(BattleLeaderboardState.initial()) {
    on<LoadBattleLeaderboardEvent>(_onLoad);
  }

  FutureOr<void> _onLoad(
    LoadBattleLeaderboardEvent event,
    Emitter<BattleLeaderboardState> emit,
  ) async {
    emit(state.copyWith(status: BattleLeaderboardStatus.loading));

    final result = await getBattleLeaderboardUseCase(NoParams());

    result.fold(
      (error) => emit(
        state.copyWith(
          status: BattleLeaderboardStatus.error,
          errorMessage: getErrorMessage(error),
        ),
      ),
      (data) => emit(
        state.copyWith(status: BattleLeaderboardStatus.loaded, entries: data),
      ),
    );
  }
}
