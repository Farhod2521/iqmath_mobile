import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/constants.dart';
import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/widgets/math_html_text.dart';
import '../../../../injector_container.dart';
import '../../../../router/app_routes.dart';
import '../../../../router/name_routes.dart';
import '../../../subject/presentation/widget/book_card_widget.dart';
import '../../../subject/presentation/widget/subject_stats_widgets.dart';
import '../../../subject/presentation/widget/topic_card.dart';
import '../../data/models/diagnostic_result.dart';
import '../diagnostic_texts.dart';

// Saytdagi `components/mistakes/utils.jsx` ranglari
const Color _kGreen = Color(0xFF22C55E);
const Color _kRed = Color(0xFFEF4444);
const Color _kBlue = Color(0xFF2563EB);
const Color _kGray = Color(0xFFCBD5E1);
const Color _kInk = Color(0xFF191C1D);
const Color _kMuted = Color(0xFF5B6478);
const Color _kSubtle = Color(0xFF8A93A6);
const Color _kBorder = Color(0xFFEEF1F6);

/// Natija rangi: yaxshi — yashil, o'rtacha — ko'k, past — qizil.
Color _scoreColor(num score) => score >= 80
    ? const Color(0xFF16A34A)
    : score >= 50
        ? _kBlue
        : _kRed;

/// Javob HTML/delimiterli bo'lsa o'zicha, oddiy LaTeX bo'lsa \( \) ichida.
String _toMath(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return '';
  if (RegExp(r'<[a-z][\s\S]*>|\\\(|\\\[|\$', caseSensitive: false)
      .hasMatch(text)) {
    return text;
  }
  return '\\($text\\)';
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _kBorder),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );

class DiagnosticResultsArgs {
  final String subjectId;

  /// Qayta topshirishda savol sahifasi sarlavhasi uchun
  final String? title;

  const DiagnosticResultsArgs({required this.subjectId, this.title});
}

/// Diagnostika "Natijalarim" — saytdagi DiagnosticMistakes sahifasi:
/// urinishlar, umumiy natija, savollar bo'yicha javoblar, mavzular kesimi,
/// natija grafigi va hisob-kitob.
class DiagnosticResultsPage extends StatefulWidget {
  final DiagnosticResultsArgs args;

  const DiagnosticResultsPage({super.key, required this.args});

  @override
  State<DiagnosticResultsPage> createState() => _DiagnosticResultsPageState();
}

class _DiagnosticResultsPageState extends State<DiagnosticResultsPage> {
  final Dio _dio = sl<Dio>();

  bool _loading = true;
  bool _failed = false;
  DiagnosticSubjectInfo? _subject;
  List<DiagnosticAttempt> _attempts = const [];
  int? _attemptId;

  bool _mistakesLoading = false;
  DiagnosticAttempt? _current;
  List<DiagnosticQuestion> _questions = const [];

  String _tab = 'all'; // all | wrong | correct | unanswered
  String _topic = 'all';
  String _sort = 'number'; // number | topic | wrongFirst
  int _trendRange = 10; // 0 — barchasi

  num? _points;
  num? _coins;

  String get _locale => context.read<AppBloc>().state.appLocale ?? 'uz';

  String get _lang => _locale == 'ru' ? 'ru' : 'uz';

  String _t(String key, [Map<String, Object>? args]) =>
      DiagnosticTexts.get(_locale, key, args);

  @override
  void initState() {
    super.initState();
    _loadAttempts();
    _loadScore();
  }

  // ─────────────────────────────── Ma'lumot ───────────────────────────────

