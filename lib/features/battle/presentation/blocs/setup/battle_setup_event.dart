part of 'battle_setup_bloc.dart';

abstract class BattleSetupEvent extends Equatable {
  const BattleSetupEvent();

  @override
  List<Object?> get props => [];
}

class LoadBattleSetupEvent extends BattleSetupEvent {
  const LoadBattleSetupEvent();
}

class SelectGradeEvent extends BattleSetupEvent {
  final String grade;

  const SelectGradeEvent(this.grade);

  @override
  List<Object?> get props => [grade];
}

class ToggleSubjectEvent extends BattleSetupEvent {
  final int subjectId;

  const ToggleSubjectEvent(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

class ChangeQuestionCountEvent extends BattleSetupEvent {
  final int count;

  const ChangeQuestionCountEvent(this.count);

  @override
  List<Object?> get props => [count];
}

class ChangeSecondsPerQuestionEvent extends BattleSetupEvent {
  final int seconds;

  const ChangeSecondsPerQuestionEvent(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class ChangeJoinCodeEvent extends BattleSetupEvent {
  final String code;

  const ChangeJoinCodeEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class CreateBattleRoomEvent extends BattleSetupEvent {
  const CreateBattleRoomEvent();
}

class JoinBattleRoomEvent extends BattleSetupEvent {
  const JoinBattleRoomEvent();
}
