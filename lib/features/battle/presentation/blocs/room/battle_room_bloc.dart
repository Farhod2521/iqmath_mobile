import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/battle/data/data_source/socket/battle_socket_service.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';

part 'battle_room_event.dart';

part 'battle_room_state.dart';

class BattleRoomBloc extends Bloc<BattleRoomEvent, BattleRoomState> {
  final BattleSocketService socketService;
  final LocalSource localSource;

  StreamSubscription? _eventsSubscription;
  StreamSubscription? _connectionSubscription;
  Timer? _tickTimer;
  Timer? _timeoutGraceTimer;

  BattleRoomBloc({
    required this.socketService,
    required this.localSource,
  }) : super(BattleRoomState.initial()) {
    on<ConnectToRoomEvent>(_onConnect);
    on<SocketMessageReceivedEvent>(_onSocketMessage);
    on<SocketConnectionChangedEvent>(_onSocketConnectionChanged);
    on<TimerTickEvent>(_onTimerTick);
    on<ToggleChoiceSelectionEvent>(_onToggleChoiceSelection);
    on<ChangeTextAnswerEvent>(_onChangeTextAnswer);
    on<ChangeCompositeAnswerEvent>(_onChangeCompositeAnswer);
    on<SubmitAnswerEvent>(_onSubmitAnswer);
    on<SkipQuestionEvent>(_onSkipQuestion);
    on<SendChatMessageEvent>(_onSendChatMessage);
  }

  FutureOr<void> _onConnect(
    ConnectToRoomEvent event,
    Emitter<BattleRoomState> emit,
  ) async {
    emit(state.copyWith(connectionStatus: BattleConnectionStatus.connecting));

    final rawToken = localSource.getAccessToken() ?? '';
    // Saqlangan token "Bearer <token>" ko'rinishida — WS uchun faqat
    // haqiqiy token qismi kerak.
    final token = rawToken.replaceFirst(RegExp(r'^Bearer\s+'), '');

    _eventsSubscription?.cancel();
    _connectionSubscription?.cancel();

    _eventsSubscription = socketService.events.listen((raw) {
      add(SocketMessageReceivedEvent(raw));
    });
    _connectionSubscription = socketService.connectionState.listen((connected) {
      add(SocketConnectionChangedEvent(connected));
    });

    socketService.connect(roomId: event.roomId, token: token);
  }

  FutureOr<void> _onSocketConnectionChanged(
    SocketConnectionChangedEvent event,
    Emitter<BattleRoomState> emit,
  ) {
    if (!event.connected &&
        state.connectionStatus != BattleConnectionStatus.finished &&
        state.connectionStatus != BattleConnectionStatus.voided) {
      emit(state.copyWith(connectionStatus: BattleConnectionStatus.connecting));
    }
  }

  FutureOr<void> _onSocketMessage(
    SocketMessageReceivedEvent event,
    Emitter<BattleRoomState> emit,
  ) {
    final eventName = event.raw['event']?.toString();
    final payload = event.raw['payload'];
    final payloadMap =
        payload is Map<String, dynamic> ? payload : <String, dynamic>{};

    switch (eventName) {
      case 'room_snapshot':
        _handleRoomSnapshot(payloadMap, emit);
        break;
      case 'opponent_joined':
        _handleOpponentJoined(payloadMap, emit);
        break;
      case 'battle_started':
        _handleBattleStarted(payloadMap, emit);
        break;
      case 'next_question':
        _handleNextQuestion(payloadMap, emit);
        break;
      case 'opponent_progress':
        _handleOpponentProgress(payloadMap, emit);
        break;
      case 'battle_finished':
        _handleBattleFinished(payloadMap, emit);
        break;
      case 'battle_voided':
        emit(state.copyWith(
          connectionStatus: BattleConnectionStatus.voided,
          voidReason: payloadMap['reason']?.toString(),
        ));
        _cancelTimers();
        break;
      case 'chat_message':
        _handleChatMessage(payloadMap, emit);
        break;
    }
  }

  void _handleRoomSnapshot(
    Map<String, dynamic> payload,
    Emitter<BattleRoomState> emit,
  ) {
    final room = BattleRoomModel.fromJson(payload);
    final status = _statusFromRoom(room.status);

    emit(state.copyWith(
      connectionStatus: status,
      room: room,
      currentQuestion: room.currentQuestion,
      remainingSeconds: room.secondsPerQuestion - room.questionSecondsElapsed,
    ));

    if (status == BattleConnectionStatus.active && room.currentQuestion != null) {
      _startQuestionTimer();
    }
  }

