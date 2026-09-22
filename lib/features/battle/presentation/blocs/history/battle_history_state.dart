part of 'battle_history_bloc.dart';

enum BattleHistoryStatus { initial, loading, loaded, error }

class BattleHistoryState extends Equatable {
  final BattleHistoryStatus status;
  final BattleHistoryResponseModel? history;
  final List<BattleEloHistoryPointModel> eloHistory;
  final ({String title, String message})? errorMessage;

  const BattleHistoryState({
    required this.status,
    required this.history,
    required this.eloHistory,
    required this.errorMessage,
  });

  factory BattleHistoryState.initial() => const BattleHistoryState(
        status: BattleHistoryStatus.initial,
        history: null,
        eloHistory: [],
        errorMessage: null,
      );

  BattleHistoryState copyWith({
    BattleHistoryStatus? status,
    BattleHistoryResponseModel? history,
    List<BattleEloHistoryPointModel>? eloHistory,
    ({String title, String message})? errorMessage,
  }) {
    return BattleHistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      eloHistory: eloHistory ?? this.eloHistory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, history, eloHistory, errorMessage];
}
