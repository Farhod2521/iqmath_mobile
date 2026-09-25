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

const String _kBattleHeroBg = 'assets/images/battle-bacground.png';

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

class _BattleLandingViewState extends State<_BattleLandingView> {
  int _mode = 0; // 0 = xona yaratish, 1 = xonaga qo'shilish
  final _codeController = TextEditingController();
  bool _showAllRules = false;
  bool _gradeExpanded = true;

  static const List<Color> _gradeColors = [
    Color(0xFF3B82F6), // Testlar
    Color(0xFF3B82F6), // 1
    Color(0xFFEC4899), // 2
    Color(0xFFF97316), // 3
    Color(0xFF8B5CF6), // 4
    Color(0xFFF59E0B), // 5
    Color(0xFF22C55E), // 6
    Color(0xFF06B6D4), // 7
    Color(0xFFEF4444), // 8
    Color(0xFFA855F7), // 9
    Color(0xFFF97316), // 10
    Color(0xFF3B82F6), // 11
  ];

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_mode == index) return;
    HapticFeedback.selectionClick();
    setState(() => _mode = index);
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
              body: SafeArea(
                child: Column(
                  children: [
                    _topBar(context, locale),
                    Expanded(
                      child: state.status == BattleSetupStatus.loading
                          ? const Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                              onRefresh: () async {
                                context
                                    .read<BattleSetupBloc>()
                                    .add(const LoadBattleSetupEvent());
                              },
                              child: ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 32),
                                children: [
                                  if (state.errorMessage != null)
                                    _errorBanner(state.errorMessage!.message),
                                  _heroCard(state, locale),
                                  const SizedBox(height: 14),
                                  _statsRow(state, locale),
                                  const SizedBox(height: 18),
                                  _setupCard(context, state, locale),
                                  const SizedBox(height: 18),
                                  _rulesCard(locale),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Yuqori panel — orqaga, sarlavha, reyting/tarix tugmalari
  // ---------------------------------------------------------------------
  Widget _topBar(BuildContext context, String locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _circleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            iconColor: const Color(0xFF1C1C1E),
            bgColor: const Color(0xFFF2F2F7),
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          const Text(
            'Battle',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: BattleColors.ink,
            ),
          ),
          const Spacer(),
          _circleIconButton(
            icon: Icons.emoji_events_rounded,
            iconColor: BattleColors.primary,
            bgColor: Colors.white,
            shadow: true,
            tooltip: locale == 'ru' ? 'Рейтинг' : 'Reyting',
            onTap: () => Navigator.pushNamed(context, Routes.battleLeaderboard),
          ),
          const SizedBox(width: 10),
          _circleIconButton(
            icon: Icons.history_rounded,
            iconColor: BattleColors.primary,
            bgColor: Colors.white,
            shadow: true,
            tooltip: locale == 'ru' ? 'История' : 'Tarix',
            onTap: () => Navigator.pushNamed(context, Routes.battleHistory),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
    bool shadow = false,
    String? tooltip,
  }) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: shadow
                ? [
                    const BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: 19, color: iconColor),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
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
  // Reyting bloki — battle-bacground.png foni bilan
  // ---------------------------------------------------------------------
  Widget _heroCard(BattleSetupState state, String locale) {
    final rating = state.rating;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: BattleColors.primary.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(_kBattleHeroBg, fit: BoxFit.cover),
            ),
            // Matn o'qilishi uchun chap tomonda qorong'ulashtiruvchi qatlam —
            // fon rasmining yorug' nur chiziqlari oq matnni yutib yuborayotgan edi.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.22),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 0.95],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: rating == null
                  ? const SizedBox(
                      height: 90,
                      child: Center(
                          child: CircularProgressIndicator(color: Colors.white)))
                  : rating.isInPlacement
                      ? _placementProgress(rating, locale)
                      : _ratingDetails(rating, locale),
            ),
          ],
        ),
      ),
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
    final pct = total > 0 ? ((rating.matchesPlayed / total) * 100).round() : 0;
    final left = rating.matchesLeftForPlacement;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'ru' ? 'Определение уровня' : 'Daraja aniqlanmoqda',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            shadows: [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 1))],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          locale == 'ru'
              ? '${rating.matchesPlayed}/$total квалификационных матчей'
              : "${rating.matchesPlayed}/$total saralash o'yini",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 1))],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(total.clamp(1, 10), (i) {
                  final done = i < rating.matchesPlayed;
                  return Expanded(
                    child: Container(
                      height: 8,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: done ? Colors.white : Colors.white.withOpacity(0.28),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$pct%',
                style: const TextStyle(
                  color: BattleColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  left > 0
                      ? (locale == 'ru'
                          ? 'Осталось ещё $left игры, чтобы определить ваш уровень!'
                          : "Yana $left ta o'yin qolsin, sizning darajangiz aniqlanadi!")
                      : (locale == 'ru'
                          ? 'Квалификация тавершена!'
                          : 'Saralash yakunlandi!'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))],
                  ),
                ),
              ),
            ],
          ),
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
        Icons.groups_rounded,
        const Color(0xFF3B82F6),
        locale == 'ru' ? 'Матчи' : "O'yinlar",
        '$total'
      ),
      (
        Icons.percent_rounded,
        const Color(0xFF3B82F6),
        locale == 'ru' ? 'Победы' : "G'alaba %",
        '${winRate.round()}%'
      ),
      (
        Icons.local_fire_department_rounded,
        const Color(0xFFF97316),
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
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.$2.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.$1, size: 18, color: item.$2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.$4,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: BattleColors.ink,
                      ),
                    ),
                    Text(
                      item.$3,
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: _modeToggle(locale),
          ),
          _mode == 0
              ? _createRoomTab(context, state, bloc, locale)
              : _joinRoomTab(context, state, bloc, locale),
        ],
      ),
    );
  }

  Widget _modeToggle(String locale) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _modeButton(
              icon: Icons.flash_on_rounded,
              label: locale == 'ru' ? 'Создать' : 'Xona yaratish',
              selected: _mode == 0,
              onTap: () => _switchTab(0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _modeButton(
              icon: Icons.group_add_rounded,
              label: locale == 'ru' ? 'Присоединиться' : 'Xonaga qo\'shilish',
              selected: _mode == 1,
              onTap: () => _switchTab(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: BattleColors.actionGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: BattleColors.actionGradient.last.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : BattleColors.muted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: selected ? Colors.white : BattleColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createRoomTab(
    BuildContext context,
    BattleSetupState state,
    BattleSetupBloc bloc,
    String locale,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _gradeStepHeader(locale),
          const SizedBox(height: 12),
          state.selectedGrade == null || _gradeExpanded
              ? _gradeGrid(state, bloc)
              : _gradeCollapsed(state),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _settingField(
                    label: locale == 'ru' ? 'Кол-во вопросов' : "Savollar soni",
                    value: state.questionCount,
                    options: const [5, 10, 15, 20],
                    onChanged: (v) => bloc.add(ChangeQuestionCountEvent(v)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _settingField(
                    label: locale == 'ru' ? 'Секунд на вопрос' : 'Savolga vaqt (soniya)',
                    value: state.secondsPerQuestion,
                    options: const [30, 45, 60, 90, 120],
                    onChanged: (v) => bloc.add(ChangeSecondsPerQuestionEvent(v)),
                  ),
                ),
              ],
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

  Widget _gradeStepHeader(String locale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BattleColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Text(
            '1',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: BattleColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          locale == 'ru' ? 'Выберите класс' : 'Sinfni tanlang',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: BattleColors.ink,
          ),
        ),
        const Spacer(),
        const Icon(Icons.school_rounded, size: 15, color: BattleColors.muted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            locale == 'ru'
                ? 'С каким классом хотите сразиться?'
                : 'Qaysi sinf bilan bellashmoqchisiz?',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 10, color: BattleColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _gradeGrid(BattleSetupState state, BattleSetupBloc bloc) {
    final grades = state.availableGrades;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grades.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        final grade = grades[index];
        final isTestlar = int.tryParse(grade) == null;
        final selected = state.selectedGrade == grade;
        final color = _gradeColors[index % _gradeColors.length];

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            bloc.add(SelectGradeEvent(grade));
            setState(() => _gradeExpanded = false);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? BattleColors.primary : const Color(0xFFF0F0F0),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: BattleColors.primary.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isTestlar
                    ? Icon(Icons.menu_book_rounded, size: 26, color: color)
                    : Text(
                        grade,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                const SizedBox(height: 4),
                Text(
                  isTestlar ? 'Testlar-sinf' : '$grade-sinf',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: BattleColors.ink,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _gradeCollapsed(BattleSetupState state) {
    final grade = state.selectedGrade!;
    final index = state.availableGrades.indexOf(grade);
    final color = _gradeColors[(index < 0 ? 0 : index) % _gradeColors.length];
    final isTestlar = int.tryParse(grade) == null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _gradeExpanded = true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BattleColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isTestlar
                  ? Icon(Icons.menu_book_rounded, size: 16, color: color)
                  : Text(
                      grade,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isTestlar ? 'Testlar-sinf' : '$grade-sinf',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: BattleColors.ink,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: BattleColors.muted),
          ],
        ),
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

  Widget _settingField({
    required String label,
    required int value,
    required List<int> options,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: BattleColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: BattleColors.muted),
              items: options
                  .map(
                    (o) => DropdownMenuItem(
                      value: o,
                      child: Text(
                        '$o',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: BattleColors.ink,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Qoidalar kartasi
  // ---------------------------------------------------------------------
  Widget _rulesCard(String locale) {
    final rules = locale == 'ru'
        ? const [
            (Icons.access_time_filled_rounded, Color(0xFFEF4444),
                'Оба игрока отвечают на одинаковые вопросы одновременно.'),
            (Icons.bolt_rounded, Color(0xFFF59E0B),
                'Побеждает игрок, который отвечает быстро и правильно.'),
            (Icons.star_rounded, Color(0xFF3B82F6),
                'Неправильные ответы также учитываются.'),
            (Icons.trending_up_rounded, Color(0xFF8B5CF6),
                'Результат влияет на ваш ELO-рейтинг.'),
          ]
        : const [
            (Icons.access_time_filled_rounded, Color(0xFFEF4444),
                "Ikkala o'yinchi bir xil savollarga bir vaqtda javob beradi."),
            (Icons.bolt_rounded, Color(0xFFF59E0B),
                "Tez va to'g'ri javob bergan o'yinchi g'alaba qozonadi."),
            (Icons.star_rounded, Color(0xFF3B82F6),
                'Xato javoblar hisobga olinadi.'),
            (Icons.trending_up_rounded, Color(0xFF8B5CF6),
                "Natija sizning ELO reytingingizga ta'sir qiladi."),
          ];

    final visibleRules = _showAllRules ? rules : rules.take(3).toList();

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
              Expanded(
                child: Text(
                  locale == 'ru' ? 'Правила игры' : "O'yin qoidalari",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800, color: BattleColors.ink),
                ),
              ),
              if (rules.length > 3)
                GestureDetector(
                  onTap: () => setState(() => _showAllRules = !_showAllRules),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: BattleColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showAllRules
                              ? (locale == 'ru' ? 'Свернуть' : 'Kamroq ko\'rish')
                              : (locale == 'ru' ? 'Смотреть все' : "Barchasini ko'rish"),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: BattleColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          _showAllRules
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.arrow_forward_rounded,
                          size: 14,
                          color: BattleColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ...visibleRules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rule.$2.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(rule.$1, size: 13, color: rule.$2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        rule.$3,
                        style: const TextStyle(
                            fontSize: 12.5, color: BattleColors.muted, height: 1.4),
                      ),
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
