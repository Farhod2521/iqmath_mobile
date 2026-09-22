part of 'battle_leaderboard_bloc.dart';

abstract class BattleLeaderboardEvent extends Equatable {
  const BattleLeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadBattleLeaderboardEvent extends BattleLeaderboardEvent {
  const LoadBattleLeaderboardEvent();
}