  Future<void> _loadAttempts({bool selectLatest = false}) async {
    setState(() {
      _loading = _attempts.isEmpty;
      _failed = false;
    });
    try {
      final response = await _dio.get(
        '${Constants.baseUrl}/func_student/my-diagnost/subjects/'
        '${widget.args.subjectId}/attempts/',
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final attempts = ((data['attempts'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => DiagnosticAttempt.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (!mounted) return;
      final keep = !selectLatest &&
          _attemptId != null &&
          attempts.any((a) => a.id == _attemptId);
      setState(() {
        _subject = data['subject'] is Map
            ? DiagnosticSubjectInfo.fromJson(
                Map<String, dynamic>.from(data['subject'] as Map))
            : null;
        _attempts = attempts;
        _attemptId = keep ? _attemptId : attempts.firstOrNull?.id;
        _loading = false;
      });
      if (_attemptId != null) await _loadMistakes();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _loadMistakes() async {
    final id = _attemptId;
    if (id == null) return;
    setState(() => _mistakesLoading = true);
    try {
      final response = await _dio
          .get('${Constants.baseUrl}/func_student/my-diagnost/$id/mistakes/');
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted || id != _attemptId) return;
      setState(() {
        _current = data['attempt'] is Map
            ? DiagnosticAttempt.fromJson(
                Map<String, dynamic>.from(data['attempt'] as Map))
            : null;
        _questions = ((data['questions'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) =>
                DiagnosticQuestion.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _mistakesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _mistakesLoading = false);
    }
  }

  Future<void> _loadScore() async {
    try {
      final response = await _dio.get('${Constants.baseUrl}${Urls.MY_SCORE}');
      final raw = response.data;
      final data = raw is Map && raw['data'] is Map ? raw['data'] : raw;
      if (!mounted || data is! Map) return;
      setState(() {
        _points = data['score'] as num?;
        _coins = data['coin'] as num?;
      });
    } catch (_) {}
  }

  void _select(int id) {
    if (id == _attemptId) return;
    HapticFeedback.selectionClick();
    setState(() {
      _attemptId = id;
      _tab = 'all';
      _topic = 'all';
    });
    _loadMistakes();
  }

  Future<void> _retake() async {
    HapticFeedback.mediumImpact();
    await Navigator.pushNamed(
      mainRootNavigatorKey.currentContext!,
      Routes.questions,
      arguments: QuestionPageArguments(
        topic: null,
        isDiagnostic: true,
        taskName: widget.args.title ?? _subjectName,
        subjectId: widget.args.subjectId,
      ),
    );
    if (mounted) await _loadAttempts(selectLatest: true);
  }

  String get _subjectName {
    final subject = _subject;
    if (subject == null) return widget.args.title ?? '';
    final grade = isGradeName(subject.className)
        ? '${subject.className}-${_t('gradeSuffix')} · '
        : '';
    return '$grade${subject.name(_lang)}';
  }

  Map<String, int> get _counts {
    final result = {
      'all': _questions.length,
      'wrong': 0,
      'correct': 0,
      'unanswered': 0
    };
    for (final q in _questions) {
      result[q.status.name] = (result[q.status.name] ?? 0) + 1;
    }
    return result;
  }

  List<DiagnosticQuestion> get _visible {
    final list = _questions.where((q) {
      if (_tab != 'all' && q.status.name != _tab) return false;
      if (_topic != 'all' && q.topic(_lang) != _topic) return false;
      return true;
    }).toList();
    if (_sort == 'topic') {
      list.sort((a, b) {
        final byTopic = a.topic(_lang).compareTo(b.topic(_lang));
        return byTopic != 0 ? byTopic : a.number.compareTo(b.number);
      });
    } else if (_sort == 'wrongFirst') {
      list.sort((a, b) {
        final byStatus =
            (a.isCorrect ? 1 : 0).compareTo(b.isCorrect ? 1 : 0);
        return byStatus != 0 ? byStatus : a.number.compareTo(b.number);
      });
    }
    return list;
  }

  // ─────────────────────────────── UI ───────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            foregroundColor: _kInk,
            title: Text(
              _t('myResults'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kInk,
              ),
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator(color: _kBlue))
              : _failed
                  ? _errorView()
                  : RefreshIndicator(
                      color: _kBlue,
                      onRefresh: () => _loadAttempts(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        children: _content(),
                      ),
                    ),
        );
      },
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 44, color: _kSubtle),
          const SizedBox(height: 12),
          Text(_t('loadError'),
              style: const TextStyle(fontSize: 14, color: _kMuted)),
          const SizedBox(height: 12),
          TextButton(onPressed: _loadAttempts, child: Text(_t('reload'))),
        ],
      ),
    );
  }

  List<Widget> _content() {
    const gap = SizedBox(height: 16);
    if (_attempts.isEmpty) {
      return [
        _header(),
        gap,
        Container(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
          decoration: _cardDecoration(),
          child: Text(
            _t('noAttempts'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: _kMuted),
          ),
        ),
      ];
    }
    return [
      _header(),
      gap,
      if (_current != null) ...[_summary(_current!), gap],
      _attemptsCarousel(),
      gap,
      _questionsCard(),
      if (_questions.isNotEmpty) ...[gap, _topicResults()],
      gap,
      _trendCard(),
      gap,
      _balanceCard(),
    ];
  }

  // ── Sarlavha ──

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kBlue.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.grid_view_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('analysisTitle'),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                    Text(
                      _subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: _kBlue,
                      ),
                    ),
                    Text(
                      _t('subtitle'),
                      style: const TextStyle(fontSize: 12, color: _kMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_attempts.isNotEmpty) ...[
            const SizedBox(height: 14),
            _attemptPicker(),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _retake,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(_t('retake')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attemptPicker() {
    final index =
        math.max(0, _attempts.indexWhere((a) => a.id == _attemptId));
    final current = _attempts[index];
    final number = _attempts.length - index;

    Widget arrow(IconData icon, bool enabled, VoidCallback onTap) => InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 46,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Icon(icon,
                size: 20, color: enabled ? _kInk : _kInk.withValues(alpha: 0.3)),
          ),
        );

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _showAttemptSheet,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: _kBlue, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(text: '${_t('testLabel')}: '),
                            TextSpan(
                              text: '#$number',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, color: _kInk),
                            ),
                            TextSpan(text: ' - ${_t('diagnostics')}'),
                          ]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 11.5, color: _kMuted),
                        ),
                        Text(
                          current.date ?? '—',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _kInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: _kInk),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Chap — eskiroq urinish, o'ng — yangiroq
        arrow(Icons.chevron_left_rounded, index < _attempts.length - 1,
            () => _select(_attempts[index + 1].id)),
        const SizedBox(width: 8),
        arrow(Icons.chevron_right_rounded, index > 0,
            () => _select(_attempts[index - 1].id)),
      ],
    );
  }

  Future<void> _showAttemptSheet() async {
    final id = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SheetFrame(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            for (var i = 0; i < _attempts.length; i++)
              ListTile(
                selected: _attempts[i].id == _attemptId,
                selectedTileColor: const Color(0xFFEAF1FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: '#${_attempts.length - i}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' · ${_attempts[i].date ?? '—'}'),
                ])),
                titleTextStyle: const TextStyle(fontSize: 14, color: _kInk),
                trailing: Text(
                  '${_attempts[i].scoreInt}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _scoreColor(_attempts[i].score),
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, _attempts[i].id),
              ),
          ],
        ),
      ),
    );
    if (id != null) _select(id);
  }

  // ── Umumiy natija ──

  Widget _summary(DiagnosticAttempt attempt) {
    final total = attempt.total;
    String pct(int value) =>
        total > 0 ? '${(value * 100 / total).round()}%' : '0%';
    final unit = _t('pcs');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: CustomPaint(
                  painter: RingPainter(
                    value: attempt.scoreInt / 100,
                    color: _kBlue,
                    stroke: 10,
                    track: const Color(0xFFEDF1F8),
                    gradient: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  ),
                  child: Center(
                    child: Text(
                      '${attempt.scoreInt}%',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _kInk,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('overall'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                    Text(
                      _t('ofQuestions', {'count': total}),
                      style: const TextStyle(fontSize: 12.5, color: _kSubtle),
                    ),
                    const SizedBox(height: 10),
                    _legendRow(_kGreen, _t('correctAnswers'), attempt.correct),
                    const SizedBox(height: 7),
                    _legendRow(_kRed, _t('wrongAnswers'), attempt.wrong),
                    const SizedBox(height: 7),
                    _legendRow(_kGray, _t('unanswered'), attempt.unanswered),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _tile(
                      icon: Icons.description_outlined,
                      iconBg: const Color(0xFFDCE7FF),
                      iconColor: _kBlue,
                      soft: const Color(0xFFF1F5FF),
                      label: _t('total'),
                      value: '$total',
                      unit: unit,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _tile(
                      icon: Icons.check_rounded,
                      iconBg: _kGreen,
                      iconColor: Colors.white,
                      soft: const Color(0xFFEFFBF3),
                      label: _t('correctAnswers'),
                      value: '${attempt.correct}',
                      unit: unit,
                      badge: pct(attempt.correct),
                      badgeBg: const Color(0xFFDCFCE7),
                      badgeColor: const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _tile(
                      icon: Icons.close_rounded,
                      iconBg: _kRed,
                      iconColor: Colors.white,
                      soft: const Color(0xFFFEF2F2),
                      label: _t('wrongAnswers'),
                      value: '${attempt.wrong}',
                      unit: unit,
                      badge: pct(attempt.wrong),
                      badgeBg: const Color(0xFFFEE2E2),
                      badgeColor: const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _tile(
                      icon: Icons.schedule_rounded,
                      iconBg: const Color(0xFFDCE7FF),
                      iconColor: _kBlue,
                      soft: const Color(0xFFF1F5FF),
                      label: _t('timeSpent'),
                      value: DiagnosticTexts.duration(
                              _locale, attempt.durationSeconds) ??
                          '—',
                      hint: attempt.date,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendRow(Color color, String label, int value) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: _kMuted)),
        ),
        Text(
          '$value',
          style: const TextStyle(
              fontSize: 13.5, fontWeight: FontWeight.w700, color: _kInk),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color soft,
    required String label,
    required String value,
    String? unit,
    String? badge,
    Color? badgeBg,
    Color? badgeColor,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 21, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: _kMuted),
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5,
            runSpacing: 4,
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                ]),
                style: const TextStyle(color: _kInk),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
            ],
          ),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint,
                style: const TextStyle(fontSize: 11, color: _kSubtle)),
          ],
        ],
      ),
    );
  }

  // ── Oldingi urinishlar ──

  Widget _attemptsCarousel() {
    const last = 10;
    final items = _attempts.take(last).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('lastAttempts', {'count': last}),
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: _kInk),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: MediaQuery.textScalerOf(context).scale(112),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final active = item.id == _attemptId;
              final duration =
                  DiagnosticTexts.duration(_locale, item.durationSeconds);
              final color = _scoreColor(item.score);
              return GestureDetector(
                onTap: () => _select(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 172,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active ? _kBlue : _kBorder,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${_attempts.length - index}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kBlue,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              size: 13, color: _kBlue),
                          const SizedBox(width: 4),
                          Text(
                            item.day.isEmpty ? '—' : item.day,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _kInk,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kMuted,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CustomPaint(
                              painter: RingPainter(
                                value: item.scoreInt / 100,
                                color: color,
                                stroke: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _miniCount(item.correct, Icons.check_rounded,
                                  _kGreen),
                              _miniCount(
                                  item.wrong, Icons.close_rounded, _kRed),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.scoreInt}%',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                  height: 1.1,
                                ),
                              ),
                              if (duration != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.schedule_rounded,
                                        size: 11, color: _kBlue),
                                    const SizedBox(width: 3),
                                    Text(
                                      duration,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: _kMuted,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _miniCount(int value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color),
        ),
        Icon(icon, size: 11, color: color),
      ],
    );
  }

  // ── Savollar ──

  static const _tabs = [
    (key: 'all', active: Color(0xFF2563EB), idle: Color(0xFFF1F5FF), count: _kBlue),
    (key: 'wrong', active: Color(0xFFEF4444), idle: Color(0xFFFEF2F2), count: Color(0xFFDC2626)),
    (key: 'correct', active: Color(0xFF16A34A), idle: Color(0xFFEFFBF3), count: Color(0xFF15803D)),
    (key: 'unanswered', active: Color(0xFF64748B), idle: Color(0xFFF4F6FA), count: Color(0xFF64748B)),
  ];

  Widget _questionsCard() {
    final counts = _counts;
    final current = _current;
    final visible = _visible;
    final topics = <String>{
      for (final q in _questions)
        if (q.topic(_lang).isNotEmpty) q.topic(_lang),
    }.toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Holat filtrlari
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tab in _tabs)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _tab = tab.key);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: _tab == tab.key ? tab.active : tab.idle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _t('filter_${tab.key}'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _tab == tab.key ? Colors.white : _kInk,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _tab == tab.key
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${counts[tab.key] ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color:
                                  _tab == tab.key ? Colors.white : tab.count,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Mavzu va tartib
          Row(
            children: [
              Expanded(
                child: _selectPill(
                  label: _t('topicLabel'),
                  value: _topic == 'all' ? _t('all') : _topic,
                  onTap: () async {
                    final value = await _pickOption(_t('topicLabel'), [
                      ('all', _t('all')),
                      for (final name in topics) (name, name),
                    ], _topic);
                    if (value != null) setState(() => _topic = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _selectPill(
                  label: _t('sortLabel'),
                  value: _t('sort_$_sort'),
                  onTap: () async {
                    final value = await _pickOption(_t('sortLabel'), [
                      for (final key in ['number', 'topic', 'wrongFirst'])
                        (key, _t('sort_$key')),
                    ], _sort);
                    if (value != null) setState(() => _sort = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(height: 20, color: _kBorder),

          if (_mistakesLoading || current == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: _kBlue)),
            )
          else ...[
            if (!current.hasAnswers)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 18, color: Color(0xFF92400E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _t('oldAttemptNote'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        size: 40, color: Color(0xFF16A34A)),
                    const SizedBox(height: 10),
                    Text(
                      _tab == 'wrong' && _topic == 'all'
                          ? _t('noMistakes')
                          : _t('emptyFilter'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kInk,
                      ),
                    ),
                  ],
                ),
              )
            else
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: _kBorder),
                _QuestionTile(
                  key: ValueKey('${_attemptId}_${visible[i].questionId}'),
                  question: visible[i],
                  lang: _lang,
                  t: _t,
                ),
              ],
          ],
        ],
      ),
    );
  }

  Widget _selectPill({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EAF2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label: $value',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _kInk,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: _kInk),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickOption(
    String title,
    List<(String, String)> options,
    String current,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SheetFrame(
        title: title,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            for (final (value, label) in options)
              ListTile(
                selected: value == current,
                selectedTileColor: const Color(0xFFEAF1FF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: Text(label,
                    style: const TextStyle(fontSize: 14, color: _kInk)),
                trailing: value == current
                    ? const Icon(Icons.check_rounded, color: _kBlue)
                    : null,
                onTap: () => Navigator.pop(sheetContext, value),
              ),
          ],
        ),
      ),
    );
  }

  // ── Mavzular bo'yicha natija ──

  static const _topicRows = [
    (icon: Icons.calculate_outlined, color: Color(0xFF3B82F6), soft: Color(0xFFE0EAFF)),
    (icon: Icons.change_history_rounded, color: Color(0xFFF97316), soft: Color(0xFFFFEDD5)),
    (icon: Icons.straighten_rounded, color: Color(0xFF6D28D9), soft: Color(0xFFEDE9FE)),
    (icon: Icons.lightbulb_outline_rounded, color: Color(0xFF10B981), soft: Color(0xFFD1FAE5)),
    (icon: Icons.category_outlined, color: Color(0xFFEF4444), soft: Color(0xFFFEE2E2)),
    (icon: Icons.layers_outlined, color: Color(0xFF0EA5E9), soft: Color(0xFFE0F2FE)),
  ];

  Widget _topicResults() {
    final map = <String, ({int total, int correct})>{};
    for (final q in _questions) {
      final name = q.topic(_lang).isEmpty ? _t('noTopic') : q.topic(_lang);
      final row = map[name] ?? (total: 0, correct: 0);
      map[name] =
          (total: row.total + 1, correct: row.correct + (q.isCorrect ? 1 : 0));
    }
    final rows = map.entries
        .map((e) => (
              name: e.key,
              total: e.value.total,
              correct: e.value.correct,
              percent: (e.value.correct * 100 / e.value.total).round(),
            ))
        .toList()
      ..sort((a, b) => b.percent != a.percent
          ? b.percent.compareTo(a.percent)
          : b.total.compareTo(a.total));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _t('byTopic'),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: _kInk),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _topicRows[i % _topicRows.length].soft,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(_topicRows[i % _topicRows.length].icon,
                      size: 17, color: _topicRows[i % _topicRows.length].color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rows[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: _kInk),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: rows[i].percent / 100,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFEDF1F8),
                      valueColor: AlwaysStoppedAnimation(
                          _topicRows[i % _topicRows.length].color),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${rows[i].correct}/${rows[i].total}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12.5, color: _kMuted),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    '${rows[i].percent}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _kRed,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Natija grafigi ──

  Widget _trendCard() {
    final numbered = [
      for (var i = 0; i < _attempts.length; i++)
        (attempt: _attempts[i], label: '#${_attempts.length - i}'),
    ];
    final points =
        (_trendRange > 0 ? numbered.take(_trendRange) : numbered).toList()
            .reversed
            .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _t('trendTitle'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: _kInk),
                ),
              ),
              PopupMenuButton<int>(
                initialValue: _trendRange,
                onSelected: (value) => setState(() => _trendRange = value),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                itemBuilder: (_) => [
                  for (final value in [5, 10, 20, 0])
                    PopupMenuItem(
                      value: value,
                      child: Text(value > 0
                          ? _t('lastN', {'count': value})
                          : _t('all')),
                    ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5EAF2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _trendRange > 0
                            ? _t('lastN', {'count': _trendRange})
                            : _t('all'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _kInk,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: _kMuted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (points.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                _t('trendNeedMore'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _kSubtle),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const height = 200.0;
                final painter = _TrendPainter(
                  scores: [for (final p in points) p.attempt.score.toDouble()],
                  labels: [for (final p in points) p.label],
                  activeIndex:
                      points.indexWhere((p) => p.attempt.id == _attemptId),
                );
                return GestureDetector(
                  onTapUp: (details) {
                    final index = painter.nearestIndex(
                        details.localPosition, Size(constraints.maxWidth, height));
                    if (index != null) _select(points[index].attempt.id);
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, height),
                    painter: painter,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Hisob-kitob ──

  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _t('balance'),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: _kInk),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                          ),
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: Colors.white, size: 21),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_t('points'),
                                style: const TextStyle(
                                    fontSize: 11.5, color: _kMuted)),
                            Text(
                              '${_points ?? 0} ${_t('pointsUnit')}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: _kInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        'https://iqmath.uz/images/homepage/tanga.png',
                        width: 36,
                        height: 36,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.monetization_on_rounded,
                            color: Color(0xFFF59E0B),
                            size: 34),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_coins ?? 0} ${_t('coinsUnit')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: _kInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(
                mainRootNavigatorKey.currentContext!,
                Routes.subjectDetail,
                arguments: SubjectDetailArguments(
                  id: widget.args.subjectId,
                  subjectName: _subject?.name(_lang) ?? _subjectName,
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAEB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: Color(0xFFF59E0B), size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('improveTitle'),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _kInk,
                          ),
                        ),
                        Text(
                          _t('improveText'),
                          style:
                              const TextStyle(fontSize: 12, color: _kMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: _kMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════ Bitta savol ═══════════════════════════

class _QuestionTile extends StatefulWidget {
  final DiagnosticQuestion question;
  final String lang;
  final String Function(String key, [Map<String, Object>? args]) t;

  const _QuestionTile({
    super.key,
    required this.question,
    required this.lang,
    required this.t,
  });

  @override
  State<_QuestionTile> createState() => _QuestionTileState();
}

class _QuestionTileState extends State<_QuestionTile> {
  bool _open = true;

  static const _numberStyle = {
    QuestionStatus.wrong: (bg: Color(0xFFFEE2E2), fg: Color(0xFFDC2626)),
    QuestionStatus.correct: (bg: Color(0xFFDCFCE7), fg: Color(0xFF15803D)),
    QuestionStatus.unanswered: (bg: Color(0xFFF1F5F9), fg: Color(0xFF64748B)),
  };

  /// "Sizning javobingiz" va "To'g'ri javob" uchun HTML (saytdagi answersOf).
  ({String own, String correct}) _answers() {
    final q = widget.question;
    final lang = widget.lang;
    if (q.type == 'text') {
      return (
        own: _toMath(q.studentAnswer),
        correct: _toMath(q.correctTextAnswer(lang)),
      );
    }
    if (q.type == 'composite') {
      final subs = q.subQuestions;
      return (
        own: subs.any((s) => s.studentAnswer != null)
            ? subs
                .map((s) =>
                    s.studentAnswer != null ? _toMath(s.studentAnswer) : '—')
                .join(', ')
            : '',
        correct: subs.map((s) => _toMath(s.correctAnswer)).join(', '),
      );
    }
    final isImage = q.type == 'image_choice';
    String join(Iterable<DiagnosticChoice> choices) => choices
        .map((c) =>
            isImage || c.text(lang).isEmpty ? c.letter : c.text(lang))
        .join(', ');
    return (
      own: join(q.choices.where((c) => c.isSelected)),
      correct: join(q.choices.where((c) => c.isCorrect)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final status = q.status;
    final topic = q.topic(widget.lang);
    final answers = _answers();
    final number = _numberStyle[status]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: number.bg, shape: BoxShape.circle),
            child: Text(
              '${q.number}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: number.fg,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: topic.isEmpty
                          ? const SizedBox.shrink()
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAF1FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  topic,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: _kBlue,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _open = !_open),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE1E7F0)),
                        ),
                        child: AnimatedRotation(
                          turns: _open ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 20, color: _kInk),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                MathHtmlText(
                  q.text(widget.lang),
                  maxLines: _open ? null : 1,
                  imageMaxHeight: _open ? 180 : 0,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (_open && q.isChoice) ...[
                  const SizedBox(height: 10),
                  _choiceGrid(q),
                ],
                const SizedBox(height: 10),
                _answerBlock(status, answers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Variantlar: belgilangan xato — qizil ×, belgilangan to'g'ri — yashil ✓.
  Widget _choiceGrid(DiagnosticQuestion q) {
    final isImage = q.type == 'image_choice';
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in q.choices)
              Builder(builder: (context) {
                final wrongPick = choice.isSelected && !choice.isCorrect;
                final rightPick = choice.isSelected && choice.isCorrect;
                final border = wrongPick
                    ? const Color(0xFFFCA5A5)
                    : rightPick
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFE5EAF2);
                final bg = wrongPick
                    ? const Color(0xFFFEE2E2)
                    : rightPick
                        ? const Color(0xFFDCFCE7)
                        : Colors.white;
                final fg = wrongPick
                    ? const Color(0xFFDC2626)
                    : rightPick
                        ? const Color(0xFF15803D)
                        : _kInk;
                return Container(
                  width: width,
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.fromLTRB(10, 7, 24, 7),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      if (isImage && choice.imageUrl != null)
                        Image.network(
                          choice.imageUrl!,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(choice.letter),
                        )
                      else
                        MathHtmlText(
                          choice.text(widget.lang).isEmpty
                              ? choice.letter
                              : choice.text(widget.lang),
                          textAlign: TextAlign.center,
                          imageMaxHeight: 40,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                      if (wrongPick || rightPick)
                        Positioned(
                          right: -18,
                          child: Icon(
                            wrongPick ? Icons.close_rounded : Icons.check_rounded,
                            size: 16,
                            color: fg,
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _answerBlock(QuestionStatus status, ({String own, String correct}) a) {
    final q = widget.question;
    final t = widget.t;
    final ownBg = status == QuestionStatus.unanswered
        ? const Color(0xFFF1F5F9)
        : status == QuestionStatus.correct
            ? const Color(0xFFEFFBF3)
            : const Color(0xFFFEF2F2);
    final ownFg = status == QuestionStatus.unanswered
        ? const Color(0xFF64748B)
        : status == QuestionStatus.correct
            ? const Color(0xFF15803D)
            : const Color(0xFFDC2626);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (q.hasAnswer)
            Container(
              color: ownBg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Icon(
                    status == QuestionStatus.unanswered
                        ? Icons.remove_circle_outline_rounded
                        : status == QuestionStatus.correct
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined,
                    size: 16,
                    color: ownFg,
                  ),
                  if (status == QuestionStatus.unanswered)
                    Text(t('unansweredShort'),
                        style: TextStyle(fontSize: 13, color: ownFg))
                  else ...[
                    Text('${t('yourAnswer')}:',
                        style: TextStyle(fontSize: 13, color: ownFg)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: status == QuestionStatus.correct
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: MathHtmlText(
                        a.own.isEmpty ? '—' : a.own,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ownFg,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Container(
            color: const Color(0xFFEFFBF3),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: _kGreen),
                Text('${t('correctAnswer')}:',
                    style: const TextStyle(fontSize: 13, color: _kInk)),
                MathHtmlText(
                  a.correct.isEmpty ? '—' : a.correct,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════ Yordamchi vidjetlar ═══════════════════════════

/// Pastki panel ramkasi: tutqich, ixtiyoriy sarlavha va ro'yxat.
class _SheetFrame extends StatelessWidget {
  final String? title;
  final Widget child;

  const _SheetFrame({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kInk,
                ),
              ),
            )
          else
            const SizedBox(height: 10),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Natija grafigi: urinishlar natijasi (0–100%), maydonli chiziq; tanlangan
/// urinish yorliq bilan ajratiladi, nuqtani bosib o'sha urinishga o'tiladi.
class _TrendPainter extends CustomPainter {
  final List<double> scores;
  final List<String> labels;
  final int activeIndex;

  _TrendPainter({
    required this.scores,
    required this.labels,
    required this.activeIndex,
  });

  static const _padLeft = 36.0;
  static const _padRight = 16.0;
  static const _padTop = 26.0;
  static const _padBottom = 24.0;

  double _x(int i, Size size) {
    final w = size.width - _padLeft - _padRight;
    return _padLeft +
        (scores.length > 1 ? w * i / (scores.length - 1) : w / 2);
  }

  double _y(double score, Size size) {
    final h = size.height - _padTop - _padBottom;
    return _padTop + h - h * score.clamp(0, 100) / 100;
  }

  int? nearestIndex(Offset position, Size size) {
    int? best;
    var bestDistance = double.infinity;
    for (var i = 0; i < scores.length; i++) {
      final d = (Offset(_x(i, size), _y(scores[i], size)) - position).distance;
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    return bestDistance <= 28 ? best : null;
  }

  void _text(Canvas canvas, String text, Offset at, TextStyle style,
      {TextAlign align = TextAlign.center}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = align == TextAlign.right
        ? at.dx - painter.width
        : align == TextAlign.center
            ? at.dx - painter.width / 2
            : at.dx;
    painter.paint(canvas, Offset(dx, at.dy - painter.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const line = _kBlue;
    final grid = Paint()
      ..color = const Color(0xFFE9EEF6)
      ..strokeWidth = 1;
    const tickStyle = TextStyle(fontSize: 10, color: _kSubtle);

    for (final tick in [0, 25, 50, 75, 100]) {
      final y = _y(tick.toDouble(), size);
      canvas.drawLine(
          Offset(_padLeft, y), Offset(size.width - _padRight, y), grid);
      _text(canvas, '$tick%', Offset(_padLeft - 6, y), tickStyle,
          align: TextAlign.right);
    }

    final path = Path();
    for (var i = 0; i < scores.length; i++) {
      final p = Offset(_x(i, size), _y(scores[i], size));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    final area = Path.from(path)
      ..lineTo(_x(scores.length - 1, size), _y(0, size))
      ..lineTo(_x(0, size), _y(0, size))
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: 0.18), line.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, _padTop, size.width, size.height)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final shown = activeIndex >= 0 ? activeIndex : scores.length - 1;
    final labelStep = (scores.length / 8).ceil();
    for (var i = 0; i < scores.length; i++) {
      final p = Offset(_x(i, size), _y(scores[i], size));
      final active = i == shown;
      canvas.drawCircle(p, active ? 6 : 3.5,
          Paint()..color = active ? Colors.white : line);
      canvas.drawCircle(
        p,
        active ? 6 : 3.5,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = active ? 3 : 1.5,
      );
      if (i % labelStep == 0 || i == scores.length - 1) {
        _text(canvas, labels[i], Offset(p.dx, size.height - 8),
            const TextStyle(fontSize: 10, color: kSubjectMutedColor));
      }
    }

    // Tanlangan nuqta yorlig'i
    final p = Offset(_x(shown, size), _y(scores[shown], size));
    final cx = p.dx.clamp(_padLeft + 20, size.width - _padRight - 20);
    final cy = math.max(p.dy - 20, 12.0);
    final rect =
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: 44, height: 21), const Radius.circular(6));
    canvas.drawRRect(rect, Paint()..color = line);
    _text(
      canvas,
      '${scores[shown].round()}%',
      Offset(cx, cy),
      const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
    );
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.scores != scores || old.activeIndex != activeIndex;
}
