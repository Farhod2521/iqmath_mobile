import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/features/battle/domain/usecases/battle_usecases.dart';
import 'package:my_flutter_template/features/battle/presentation/blocs/setup/battle_setup_bloc.dart';
import 'package:my_flutter_template/features/battle/presentation/page_args/battle_room_page_args.dart';
import 'package:my_flutter_template/features/battle/presentation/widgets/battle_level_badge.dart';
import 'package:my_flutter_template/features/battle/presentation/widgets/battle_theme.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/name_routes.dart';

class BattleLandingPage extends StatelessWidget {
  const BattleLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BattleSetupBloc(
        getBattleSubjectsUseCase: sl<GetBattleSubjectsUseCase>(),
        getBattleGradeStatsUseCase: sl<GetBattleGradeStatsUseCase>(),
        getBattleRatingUseCase: sl<GetBattleRatingUseCase>(),
        createBattleRoomUseCase: sl<CreateBattleRoomUseCase>(),
        joinBattleRoomUseCase: sl<JoinBattleRoomUseCase>(),
      )..add(const LoadBattleSetupEvent()),
      child: const _BattleLandingView(),
    );
  }
}

class _BattleLandingView extends StatefulWidget {
  const _BattleLandingView();

  @override
  State<_BattleLandingView> createState() => _BattleLandingViewState();
}

