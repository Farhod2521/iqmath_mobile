part of 'battle_room_bloc.dart';

enum BattleConnectionStatus { connecting, waiting, active, finished, voided }

class BattleRoomState extends Equatable {
  final BattleConnectionStatus connectionStatus;
  final BattleRoomModel? room;
  final BattleQuestionModel? currentQuestion;
  final int remainingSeconds;
  final bool myAnswered;
  final bool opponentAnswered;
  final Set<int> selectedChoiceIds;
  final String textAnswer;
  final List<String> compositeAnswers;
  final List<BattleChatMessageModel> chatMessages;
  final BattleFinishedResultModel? result;
  final String? voidReason;

  const BattleRoomState({
    required this.connectionStatus,
    required this.room,
    required this.currentQuestion,
    required this.remainingSeconds,
    required this.myAnswered,
    required this.opponentAnswered,
    required this.selectedChoiceIds,
    required this.textAnswer,
    required this.compositeAnswers,
    required this.chatMessages,
    required this.result,
    required this.voidReason,
  });

  factory BattleRoomState.initial() => const BattleRoomState(
        connectionStatus: BattleConnectionStatus.connecting,
        room: null,
        currentQuestion: null,
        remainingSeconds: 0,
        myAnswered: false,
        opponentAnswered: false,
        selectedChoiceIds: {},
        textAnswer: '',
        compositeAnswers: [],
        chatMessages: [],
        result: null,
        voidReason: null,
      );

  BattleRoomState copyWith({
    BattleConnectionStatus? connectionStatus,
    BattleRoomModel? room,
    BattleQuestionModel? currentQuestion,
    int? remainingSeconds,
    bool? myAnswered,
    bool? opponentAnswered,
    Set<int>? selectedChoiceIds,
    String? textAnswer,
    List<String>? compositeAnswers,
    List<BattleChatMessageModel>? chatMessages,
    BattleFinishedResultModel? result,
    String? voidReason,
  }) {
    return BattleRoomState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      room: room ?? this.room,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      myAnswered: myAnswered ?? this.myAnswered,
      opponentAnswered: opponentAnswered ?? this.opponentAnswered,
      selectedChoiceIds: selectedChoiceIds ?? this.selectedChoiceIds,
      textAnswer: textAnswer ?? this.textAnswer,
      compositeAnswers: compositeAnswers ?? this.compositeAnswers,
      chatMessages: chatMessages ?? this.chatMessages,
      result: result ?? this.result,
      voidReason: voidReason ?? this.voidReason,
    );
  }

  @override
  List<Object?> get props => [
        connectionStatus,
        room,
        currentQuestion,
        remainingSeconds,
        myAnswered,
        opponentAnswered,
        selectedChoiceIds,
        textAnswer,
        compositeAnswers,
        chatMessages,
        result,
        voidReason,
      ];
}
