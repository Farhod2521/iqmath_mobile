import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/features/diagnostics/data/models/subject.dart';

import '../../../../constants/constants.dart';
import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../generated/assets.dart';
import '../../../../injector_container.dart';
import '../../../../router/app_routes.dart';
import '../../../../router/name_routes.dart';
import '../../../subject/presentation/widget/subject_stats_widgets.dart';
import '../../../subject/presentation/widget/topic_card.dart';
import '../diagnostic_texts.dart';
import 'diagnostic_results_page.dart';

/// Bitta fan turi (Matematika, Algebra, ...) bo'yicha diagnostika bo'limi.
class _DiagnosticSection {
  final String title;
  final List<Subject> items;
  final List<Subject> graded;
  final SubjectTheme theme;

  _DiagnosticSection({
    required this.title,
    required this.items,
    required this.theme,
  }) : graded = items.where((s) => isGradeName(s.className)).toList()
          ..sort((a, b) =>
              int.parse(a.className).compareTo(int.parse(b.className)));

  int? get firstGrade =>
      graded.isEmpty ? null : int.parse(graded.first.className);

  int? get lastGrade => graded.isEmpty ? null : int.parse(graded.last.className);
}

/// Diagnostika — saytdagi DiagnosticSubjects sahifasi: fan turlari bo'yicha
/// statistika karuseli va har bir fan uchun diagnostika kartasi
/// ("Boshlash" / "Natijalarim" / "Qayta topshirish").
class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  final Dio _dio = sl<Dio>();
  final Map<int, GlobalKey> _sectionKeys = {};

  List<Subject> _subjects = const [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      _loading = _subjects.isEmpty;
      _failed = false;
    });
    try {
      final response = await _dio
          .get('${Constants.baseUrl}/func_student/my-diagnost-subjects/');
      final subjects = ((response.data as List?) ?? const [])
          .whereType<Map>()
          .map((e) => Subject.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (!mounted) return;
      setState(() {
        _subjects = subjects;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  List<_DiagnosticSection> _buildSections(String? locale) {
    final grouped = <String, List<Subject>>{};
    for (final subject in _subjects) {
      grouped.putIfAbsent(subject.nameUz, () => []).add(subject);
    }
    final entries = grouped.entries.toList();
    return [
      for (var i = 0; i < entries.length; i++)
        _DiagnosticSection(
          title: locale == 'ru' && entries[i].value.first.nameRu.isNotEmpty
              ? entries[i].value.first.nameRu
              : entries[i].key,
          items: entries[i].value,
          theme: SubjectTheme.of(entries[i].key, i),
        ),
    ];
  }

  GlobalKey _keyFor(int index) =>
      _sectionKeys.putIfAbsent(index, () => GlobalKey());

  void _scrollToSection(int index) {
    final ctx = _sectionKeys[index]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  String _taskName(Subject subject, String? locale) =>
      locale == 'ru' ? subject.classRu : subject.classUz;

  Future<void> _start(Subject subject, String? locale) async {
    HapticFeedback.mediumImpact();
    await Navigator.pushNamed(
      mainRootNavigatorKey.currentContext!,
      Routes.questions,
      arguments: QuestionPageArguments(
        topic: null,
        isDiagnostic: true,
        taskName: _taskName(subject, locale),
        subjectId: subject.id.toString(),
      ),
    );
    // Testdan qaytganda yangi natija darhol ko'rinsin
    if (mounted) _fetchSubjects();
  }

  Future<void> _openResults(Subject subject, String? locale) async {
    HapticFeedback.lightImpact();
    await Navigator.pushNamed(
      mainRootNavigatorKey.currentContext!,
      Routes.diagnosticResults,
      arguments: DiagnosticResultsArgs(
        subjectId: subject.id.toString(),
        title: _taskName(subject, locale),
      ),
    );
    if (mounted) _fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';
        final sections = _buildSections(locale);
        final statsSections = [
          for (var i = 0; i < sections.length; i++)
            if (sections[i].graded.isNotEmpty) i,
        ];

        return CupertinoPageScaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          navigationBar: CupertinoNavigationBar(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    Assets.svgChartDiagram,
                    colorFilter: ColorFilter.mode(
                        context.color.white, BlendMode.srcIn),
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DiagnosticTexts.get(locale, 'diagnostics'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            bottom: const PreferredSize(
              preferredSize: Size(double.infinity, 8),
              child: SizedBox.shrink(),
            ),
            backgroundColor: CupertinoColors.white,
            automaticBackgroundVisibility: false,
          ),
          child: SafeArea(
            bottom: false,
            child: _loading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CupertinoActivityIndicator(radius: 16),
                        const SizedBox(height: 16),
                        Text(
                          DiagnosticTexts.get(locale, 'loading'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  )
                : _failed && _subjects.isEmpty
                    ? _errorView(locale)
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: _fetchSubjects,
                          ),
                          if (sections.isEmpty)
                            SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  DiagnosticTexts.get(locale, 'empty'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ),
                            )
                          else
                            // Barcha bo'limlar bitta blokda — "Barchasini
                            // ko'rish" istalgan bo'limga aylantira olishi uchun
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (statsSections.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 16, 16, 0),
                                      child: StatsCarousel(
                                        children: [
                                          for (final i in statsSections)
                                            _statsCard(sections[i], locale,
                                                () => _scrollToSection(i)),
                                        ],
                                      ),
                                    ),
                                  for (var i = 0; i < sections.length; i++)
                                    _section(sections[i], locale, _keyFor(i)),
                                ],
                              ),
                            ),
                          const SliverGap(100),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Widget _errorView(String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle_fill,
                size: 40, color: Color(0xFFFF3B30)),
            const SizedBox(height: 16),
            Text(
              DiagnosticTexts.get(locale, 'loadError'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              onPressed: _fetchSubjects,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF007AFF),
              child: Text(
                DiagnosticTexts.get(locale, 'reload'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fan turi bo'yicha statistika: o'rtacha natija (topshirilmagan fan 0%
  /// hisoblanadi), topshirilgan / topshirilmagan fanlar va zaif mavzular.
  Widget _statsCard(
      _DiagnosticSection section, String locale, VoidCallback onSeeAll) {
    String t(String key, [Map<String, Object>? args]) =>
        DiagnosticTexts.get(locale, key, args);
    final items = section.items;
    final taken = items.where((s) => s.hasTakenDiagnostic).toList();
    final average = items.isEmpty
        ? 0
        : (taken.fold<int>(0, (sum, s) => sum + s.score) / items.length)
            .round();
    final weak = taken.fold<int>(0, (sum, s) => sum + s.weakTopicsCount);
    final first = section.firstGrade;
    final last = section.lastGrade;

    return SubjectStatsCard(
      title: section.title,
      theme: section.theme,
      gradesLabel: first == last
          ? t('statsGrade', {'grade': '$first'})
          : t('statsGrades', {'from': '$first', 'to': '$last'}),
      overall: average,
      overallLabel: t('statsOverall'),
      legend: [
        StatsLegendItem(
            color: section.theme.accent,
            label: t('statsTotal'),
            value: items.length),
        StatsLegendItem(
            color: kStatsCompletedColor,
            label: t('statsTaken'),
            value: taken.length),
        StatsLegendItem(
            color: kStatsNotStartedColor,
            label: t('statsNotTaken'),
            value: items.length - taken.length),
        StatsLegendItem(
            color: kStatsInProgressColor,
            label: t('statsWeak'),
            value: weak),
      ],
      grades: [
        for (final s in section.graded) (label: s.className, value: s.score),
      ],
      seeAllLabel: t('seeAll'),
      onSeeAll: onSeeAll,
    );
  }

  Widget _section(_DiagnosticSection section, String locale, Key key) {
    final first = section.firstGrade;
    final last = section.lastGrade;
    final subtitle = first == null
        ? ''
        : first == last
            ? DiagnosticTexts.get(
                locale, 'sectionSubtitleSingle', {'grade': '$first'})
            : DiagnosticTexts.get(locale, 'sectionSubtitle',
                {'from': '$first', 'to': '$last'});
    final items = section.items;

    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SubjectSectionHeader(
            title: section.title,
            subtitle: subtitle,
            accent: section.theme.accent,
          ),
          const SizedBox(height: 14),
          // 2 ustunli setka; bir qatordagi kartalar balandligi teng
          for (var row = 0; row < items.length; row += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _card(items[row], section.theme, locale)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: row + 1 < items.length
                          ? _card(items[row + 1], section.theme, locale)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(Subject subject, SubjectTheme theme, String locale) {
    return _DiagnosticCard(
      subject: subject,
      theme: theme,
      locale: locale,
      onStart: () => _start(subject, locale),
      onResults: () => _openResults(subject, locale),
    );
  }
}

/// Diagnostika kartasi (saytdagi CardDiagnostic): fan rasmi va nomi,
/// natija qatori, oxirgi sana / urinishlar / zaif mavzular va tugmalar.
class _DiagnosticCard extends StatefulWidget {
  final Subject subject;
  final SubjectTheme theme;
  final String locale;
  final VoidCallback onStart;
  final VoidCallback onResults;

  const _DiagnosticCard({
    required this.subject,
    required this.theme,
    required this.locale,
    required this.onStart,
    required this.onResults,
  });

  @override
  State<_DiagnosticCard> createState() => _DiagnosticCardState();
}

class _DiagnosticCardState extends State<_DiagnosticCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1, end: 0.96).animate(
    CurvedAnimation(parent: _press, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  String _t(String key, [Map<String, Object>? args]) =>
      DiagnosticTexts.get(widget.locale, key, args);

  /// Natija rangi: yaxshi — yashil, o'rtacha — fan rangi, past — sariq.
  Color _scoreColor(int score) => score >= 80
      ? const Color(0xFF22C55E)
      : score >= 50
          ? widget.theme.accent
          : const Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final accent = widget.theme.accent;
    final taken = subject.hasTakenDiagnostic;
    final score = subject.score;
    final color = _scoreColor(score);
    final isRu = widget.locale == 'ru';
    final grade = subject.className;
    final gradeLabel = isGradeName(grade)
        ? '$grade-${isRu ? 'класс' : 'sinf'}'
        : grade;
    final name = isRu && subject.nameRu.isNotEmpty
        ? subject.nameRu
        : subject.nameUz;

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onStart();
      },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEDF0F5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F1B3D).withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 1920 / 819,
                  child: Container(
                    color: const Color(0xFFF4F7FC),
                    child: subject.imageUz.isNotEmpty
                        ? Image.network(
                            'https://api.iqmath.uz${subject.imageUz}',
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                        child: CupertinoActivityIndicator(
                                            radius: 9)),
                            errorBuilder: (_, __, ___) => Icon(
                                CupertinoIcons.book_fill,
                                color: accent.withValues(alpha: 0.6)),
                          )
                        : Icon(CupertinoIcons.book_fill,
                            color: accent.withValues(alpha: 0.6)),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sinf, fan nomi va strelka
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gradeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: kSubjectTitleColor,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF5B6478),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.theme.soft,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(CupertinoIcons.arrow_right,
                                size: 14, color: accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Natija qatori
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: taken ? score / 100 : 0,
                                minHeight: 6,
                                backgroundColor: kSubjectTrackColor,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            taken ? '$score%' : '—',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: taken ? color : const Color(0xFFA0A8BA),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Ma'lumot (2 qator)
                      if (taken) ...[
                        _info(
                          CupertinoIcons.calendar,
                          accent,
                          _t('lastTaken', {'date': subject.lastTakenAt ?? '—'}),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              flex: 3,
                              child: _info(
                                Icons.track_changes_rounded,
                                const Color(0xFFF59E0B),
                                _t('weakTopics',
                                    {'count': subject.weakTopicsCount}),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              flex: 2,
                              child: _info(
                                Icons.refresh_rounded,
                                accent,
                                _t('attempts', {
                                  'count': math.max(1, subject.attemptsCount)
                                }),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          _t('notTaken'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5B6478),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _t('notTakenHint'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kSubjectMutedColor,
                          ),
                        ),
                      ],
                      const Spacer(),
                      const SizedBox(height: 10),

                      // Tugmalar
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: ElevatedButton.icon(
                                onPressed:
                                    taken ? widget.onResults : widget.onStart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                icon: Icon(
                                  taken
                                      ? Icons.bar_chart_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  taken ? _t('myResults') : _t('start'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          if (taken) ...[
                            const SizedBox(width: 6),
                            Tooltip(
                              message: _t('retake'),
                              child: InkWell(
                                onTap: widget.onStart,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: widget.theme.soft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.refresh_rounded,
                                      size: 18, color: accent),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: kSubjectMutedColor,
            ),
          ),
        ),
      ],
    );
  }
}