class _BattleLandingViewState extends State<_BattleLandingView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return BlocConsumer<BattleSetupBloc, BattleSetupState>(
          listenWhen: (previous, current) =>
              previous.readyRoomId != current.readyRoomId &&
              current.readyRoomId != null,
          listener: (context, state) {
            Navigator.of(context).pushReplacementNamed(
              Routes.battleRoom,
              arguments: BattleRoomPageArgs(roomId: state.readyRoomId!),
            );
          },
          builder: (context, state) {
            return Scaffold(
              backgroundColor: BattleColors.background,
              appBar: AppBar(
                backgroundColor: BattleColors.background,
                elevation: 0,
                foregroundColor: BattleColors.ink,
                title: Text(locale == 'ru' ? 'Battle' : 'Battle'),
                actions: [
                  IconButton(
                    tooltip: locale == 'ru' ? 'Рейтинг' : 'Reyting',
                    icon: const Icon(Icons.emoji_events_rounded),
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.battleLeaderboard),
                  ),
                  IconButton(
                    tooltip: locale == 'ru' ? 'История' : 'Tarix',
                    icon: const Icon(Icons.history_rounded),
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.battleHistory),
                  ),
                ],
              ),
              body: state.status == BattleSetupStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<BattleSetupBloc>()
                            .add(const LoadBattleSetupEvent());
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        children: [
                          if (state.errorMessage != null)
                            _errorBanner(state.errorMessage!.message),
                          _ratingWidget(state, locale),
                          const SizedBox(height: 14),
                          _statsRow(state, locale),
                          const SizedBox(height: 18),
                          _setupCard(context, state, locale),
                          const SizedBox(height: 18),
                          _rulesCard(locale),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        border: Border.all(color: const Color(0xFFFFD9D9)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE5484D), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: Color(0xFFE5484D), fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Reyting bloki
  // ---------------------------------------------------------------------
  Widget _ratingWidget(BattleSetupState state, String locale) {
    final rating = state.rating;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BattleColors.primary, BattleColors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: BattleColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: rating == null
          ? const SizedBox(
              height: 70,
              child: Center(
                  child: CircularProgressIndicator(color: Colors.white)))
          : rating.isInPlacement
              ? _placementProgress(rating, locale)
              : _ratingDetails(rating, locale),
    );
  }

  Widget _ratingDetails(rating, String locale) {
    final progress = rating.levelProgress.pctToNext;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            BattleLevelBadge(level: rating.level, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                    Text(
                      ' ${rating.elo}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  locale == 'ru' ? 'ELO рейтинг' : 'ELO reyting',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            _wldChip(rating.wins, rating.losses, rating.draws),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (progress / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            locale == 'ru'
                ? 'До следующего уровня: $progress%'
                : "Keyingi darajagacha: $progress%",
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _placementProgress(rating, String locale) {
    final total = rating.matchesPlayed + rating.matchesLeftForPlacement;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'ru' ? 'Определение уровня' : 'Daraja aniqlanmoqda',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          locale == 'ru'
              ? '${rating.matchesPlayed}/$total квалификационных матчей'
              : "${rating.matchesPlayed}/$total saralash o'yini",
          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(total.clamp(1, 10), (i) {
            final done = i < rating.matchesPlayed;
            return Expanded(
              child: Container(
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: done ? Colors.white : Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _wldChip(int wins, int losses, int draws) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$wins/$losses/$draws',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Statistika qatorlari
  // ---------------------------------------------------------------------
  Widget _statsRow(BattleSetupState state, String locale) {
    final rating = state.rating;
    final total = rating?.totalMatches ?? 0;
    final winRate = rating?.winRate ?? 0;
    final streak = rating?.winStreak ?? 0;

    final items = [
      (
        Icons.sports_kabaddi_rounded,
        locale == 'ru' ? 'Матчи' : "O'yinlar",
        '$total'
      ),
      (
        Icons.percent_rounded,
        locale == 'ru' ? 'Победы' : "G'alaba %",
        '${winRate.round()}%'
      ),
      (
        Icons.local_fire_department_rounded,
        locale == 'ru' ? 'Серия побед' : 'Ketma-ket',
        '$streak'
      ),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0E1A4C).withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(item.$1, size: 20, color: BattleColors.primary),
                    const SizedBox(height: 6),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: BattleColors.ink,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: const TextStyle(fontSize: 10.5, color: BattleColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------
  // Xona yaratish / qo'shilish
  // ---------------------------------------------------------------------
  Widget _setupCard(BuildContext context, BattleSetupState state, String locale) {
    final bloc = context.read<BattleSetupBloc>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E1A4C).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: BattleColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: BattleColors.muted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(text: locale == 'ru' ? 'Создать' : "Xona yaratish"),
                Tab(text: locale == 'ru' ? 'Присоединиться' : 'Xonaga qo\'shilish'),
              ],
            ),
          ),
          SizedBox(
            height: 420,
            child: TabBarView(
              controller: _tabController,
              children: [
                _createRoomTab(context, state, bloc, locale),
                _joinRoomTab(context, state, bloc, locale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _createRoomTab(
    BuildContext context,
    BattleSetupState state,
    BattleSetupBloc bloc,
    String locale,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(locale == 'ru' ? '1. Выберите класс' : '1. Sinfni tanlang'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.availableGrades.map((grade) {
              final selected = state.selectedGrade == grade;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  bloc.add(SelectGradeEvent(grade));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? BattleColors.primary : const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    locale == 'ru' ? '$grade-класс' : '$grade-sinf',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: selected ? Colors.white : BattleColors.ink,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (state.selectedGrade != null) ...[
            const SizedBox(height: 20),
            _sectionLabel(locale == 'ru' ? '2. Выберите предметы' : '2. Fan(lar)ni tanlang'),
            const SizedBox(height: 10),
            ...state.subjectsForSelectedGrade.map((subject) {
              final selected = state.selectedSubjectIds.contains(subject.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    bloc.add(ToggleSubjectEvent(subject.id));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? BattleColors.primary.withOpacity(0.08)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? BattleColors.primary : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          size: 18,
                          color: selected ? BattleColors.primary : BattleColors.muted,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          subject.name(locale),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: BattleColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            _sectionLabel(locale == 'ru' ? '3. Настройки' : '3. Qo\'shimcha sozlamalar'),
            const SizedBox(height: 10),
            _dropdownRow(
              label: locale == 'ru' ? 'Количество вопросов' : "Savollar soni",
              value: state.questionCount,
              options: const [5, 10, 15, 20],
              onChanged: (v) => bloc.add(ChangeQuestionCountEvent(v)),
            ),
            const SizedBox(height: 10),
            _dropdownRow(
              label: locale == 'ru' ? 'Секунд на вопрос' : 'Savolga vaqt (soniya)',
              value: state.secondsPerQuestion,
              options: const [30, 45, 60, 90, 120],
              onChanged: (v) => bloc.add(ChangeSecondsPerQuestionEvent(v)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.canCreateRoom
                    ? () => bloc.add(const CreateBattleRoomEvent())
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BattleColors.primary,
                  disabledBackgroundColor: const Color(0xFFE7EEFB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        locale == 'ru' ? 'Начать Battle' : 'Battle boshlash',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14.5),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _joinRoomTab(
    BuildContext context,
    BattleSetupState state,
    BattleSetupBloc bloc,
    String locale,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(
              locale == 'ru' ? 'Код комнаты' : 'Xona kodi'),
          const SizedBox(height: 10),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 8,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 6,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'ABC123',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) => bloc.add(ChangeJoinCodeEvent(value)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.canJoinRoom
                  ? () => bloc.add(const JoinBattleRoomEvent())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: BattleColors.primary,
                disabledBackgroundColor: const Color(0xFFE7EEFB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      locale == 'ru' ? 'Присоединиться' : 'Xonaga qo\'shilish',
                      style:
                          const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: BattleColors.ink,
      ),
    );
  }

  Widget _dropdownRow({
    required String label,
    required int value,
    required List<int> options,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 12.5, color: BattleColors.muted)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text('$o')))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Qoidalar kartasi
  // ---------------------------------------------------------------------
  Widget _rulesCard(String locale) {
    final rules = locale == 'ru'
        ? [
            'Оба игрока отвечают на одинаковые вопросы одновременно',
            'Сложность подбирается случайно сервером',
            'Победитель определяется по количеству правильных ответов',
            'Результат влияет на ваш ELO-рейтинг'
          ]
        : [
            'Ikkala o\'yinchi bir xil savollarga bir vaqtda javob beradi',
            'Qiyinlik darajasi server tomonidan tasodifiy tanlanadi',
            'G\'olib to\'g\'ri javoblar soniga qarab aniqlanadi',
            'Natija sizning ELO reytingingizga ta\'sir qiladi'
          ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          Row(
            children: [
              const Icon(Icons.shield_rounded, size: 18, color: BattleColors.primary),
              const SizedBox(width: 8),
              Text(
                locale == 'ru' ? 'Правила игры' : 'O\'yin qoidalari',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: BattleColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 5, color: BattleColors.muted),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rule,
                      style: const TextStyle(fontSize: 12.5, color: BattleColors.muted, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
