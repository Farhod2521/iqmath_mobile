part of 'battle_history_bloc.dart';

abstract class BattleHistoryEvent extends Equatable {
  const BattleHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadBattleHistoryEvent extends BattleHistoryEvent {
  const LoadBattleHistoryEvent();
}
