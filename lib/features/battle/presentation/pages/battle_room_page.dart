import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/battle/data/data_source/socket/battle_socket_service.dart';
import 'package:my_flutter_template/features/battle/data/models/battle_models.dart';
import 'package:my_flutter_template/features/battle/presentation/blocs/room/battle_room_bloc.dart';
import 'package:my_flutter_template/features/battle/presentation/page_args/battle_room_page_args.dart';
import 'package:my_flutter_template/features/battle/presentation/widgets/battle_player_avatar.dart';
import 'package:my_flutter_template/features/battle/presentation/widgets/battle_rich_text.dart';
import 'package:my_flutter_template/features/battle/presentation/widgets/battle_theme.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/name_routes.dart';

const String _kWinBg = 'assets/images/win_battle.png';
const String _kLoseBg = 'assets/images/lose_battle.png';

class BattleRoomPage extends StatelessWidget {
  final BattleRoomPageArgs args;

  const BattleRoomPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BattleRoomBloc(
        socketService: sl<BattleSocketService>(),
        localSource: sl<LocalSource>(),
      )..add(ConnectToRoomEvent(args.roomId)),
      child: const _BattleRoomView(),
    );
  }
}

class _BattleRoomView extends StatefulWidget {
  const _BattleRoomView();

  @override
  State<_BattleRoomView> createState() => _BattleRoomViewState();
}