  void _handleOpponentJoined(
    Map<String, dynamic> payload,
    Emitter<BattleRoomState> emit,
  ) {
    final participant = payload['participant'] is Map<String, dynamic>
        ? BattleParticipantModel.fromJson(
            payload['participant'] as Map<String, dynamic>)
        : null;
    if (participant == null || state.room == null) return;

    final updatedParticipants = [...state.room!.participants, participant];
    emit(state.copyWith(
      room: _copyRoomWithParticipants(state.room!, updatedParticipants),
    ));
  }

  void _handleBattleStarted(
    Map<String, dynamic> payload,
    Emitter<BattleRoomState> emit,
  ) {
    final room = payload['room'] is Map<String, dynamic>
        ? BattleRoomModel.fromJson(payload['room'] as Map<String, dynamic>)
        : state.room;
    final question = payload['question'] is Map<String, dynamic>
        ? BattleQuestionModel.fromJson(
            payload['question'] as Map<String, dynamic>)
        : null;

    emit(state.copyWith(
      connectionStatus: BattleConnectionStatus.active,
      room: room,
      currentQuestion: question,
      remainingSeconds: room?.secondsPerQuestion ?? state.remainingSeconds,
      myAnswered: false,
      opponentAnswered: false,
      selectedChoiceIds: {},
      textAnswer: '',
      compositeAnswers: const [],
    ));
    _startQuestionTimer();
  }

  void _handleNextQuestion(
    Map<String, dynamic> payload,
    Emitter<BattleRoomState> emit,
  ) {
    final question = payload['question'] is Map<String, dynamic>
        ? BattleQuestionModel.fromJson(
            payload['question'] as Map<String, dynamic>)
        : null;

    // Server "question_index"/"current_question_index" maydonini yuborsa
    // o'shani ishonchli manba sifatida olamiz; bo'lmasa, savollar hamisha
    // ketma-ket kelgani uchun joriy indeksni 1ga oshiramiz — aks holda
    // progress ko'rsatkichi ("1/5") hech qachon yangilanmay qoladi.
    final serverIndex = payload['question_index'] ?? payload['current_question_index'];
    final nextIndex = serverIndex is num
        ? serverIndex.toInt()
        : (state.room?.currentQuestionIndex ?? 0) + 1;

    emit(state.copyWith(
      room: state.room == null
          ? null
          : _copyRoomWithIndex(state.room!, nextIndex, question),
      currentQuestion: question,
      remainingSeconds: state.room?.secondsPerQuestion ?? state.remainingSeconds,
      myAnswered: false,
      opponentAnswered: false,
      selectedChoiceIds: {},
      textAnswer: '',
      compositeAnswers: const [],
    ));
    _startQuestionTimer();
  }

  void _handleOpponentProgress(
    Map<String, dynamic> payload,
    Emitter<BattleRoomState> emit,
  ) {
    final participantId = payload['participant_id']?.toString();
    if (participantId == null || state.room == null) return;

    if (participantId == state.room!.me?.participantId) {
      emit(state.copyWith(myAnswered: true));
    } else {
      emit(state.copyWith(opponentAnswered: true));
    }
  }

  void _handleBattleFinished(
    Map<String, dynamic> payload,
    Emitter<BattleRoomState> emit,
  ) {
    _cancelTimers();
    emit(state.copyWith(
      connectionStatus: BattleConnectionStatus.finished,
      result: BattleFinishedResultModel.fromJson(payload),
    ));
  }

  void _handleChatMessage(
    Map<String, dynamic> payload,
    Emitter<BattleRoomState> emit,
  ) {
    final message = BattleChatMessageModel.fromJson(
      payload,
      selfParticipantId: state.room?.me?.participantId,
    );
    emit(state.copyWith(chatMessages: [...state.chatMessages, message]));
  }

  BattleConnectionStatus _statusFromRoom(String status) {
    switch (status) {
      case 'active':
        return BattleConnectionStatus.active;
      case 'finished':
        return BattleConnectionStatus.finished;
      case 'voided':
        return BattleConnectionStatus.voided;
      default:
        return BattleConnectionStatus.waiting;
    }
  }

  BattleRoomModel _copyRoomWithParticipants(
    BattleRoomModel room,
    List<BattleParticipantModel> participants,
  ) {
    return BattleRoomModel(
      status: room.status,
      currentQuestionIndex: room.currentQuestionIndex,
      currentQuestion: room.currentQuestion,
      questionSecondsElapsed: room.questionSecondsElapsed,
      secondsPerQuestion: room.secondsPerQuestion,
      questionCount: room.questionCount,
      grade: room.grade,
      chatEnabled: room.chatEnabled,
      subjects: room.subjects,
      participants: participants,
    );
  }

