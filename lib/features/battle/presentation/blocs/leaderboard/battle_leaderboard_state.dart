part of 'battle_leaderboard_bloc.dart';

enum BattleLeaderboardStatus { initial, loading, loaded, error }

class BattleLeaderboardState extends Equatable {
  final BattleLeaderboardStatus status;
  final List<BattleLeaderboardEntryModel> entries;
  final ({String title, String message})? errorMessage;

  const BattleLeaderboardState({
    required this.status,
    required this.entries,
    required this.errorMessage,
  });

  factory BattleLeaderboardState.initial() => const BattleLeaderboardState(
        status: BattleLeaderboardStatus.initial,
        entries: [],
        errorMessage: null,
      );

  BattleLeaderboardState copyWith({
    BattleLeaderboardStatus? status,
    List<BattleLeaderboardEntryModel>? entries,
    ({String title, String message})? errorMessage,
  }) {
    return BattleLeaderboardState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, entries, errorMessage];
}