class _BattleRoomViewState extends State<_BattleRoomView> {
  final _chatController = TextEditingController();
  bool _chatOpen = false;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return PopScope(
          canPop: true,
          child: Scaffold(
            backgroundColor: BattleColors.background,
            body: SafeArea(
              child: BlocBuilder<BattleRoomBloc, BattleRoomState>(
                builder: (context, state) {
                  switch (state.connectionStatus) {
                    case BattleConnectionStatus.connecting:
                      return _connectingView(locale);
                    case BattleConnectionStatus.waiting:
                      return _searchingView(context, state, locale);
                    case BattleConnectionStatus.active:
                      return _arenaView(context, state, locale);
                    case BattleConnectionStatus.finished:
                      return _resultView(context, state, locale);
                    case BattleConnectionStatus.voided:
                      return _voidedView(context, state, locale);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  Widget _connectingView(String locale) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: BattleColors.primary),
          const SizedBox(height: 16),
          Text(
            locale == 'ru' ? 'Подключение...' : 'Ulanmoqda...',
            style: const TextStyle(color: BattleColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Raqib qidirilmoqda
  // ---------------------------------------------------------------------
  Widget _searchingView(
      BuildContext context, BattleRoomState state, String locale) {
    return Column(
      children: [
        _closeBar(context, locale),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _pulsingVsBadge(),
                const SizedBox(height: 24),
                Text(
                  locale == 'ru' ? 'Поиск соперника...' : 'Raqib qidirilmoqda...',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: BattleColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                if (state.room != null)
                  Text(
                    state.room!.subjects.join(', '),
                    style: const TextStyle(fontSize: 12.5, color: BattleColors.muted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pulsingVsBadge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [BattleColors.primary, BattleColors.purple, BattleColors.rose],
          ),
        ),
        child: const Text(
          'VS',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ),
    );
  }

  Widget _closeBar(BuildContext context, String locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          if (locale.isNotEmpty) const SizedBox.shrink(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Faol o'yin maydoni
  // ---------------------------------------------------------------------
  Widget _arenaView(
      BuildContext context, BattleRoomState state, String locale) {
    final room = state.room;
    final question = state.currentQuestion;

    return Column(
      children: [
        _vsHeader(context, state, locale),
        if (question != null)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: _questionCard(context, state, question, locale),
            ),
          )
        else
          const Expanded(child: Center(child: CircularProgressIndicator())),
        if (room?.chatEnabled == true) _chatToggleBar(context, state, locale),
        if (_chatOpen && room?.chatEnabled == true)
          _chatPanel(context, state, locale),
      ],
    );
  }

  Widget _vsHeader(
      BuildContext context, BattleRoomState state, String locale) {
    final me = state.room?.me;
    final opponent = state.room?.opponent;
    final total = state.room?.questionCount ?? 0;
    final index = (state.room?.currentQuestionIndex ?? 0) + 1;
    final danger = state.remainingSeconds <= 10;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: BattleColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _playerChip(me?.name ?? '', me?.level, alignEnd: false),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: danger
                            ? const Color(0xFFFFF0F0)
                            : BattleColors.primary.withOpacity(0.08),
                        border: Border.all(
                          color: danger ? const Color(0xFFE5484D) : BattleColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${state.remainingSeconds}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: danger ? const Color(0xFFE5484D) : BattleColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$index/$total',
                      style: const TextStyle(fontSize: 10.5, color: BattleColors.muted),
                    ),
                  ],
                ),
              ),
              _playerChip(opponent?.name ?? '', opponent?.level, alignEnd: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playerChip(String name, int? level, {required bool alignEnd}) {
    final children = [
      BattlePlayerAvatar(name: name, level: level, size: 40),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: BattleColors.ink),
        ),
      ),
    ];
    return Expanded(
      child: Row(
        mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: alignEnd ? children.reversed.toList() : children,
      ),
    );
  }

  Widget _questionCard(
    BuildContext context,
    BattleRoomState state,
    BattleQuestionModel question,
    String locale,
  ) {
    final data = question.question;
    final bloc = context.read<BattleRoomBloc>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E1A4C).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BattleRichText(
            data.text(locale),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 18),
          if (data.questionType == 'text')
            _textAnswerInput(context, state, locale)
          else if (data.questionType == 'composite')
            ..._compositeInputs(context, state, data, locale)
          else
            ..._choiceOptions(context, state, data, locale),
          const SizedBox(height: 16),
          if (state.myAnswered)
            _waitingForOpponentBanner(state, locale)
          else if (data.questionType == 'text' ||
              data.questionType == 'composite' ||
              data.isMultiSelect)
            _canSubmit(state, data)
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => bloc.add(const SubmitAnswerEvent()),
                      borderRadius: BorderRadius.circular(14),
                      child: Ink(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: BattleColors.actionGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            locale == 'ru' ? 'Отправить ответ' : 'Javobni yuborish',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EEFB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        locale == 'ru' ? 'Отправить ответ' : 'Javobni yuborish',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: BattleColors.muted),
                      ),
                    ),
                  ),
        ],
      ),
    );
  }

  bool _canSubmit(BattleRoomState state, BattleQuestionDataModel data) {
    if (data.questionType == 'text') return state.textAnswer.trim().isNotEmpty;
    if (data.questionType == 'composite') {
      return state.compositeAnswers.length >= data.subQuestions.length &&
          state.compositeAnswers.every((a) => a.trim().isNotEmpty);
    }
    if (data.isMultiSelect) return state.selectedChoiceIds.isNotEmpty;
    return true;
  }

  List<Widget> _choiceOptions(
    BuildContext context,
    BattleRoomState state,
    BattleQuestionDataModel data,
    String locale,
  ) {
    final bloc = context.read<BattleRoomBloc>();
    return data.choices.asMap().entries.map((entry) {
      final index = entry.key;
      final choice = entry.value;
      final selected = state.selectedChoiceIds.contains(choice.id);
      final accent = BattleColors.choiceColors[index % BattleColors.choiceColors.length];

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: state.myAnswered
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  bloc.add(ToggleChoiceSelectionEvent(choice.id));
                },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? accent.withOpacity(0.08) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? accent : Colors.transparent, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? accent : accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    choice.letter,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: selected ? Colors.white : accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BattleRichText(choice.text(locale), fontSize: 13.5),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _textAnswerInput(
      BuildContext context, BattleRoomState state, String locale) {
    final bloc = context.read<BattleRoomBloc>();
    return TextField(
      enabled: !state.myAnswered,
      onChanged: (v) => bloc.add(ChangeTextAnswerEvent(v)),
      decoration: InputDecoration(
        hintText: locale == 'ru' ? 'Ваш ответ' : 'Javobingiz',
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  List<Widget> _compositeInputs(
    BuildContext context,
    BattleRoomState state,
    BattleQuestionDataModel data,
    String locale,
  ) {
    final bloc = context.read<BattleRoomBloc>();
    return data.subQuestions.asMap().entries.map((entry) {
      final index = entry.key;
      final sub = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BattleRichText(sub.text(locale), fontSize: 13, color: BattleColors.muted),
            const SizedBox(height: 6),
            TextField(
              enabled: !state.myAnswered,
              onChanged: (v) => bloc.add(ChangeCompositeAnswerEvent(index, v)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _waitingForOpponentBanner(BattleRoomState state, String locale) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.opponentAnswered
                  ? (locale == 'ru' ? 'Переход к следующему вопросу...' : 'Keyingi savolga o\'tilmoqda...')
                  : (locale == 'ru'
                      ? 'Ожидаем ответа соперника...'
                      : 'Raqib javobini kutmoqdamiz...'),
              style: const TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------
  Widget _chatToggleBar(
      BuildContext context, BattleRoomState state, String locale) {
    return InkWell(
      onTap: () => setState(() => _chatOpen = !_chatOpen),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: BattleColors.border)),
        ),
        child: Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: BattleColors.primary),
            const SizedBox(width: 6),
            Text(
              locale == 'ru' ? 'Чат' : 'Chat',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: BattleColors.ink),
            ),
            const Spacer(),
            Icon(_chatOpen ? Icons.expand_more_rounded : Icons.expand_less_rounded,
                size: 18, color: BattleColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _chatPanel(
      BuildContext context, BattleRoomState state, String locale) {
    final bloc = context.read<BattleRoomBloc>();
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BattleColors.border)),
      ),
      child: Column(
        children: [
          Expanded(
            child: state.chatMessages.isEmpty
                ? Center(
                    child: Text(
                      locale == 'ru' ? 'Пока нет сообщений' : 'Hozircha xabar yo\'q',
                      style: const TextStyle(fontSize: 11.5, color: BattleColors.muted),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: state.chatMessages.length,
                    itemBuilder: (context, index) {
                      final message =
                          state.chatMessages[state.chatMessages.length - 1 - index];
                      return Align(
                        alignment: message.isSelf
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          constraints: const BoxConstraints(maxWidth: 240),
                          decoration: BoxDecoration(
                            color: message.isSelf
                                ? BattleColors.primary
                                : const Color(0xFFF3F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: message.isSelf ? Colors.white : BattleColors.ink,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: locale == 'ru' ? 'Сообщение...' : 'Xabar...',
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                    ),
                    onSubmitted: (value) {
                      bloc.add(SendChatMessageEvent(value));
                      _chatController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    bloc.add(SendChatMessageEvent(_chatController.text));
                    _chatController.clear();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: BattleColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Natija
  // ---------------------------------------------------------------------
  Widget _resultView(
      BuildContext context, BattleRoomState state, String locale) {
    final results = state.result?.results ?? const [];
    final myId = state.room?.me?.participantId;
    var me = results.where((r) => r.participantId == myId).firstOrNull;
    var opponent = results.where((r) => r.participantId != myId).firstOrNull;

    // Agar participant_id mos kelmasa (masalan server "battle_finished"
    // xabarida boshqa ID sxemasidan foydalansa), ekran butunlay bo'sh
    // qolib ketmasin — ro'yxatdagi birinchi natijani "men" deb olamiz.
    if (me == null && results.isNotEmpty) {
      me = results.first;
      opponent = results.length > 1 ? results[1] : null;
    }

    final isWin = me?.result == 'win';
    final isDraw = me?.result == 'draw';
    final isLoss = me != null && !isWin && !isDraw;
    final bgImage = isLoss ? _kLoseBg : _kWinBg;

    final title = me == null
        ? ''
        : isWin
            ? (locale == 'ru' ? 'Победа!' : "G'alaba!")
            : isDraw
                ? (locale == 'ru' ? 'Ничья' : 'Durrang')
                : (locale == 'ru' ? 'Поражение' : "Mag'lubiyat");

    final subtitle = isWin
        ? (locale == 'ru'
            ? 'Отличный результат! Продолжайте!'
            : 'Ajoyib natija! Davom eting!')
        : isDraw
            ? (locale == 'ru'
                ? 'Близкая игра! Попробуйте ещё раз!'
                : "Yaqin o'yin edi! Yana urinib ko'ring!")
            : (locale == 'ru'
                ? 'Будьте настойчивы, продолжайте!'
                : "Qat'iyatli bo'lib, davom et!");

    final tip = isWin
        ? (locale == 'ru'
            ? 'Отличная работа! Каждая игра приближает вас к новым знаниям!'
            : "Zo'r ishladingiz! Har bir o'yin sizni yangi bilim sari yaqinlashtiradi!")
        : isDraw
            ? (locale == 'ru'
                ? 'Ничья — тоже опыт! Попробуйте снова.'
                : "Durrang ham tajriba! Yana urinib ko'ring.")
            : (locale == 'ru'
                ? 'Каждое поражение — шаг к новым знаниям!'
                : "Har bir mag'lubiyat — bu yangi bilim sari qadam!");

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(bgImage, fit: BoxFit.cover),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [_resultCloseButton(context)],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: BattleColors.ink,
                            ),
                          ),
                          if (me != null) ...[
                            const SizedBox(height: 14),
                            _scorePill(me, opponent, locale),
                          ],
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: BattleColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (me != null) ...[
                            const SizedBox(height: 14),
                            _eloResultCard(me, locale),
                          ],
                          const SizedBox(height: 26),
                          _resultPrimaryButton(
                            icon: Icons.refresh_rounded,
                            label: locale == 'ru' ? 'Играть снова' : "Yana o'ynash",
                            onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                                Routes.battle, (r) => false),
                          ),
                          const SizedBox(height: 12),
                          _resultOutlinedButton(
                            icon: Icons.leaderboard_rounded,
                            label: locale == 'ru' ? 'Рейтинг' : 'Reytingga o\'tish',
                            onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                                Routes.battleLeaderboard,
                                (r) => r.settings.name == Routes.battle),
                          ),
                          const SizedBox(height: 18),
                          _resultTipBanner(tip),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resultCloseButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.battle, (r) => false);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.close_rounded, size: 20, color: BattleColors.ink),
        ),
      ),
    );
  }

  Widget _scorePill(
      BattleResultEntryModel me, BattleResultEntryModel? opponent, String locale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 14.5, color: BattleColors.muted),
          children: [
            TextSpan(text: '${locale == 'ru' ? 'Счёт' : 'Hisob'}: '),
            TextSpan(
              text: '${me.score} – ${opponent?.score ?? 0}',
              style: const TextStyle(
                color: BattleColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: BattleColors.actionGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: BattleColors.actionGradient.last.withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              Expanded(
                child: Center(
                  child: Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultOutlinedButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: BattleColors.ink,
          side: const BorderSide(color: Color(0xFFE5E9F5)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: BattleColors.ink),
            Expanded(
              child: Center(
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, color: BattleColors.ink)),
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18, color: BattleColors.ink),
          ],
        ),
      ),
    );
  }

  Widget _resultTipBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: BattleColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BattleColors.primary.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, size: 16, color: BattleColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: BattleColors.muted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eloResultCard(BattleResultEntryModel me, String locale) {
    if (me.stillCalibrating) {
      return Text(
        locale == 'ru'
            ? 'Матч ${me.matchesPlayed}/${me.placementMatchesTotal} квалификации'
            : "${me.matchesPlayed}/${me.placementMatchesTotal}-saralash o'yini",
        style: const TextStyle(fontSize: 12.5, color: BattleColors.muted),
      );
    }
    if (me.isPlacementReveal) {
      return Column(
        children: [
          Text(
            locale == 'ru' ? 'Ваш уровень определён!' : 'Darajangiz aniqlandi!',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text('${me.eloAfter} ELO • ${locale == 'ru' ? 'Уровень' : 'Daraja'} ${me.level}',
              style: const TextStyle(fontSize: 12.5, color: BattleColors.muted)),
        ],
      );
    }
    final positive = me.eloChange > 0;
    final changeColor = positive
        ? BattleColors.historyWin
        : me.eloChange < 0
            ? BattleColors.historyLoss
            : BattleColors.muted;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${me.eloBefore}', style: const TextStyle(fontSize: 13, color: BattleColors.muted)),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, size: 14, color: BattleColors.muted),
        const SizedBox(width: 8),
        Text('${me.eloAfter}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Text(
          '${positive ? '+' : ''}${me.eloChange}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: changeColor),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Bekor qilingan o'yin
  // ---------------------------------------------------------------------
  Widget _voidedView(
      BuildContext context, BattleRoomState state, String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 38, color: BattleColors.muted),
            ),
            const SizedBox(height: 16),
            Text(
              locale == 'ru' ? 'Матч отменён' : 'O\'yin bekor qilindi',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              locale == 'ru'
                  ? 'Результат не будет засчитан'
                  : 'Natija hisobga olinmaydi',
              style: const TextStyle(fontSize: 12.5, color: BattleColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.battle, (r) => false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BattleColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(locale == 'ru' ? 'Играть снова' : 'Yana o\'ynash',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
