import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_bloc/app_bloc.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/top_notification.dart';
import '../../router/name_routes.dart';
import '../home/presentation/pages/home/widgets/payment_screen.dart';
import '../rewards/daily_reward_dialog.dart';
import 'liga_api.dart';
import 'liga_join_sheet.dart';
import 'liga_texts.dart';
import 'liga_widgets.dart';

/// O'quvchining liga sahifasi: mavsum, haftalik testlar, sinf reytingi va sovg'alar
/// (saytdagi /dashboard/student/liga bilan bir xil).
class LigaPage extends StatefulWidget {
  const LigaPage({super.key});

  @override
  State<LigaPage> createState() => _LigaPageState();
}

class _LigaPageState extends State<LigaPage> {
  static const _topShown = 5;

  Map<String, dynamic>? _data;
  Map<String, dynamic>? _past;
  bool _loading = true;
  bool _error = false;
  bool _busy = false;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = false);
    try {
      final data = await LigaApi.current();
      Map<String, dynamic>? past;
      try {
        final history = await LigaApi.winnersHistory();
        final seasonId = asMap(data['season'])['id'];
        past = history.where((s) => s['id'] != seasonId).cast<Map<String, dynamic>?>().firstWhere((_) => true, orElse: () => null);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _data = data;
        _past = past;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) TopNotification.showError(context, message: LigaApi.errorText(e) ?? 'Xatolik');
      _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Avval sinf tanlash va qoidalar oynasi, so'ng qo'shilish
  Future<void> _join(int seasonId, String locale) async {
    final data = _data ?? {};
    var grades = asMapList(data['grades']);
    if (grades.isEmpty) {
      try {
        grades = await LigaApi.classes();
      } catch (_) {}
    }
    if (!mounted) return;
    final grade = await showLigaJoinSheet(
      context,
      locale: locale,
      grades: grades,
      initialGrade: data['profile_grade_id'] == null ? null : asInt(data['profile_grade_id']),
    );
    if (grade == null || !mounted) return;
    await _run(() async {
      HapticFeedback.mediumImpact();
      await LigaApi.join(seasonId, grade);
      await _load();
    });
    // Ligaga qo'shilgach gol yig'ish boshlanadi: bugungi gol darhol beriladi (konfetti bilan)
    if (!mounted) return;
    DailyReward.reset();
    await DailyReward.claimAndShow(context, locale);
  }

  void _start(int testId) => _run(() async {
        final attempt = await LigaApi.start(testId);
        await _openAttempt(asInt(attempt['id']));
      });

  Future<void> _openAttempt(int id) async {
    await Navigator.of(context).pushNamed(Routes.ligaTest, arguments: id);
    if (mounted) _load(); // natija va reyting yangilansin
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<AppBloc, String>((b) => b.state.appLocale ?? 'uz');
    return Scaffold(
      backgroundColor: LigaColors.bg,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: LigaColors.primary))
            : RefreshIndicator(
                color: LigaColors.primary,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                  children: _content(locale),
                ),
              ),
      ),
    );
  }

  List<Widget> _content(String locale) {
    void back() => Navigator.of(context).maybePop();
    if (_error) {
      return [
        LigaHero(title: lt(locale, 'title'), subtitle: '', onBack: back),
        const SizedBox(height: 60),
        Center(child: Text(lt(locale, 'error'), style: const TextStyle(color: LigaColors.red, fontSize: 15))),
        Center(child: TextButton(onPressed: _load, child: Text(lt(locale, 'retry')))),
      ];
    }
    final data = _data ?? {};
    final season = data['season'] is Map ? asMap(data['season']) : null;
    if (season == null) {
      return [
        LigaHero(title: lt(locale, 'title'), subtitle: '', onBack: back),
        const SizedBox(height: 14),
        _menu(locale),
        _emptySeason(locale),
      ];
    }

    final closed = season['is_closed'] == true;
    final joined = data['joined'] == true;
    final grade = data['grade'];
    final subtitle = [
      ltf(locale, 'season', season['number']),
      if (grade != null) ltf(locale, 'grade', grade),
      if (closed) lt(locale, 'closed'),
    ].join(' • ');

    return [
      LigaHero(title: lt(locale, 'title'), subtitle: subtitle, onBack: back),
      const SizedBox(height: 14),
      _menu(locale),
      const SizedBox(height: 14),
      _stats(locale, season, data),
      if (!joined && !closed) ...[const SizedBox(height: 14), _joinCard(locale, season, data)],
      const SizedBox(height: 14),
      _tests(locale, data),
      const SizedBox(height: 14),
      _rating(locale, data, closed),
      const SizedBox(height: 14),
      _prizes(locale, season),
      ..._pastWinners(locale, grade),
    ];
  }

  /// Liga bo'limlari (saytdagi Liga menyusi kabi): mavsumlar/g'oliblar va shaxsiy tarix
  Widget _menu(String locale) {
    Widget tile(IconData icon, Color color, Color bg, String title, String text, String route) => Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                await Navigator.of(context).pushNamed(route);
                if (mounted) _load();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: LigaColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        LigaIconBox(icon: icon, size: 40, color: color, bg: bg),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded, color: LigaColors.muted),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                    const SizedBox(height: 2),
                    Text(text,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12, color: LigaColors.muted, height: 1.3)),
                  ],
                ),
              ),
            ),
          ),
        );
    return Row(
      children: [
        tile(Icons.workspace_premium_rounded, LigaColors.amber, const Color(0xFFFFF4DB), lt(locale, 'mSeasons'),
            lt(locale, 'mSeasonsText'), Routes.ligaSeasons),
        const SizedBox(width: 10),
        tile(Icons.history_rounded, LigaColors.primary, LigaColors.primarySoft, lt(locale, 'mHistory'),
            lt(locale, 'mHistoryText'), Routes.ligaHistory),
      ],
    );
  }

  Widget _emptySeason(String locale) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: LigaCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/images/liga_season_empty.webp', height: 170, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(lt(locale, 'emptyTitle'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: LigaColors.ink)),
            const SizedBox(height: 8),
            Text(lt(locale, 'empty'),
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: LigaColors.muted, height: 1.45)),
          ],
        ),
      ),
    );
  }

  Widget _stats(String locale, Map<String, dynamic> season, Map<String, dynamic> data) {
    final joined = data['joined'] == true;
    final items = [
      (Icons.calendar_month_rounded, LigaColors.primary, lt(locale, 'seasonLabel'), ltf(locale, 'season', season['number'])),
      (Icons.groups_rounded, LigaColors.primary, lt(locale, 'gradeLabel'),
          data['grade'] != null ? ltf(locale, 'grade', data['grade']) : '—'),
      (Icons.emoji_events_outlined, LigaColors.amber, lt(locale, 'rank'),
          joined && data['rank'] != null ? '#${data['rank']}' : '—'),
      (Icons.bar_chart_rounded, const Color(0xFF16A34A), lt(locale, 'points'), joined ? '${asInt(data['points'])}' : '—'),
    ];
    Widget cell((IconData, Color, String, String) item) => Row(
          children: [
            Icon(item.$1, size: 28, color: item.$2),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$3, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: LigaColors.muted)),
                  Text(item.$4, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                ],
              ),
            ),
          ],
        );
    return LigaCard(
      child: Column(
        children: [
          Row(children: [Expanded(child: cell(items[0])), Expanded(child: cell(items[1]))]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFEDF1F8))),
          Row(children: [Expanded(child: cell(items[2])), Expanded(child: cell(items[3]))]),
        ],
      ),
    );
  }

  Widget _joinCard(String locale, Map<String, dynamic> season, Map<String, dynamic> data) {
    final active = data['subscription_active'] == true;
    return LigaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lt(locale, 'joinTitle'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: LigaColors.ink)),
          const SizedBox(height: 4),
          Text(lt(locale, active ? 'joinText' : 'needPay'),
              style: const TextStyle(fontSize: 13.5, color: LigaColors.muted, height: 1.4)),
          const SizedBox(height: 14),
          active
              ? LigaButton(label: lt(locale, 'join'), busy: _busy, expand: true, onTap: () => _join(asInt(season['id']), locale))
              : LigaButton(
                  label: lt(locale, 'pay'),
                  expand: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TarifRejasiScreen())),
                ),
        ],
      ),
    );
  }

  Widget _tests(String locale, Map<String, dynamic> data) {
    final tests = asMapList(data['tests']);
    return LigaCard(
      child: Column(
        children: [
          LigaCardHead(icon: Icons.event_available_rounded, title: lt(locale, 'tests'), text: lt(locale, 'testsText')),
          const SizedBox(height: 14),
          if (tests.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(18)),
              child: Text(lt(locale, 'noTests'),
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, color: LigaColors.muted)),
            )
          else
            for (final test in tests) ...[
              _testRow(locale, test, data['joined'] == true),
              if (test != tests.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  Widget _testRow(String locale, Map<String, dynamic> test, bool joined) {
    final attempt = test['attempt'] is Map ? asMap(test['attempt']) : null;
    final inProgress = attempt?['status'] == 'in_progress';
    final status = '${test['status']}';

    Widget action;
    if (attempt != null && !inProgress) {
      action = Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _chip(Icons.check_circle_outline_rounded, ltf(locale, 'result', asInt(attempt['score']), asInt(attempt['max_score'])),
              LigaColors.greenSoft, LigaColors.green),
          LigaButton(label: lt(locale, 'showResult'), onTap: () => _openAttempt(asInt(attempt['id']))),
        ],
      );
    } else if (inProgress) {
      action = LigaButton(label: lt(locale, 'resume'), expand: true, onTap: () => _openAttempt(asInt(attempt!['id'])));
    } else if (status == 'live') {
      action = joined
          ? LigaButton(label: lt(locale, 'start'), busy: _busy, expand: true, onTap: () => _start(asInt(test['id'])))
          : _chip(Icons.lock_outline_rounded, lt(locale, 'joinFirst'), LigaColors.chip, LigaColors.muted);
    } else if (status == 'upcoming') {
      action = Row(
        children: [
          _Countdown(to: parseDate(test['start_at']), daysLabel: lt(locale, 'days'), onEnd: _load),
          const SizedBox(width: 8),
          Expanded(child: LigaButton(label: lt(locale, 'start'), icon: Icons.lock_outline_rounded, expand: true, onTap: null)),
        ],
      );
    } else {
      action = _chip(Icons.event_busy_rounded, lt(locale, 'missed'), LigaColors.chip, LigaColors.muted);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LigaColors.rowBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LigaIconBox(icon: Icons.assignment_outlined, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ltf(locale, 'weekTest', test['week_number']),
                        style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                    const SizedBox(height: 4),
                    _meta(Icons.calendar_today_rounded, '${_shortDate(test['start_at'])} – ${_shortDate(test['end_at'])}'),
                    const SizedBox(height: 2),
                    Wrap(spacing: 14, children: [
                      _meta(Icons.schedule_rounded, ltf(locale, 'minutes', test['duration_minutes'])),
                      _meta(Icons.layers_outlined, ltf(locale, 'questions', test['question_count'])),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          action,
        ],
      ),
    );
  }

  /// 11.06 16:16
  String _shortDate(dynamic iso) {
    final d = parseDate(iso);
    if (d == null) return '';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }

  Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: LigaColors.muted),
          const SizedBox(width: 4),
          Flexible(child: Text(text, style: const TextStyle(fontSize: 12.5, color: LigaColors.muted))),
        ],
      );

  Widget _chip(IconData? icon, String text, Color bg, Color fg) => Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 17, color: fg), const SizedBox(width: 6)],
            Flexible(child: Text(text, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: fg))),
          ],
        ),
      );

  Widget _rating(String locale, Map<String, dynamic> data, bool closed) {
    final top = asMapList(data['top']);
    final shown = _showAll ? top : top.take(_topShown).toList();
    final winners = asMapList(data['winners']);
    return LigaCard(
      child: Column(
        children: [
          LigaCardHead(
            icon: Icons.bar_chart_rounded,
            title: lt(locale, closed ? 'winners' : 'top'),
            trailing: !closed && top.length > _topShown
                ? TextButton(
                    onPressed: () => setState(() => _showAll = !_showAll),
                    child: Text(lt(locale, _showAll ? 'less' : 'all'),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: LigaColors.primary)),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (closed)
            for (final w in winners)
              _rankRow(
                asInt(w['place']),
                '${w['full_name'] ?? ''}',
                trailing: Text(
                  w['is_disqualified'] == true ? lt(locale, 'disqualified') : '${w['prize_$locale'] ?? w['prize_uz'] ?? ''}',
                  style: const TextStyle(fontSize: 13, color: LigaColors.muted),
                ),
                struck: w['is_disqualified'] == true,
              )
          else if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(lt(locale, 'noTop'), style: const TextStyle(fontSize: 13.5, color: LigaColors.muted)),
            )
          else
            for (final row in shown)
              _rankRow(
                asInt(row['rank']),
                '${row['full_name'] ?? ''}',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: LigaColors.primarySoft, borderRadius: BorderRadius.circular(20)),
                  child: Text(ltf(locale, 'ball', asInt(row['points'])),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: LigaColors.primary)),
                ),
              ),
        ],
      ),
    );
  }

  Widget _rankRow(int place, String name, {Widget? trailing, bool struck = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          LigaMedal(place: place),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: struck ? const Color(0xFF94A3B8) : LigaColors.ink,
                decoration: struck ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  Widget _prizes(String locale, Map<String, dynamic> season) {
    const images = {'planshet': 'tablet', 'telefon': 'phone', 'quloqchin': 'headphones'};
    return LigaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LigaCardHead(icon: Icons.card_giftcard_rounded, title: lt(locale, 'prizes'), text: lt(locale, 'prizesText')),
          const SizedBox(height: 12),
          for (final place in [1, 2, 3])
            Builder(builder: (_) {
              final key = '${season['prize_${place}_uz'] ?? ''}'.trim().toLowerCase();
              final name = '${season['prize_${place}_$locale'] ?? season['prize_${place}_uz'] ?? ''}';
              final image = images[key];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    LigaMedal(place: place),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(ltf(locale, 'place', place),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LigaColors.ink)),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: image != null
                          ? Image.asset('assets/images/liga_prize_$image.webp', fit: BoxFit.contain)
                          : const Icon(Icons.card_giftcard_rounded, color: LigaColors.primary, size: 26),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 4),
          Text(lt(locale, 'prizeNote'), style: const TextStyle(fontSize: 12, color: LigaColors.muted, height: 1.45)),
        ],
      ),
    );
  }

  List<Widget> _pastWinners(String locale, dynamic grade) {
    final past = _past;
    if (past == null) return const [];
    final winners = asMapList(past['winners']).where((w) => '${w['grade']}' == '$grade').toList();
    if (winners.isEmpty) return const [];
    return [
      const SizedBox(height: 14),
      LigaCard(
        child: Column(
          children: [
            LigaCardHead(
              icon: Icons.emoji_events_outlined,
              title: lt(locale, 'pastWinners'),
              text: ltf(locale, 'season', past['number']),
            ),
            const SizedBox(height: 12),
            for (final w in winners) _rankRow(asInt(w['place']), '${w['full_name'] ?? ''}'),
          ],
        ),
      ),
    ];
  }
}

/// Test boshlanishigacha orqaga sanash
class _Countdown extends StatefulWidget {
  const _Countdown({required this.to, required this.daysLabel, required this.onEnd});

  final DateTime? to;
  final String daysLabel;
  final VoidCallback onEnd;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _timer;
  int _left = 0;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final to = widget.to;
    final left = to == null ? 0 : to.difference(DateTime.now()).inSeconds;
    if (left <= 0 && _timer != null) {
      _timer?.cancel();
      widget.onEnd();
    }
    if (mounted) setState(() => _left = left < 0 ? 0 : left);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int v) => v.toString().padLeft(2, '0');
    final days = _left ~/ 86400;
    final text = '${days > 0 ? '$days ${widget.daysLabel} ' : ''}'
        '${two((_left % 86400) ~/ 3600)}:${two((_left % 3600) ~/ 60)}:${two(_left % 60)}';
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: LigaColors.primarySoft, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, size: 17, color: LigaColors.primary),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: LigaColors.primary,
                fontFeatures: [FontFeature.tabularFigures()],
              )),
        ],
      ),
    );
  }
}
