part of 'battle_room_bloc.dart';

abstract class BattleRoomEvent extends Equatable {
  const BattleRoomEvent();

  @override
  List<Object?> get props => [];
}

class ConnectToRoomEvent extends BattleRoomEvent {
  final int roomId;

  const ConnectToRoomEvent(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class SocketMessageReceivedEvent extends BattleRoomEvent {
  final Map<String, dynamic> raw;

  const SocketMessageReceivedEvent(this.raw);

  @override
  List<Object?> get props => [raw];
}

class SocketConnectionChangedEvent extends BattleRoomEvent {
  final bool connected;

  const SocketConnectionChangedEvent(this.connected);

  @override
  List<Object?> get props => [connected];
}

class TimerTickEvent extends BattleRoomEvent {
  const TimerTickEvent();
}

class ToggleChoiceSelectionEvent extends BattleRoomEvent {
  final int choiceId;

  const ToggleChoiceSelectionEvent(this.choiceId);

  @override
  List<Object?> get props => [choiceId];
}

class ChangeTextAnswerEvent extends BattleRoomEvent {
  final String text;

  const ChangeTextAnswerEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class ChangeCompositeAnswerEvent extends BattleRoomEvent {
  final int index;
  final String value;

  const ChangeCompositeAnswerEvent(this.index, this.value);

  @override
  List<Object?> get props => [index, value];
}

class SubmitAnswerEvent extends BattleRoomEvent {
  const SubmitAnswerEvent();
}

class SkipQuestionEvent extends BattleRoomEvent {
  const SkipQuestionEvent();
}

class SendChatMessageEvent extends BattleRoomEvent {
  final String text;

  const SendChatMessageEvent(this.text);

  @override
  List<Object?> get props => [text];
}