  BattleRoomModel _copyRoomWithIndex(
    BattleRoomModel room,
    int currentQuestionIndex,
    BattleQuestionModel? currentQuestion,
  ) {
    return BattleRoomModel(
      status: room.status,
      currentQuestionIndex: currentQuestionIndex,
      currentQuestion: currentQuestion ?? room.currentQuestion,
      questionSecondsElapsed: 0,
      secondsPerQuestion: room.secondsPerQuestion,
      questionCount: room.questionCount,
      grade: room.grade,
      chatEnabled: room.chatEnabled,
      subjects: room.subjects,
      participants: room.participants,
    );
  }

  // ---------------------------------------------------------------------
  // Timer — har soniyada kamayadi; 0 ga yetganda 2s grace davri kutib,
  // serverga timeout_check yuboradi (veb bilan bir xil xatti-harakat).
  // ---------------------------------------------------------------------
  void _startQuestionTimer() {
    _cancelTimers();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TimerTickEvent());
    });
  }

  void _cancelTimers() {
    _tickTimer?.cancel();
    _timeoutGraceTimer?.cancel();
  }

  FutureOr<void> _onTimerTick(
    TimerTickEvent event,
    Emitter<BattleRoomState> emit,
  ) {
    if (state.connectionStatus != BattleConnectionStatus.active) return null;
    final next = state.remainingSeconds - 1;
    emit(state.copyWith(remainingSeconds: next));

    if (next <= 0) {
      _tickTimer?.cancel();
      _timeoutGraceTimer?.cancel();
      _timeoutGraceTimer = Timer(const Duration(seconds: 2), () {
        final order = state.currentQuestion?.order;
        if (order != null) socketService.sendTimeoutCheck(order);
      });
    }
    return null;
  }

  FutureOr<void> _onToggleChoiceSelection(
    ToggleChoiceSelectionEvent event,
    Emitter<BattleRoomState> emit,
  ) {
    final question = state.currentQuestion?.question;
    if (question == null || state.myAnswered) return null;

    if (question.isMultiSelect) {
      final updated = Set<int>.from(state.selectedChoiceIds);
      updated.contains(event.choiceId)
          ? updated.remove(event.choiceId)
          : updated.add(event.choiceId);
      emit(state.copyWith(selectedChoiceIds: updated));
    } else {
      // Bitta tanlovli savol — darhol yuboriladi (veb bilan bir xil)
      emit(state.copyWith(selectedChoiceIds: {event.choiceId}));
      add(const SubmitAnswerEvent());
    }
    return null;
  }

  FutureOr<void> _onChangeTextAnswer(
    ChangeTextAnswerEvent event,
    Emitter<BattleRoomState> emit,
  ) {
    emit(state.copyWith(textAnswer: event.text));
  }

  FutureOr<void> _onChangeCompositeAnswer(
    ChangeCompositeAnswerEvent event,
    Emitter<BattleRoomState> emit,
  ) {
    final updated = [...state.compositeAnswers];
    while (updated.length <= event.index) {
      updated.add('');
    }
    updated[event.index] = event.value;
    emit(state.copyWith(compositeAnswers: updated));
  }

  FutureOr<void> _onSubmitAnswer(
    SubmitAnswerEvent event,
    Emitter<BattleRoomState> emit,
  ) {
    final question = state.currentQuestion;
    if (question == null || state.myAnswered) return null;

    final data = question.question;
    Map<String, dynamic> answerFields;

    switch (data.questionType) {
      case 'text':
        final locale = localSource.getLocale() ?? 'uz';
        answerFields = {
          locale == 'ru' ? 'answer_ru' : 'answer_uz': state.textAnswer,
        };
        break;
      case 'composite':
        answerFields = {'answers': state.compositeAnswers};
        break;
      default:
        answerFields = {'choices': state.selectedChoiceIds.toList()};
    }

    socketService.sendAnswer(
      questionOrder: question.order,
      answerFields: answerFields,
    );
    emit(state.copyWith(myAnswered: true));
    return null;
  }

  FutureOr<void> _onSkipQuestion(
    SkipQuestionEvent event,
    Emitter<BattleRoomState> emit,
  ) {
    final order = state.currentQuestion?.order;
    if (order == null || state.myAnswered) return null;
    socketService.sendSkip(order);
    emit(state.copyWith(myAnswered: true));
    return null;
  }

  FutureOr<void> _onSendChatMessage(
    SendChatMessageEvent event,
    Emitter<BattleRoomState> emit,
  ) {
    if (event.text.trim().isEmpty) return null;
    socketService.sendChat(event.text.trim());
    return null;
  }

  @override
  Future<void> close() {
    _cancelTimers();
    _eventsSubscription?.cancel();
    _connectionSubscription?.cancel();
    socketService.dispose();
    return super.close();
  }
}
