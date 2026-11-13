import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_bloc/app_bloc.dart';
import '../../core/widgets/dash_ui.dart';
import '../../router/name_routes.dart';
import 'liga_api.dart';
import 'liga_texts.dart';
import 'liga_widgets.dart';

/// O'quvchining shaxsiy liga tarixi: mavsumlar bo'yicha ball, o'rin, yutuqlar, testlar va ball tarixi
/// (saytdagi /dashboard/student/liga/history bilan bir xil).
class LigaHistoryPage extends StatefulWidget {
  const LigaHistoryPage({super.key});

  @override
  State<LigaHistoryPage> createState() => _LigaHistoryPageState();
}

const _sources = {
  'daily': (Icons.login_rounded, 'hDaily'),
  'subject': (Icons.menu_book_rounded, 'hSubject'),
  'test': (Icons.assignment_outlined, 'hTest'),
};

class _LigaHistoryPageState extends State<LigaHistoryPage> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _error = false;

  // Ball tarixi
  final List<Map<String, dynamic>> _logs = [];
  String? _source;
  int _page = 1;
  bool _hasMore = false;
  bool _logsLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = false);
    try {
      final data = await LigaApi.myHistory();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
      await _loadLogs(reset: true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  Future<void> _loadLogs({bool reset = false}) async {
    if (_logsLoading) return;
    final page = reset ? 1 : _page + 1;
    setState(() => _logsLoading = true);
    try {
      final res = await LigaApi.myPoints(page: page, source: _source);
      if (!mounted) return;
      setState(() {
        if (reset) _logs.clear();
        _logs.addAll(asMapList(res['results']));
        _page = page;
        _hasMore = res['next'] != null;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _logsLoading = false);
    }
  }

  void _pickSource(String? source) {
    if (source == _source) return;
    setState(() => _source = source);
    _loadLogs(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<AppBloc, String>((b) => b.state.appLocale ?? 'uz');
    final body = _loading
        ? const Center(child: CircularProgressIndicator(color: LigaColors.primary))
        : RefreshIndicator(
            color: LigaColors.primary,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
              children: _content(locale),
            ),
          );
    return Scaffold(
      backgroundColor: LigaColors.bg,
      body: SafeArea(
        bottom: false,
        child: _data?['viewer'] != null ? LigaWatermark(viewer: '${_data!['viewer']}', child: body) : body,
      ),
    );
  }

  List<Widget> _content(String locale) {
    void back() => Navigator.of(context).maybePop();
    final hero = LigaHero(title: lt(locale, 'hTitle'), subtitle: lt(locale, 'hSub'), onBack: back);
    if (_error) {
      return [
        hero,
        const SizedBox(height: 60),
        Center(child: Text(lt(locale, 'error'), style: const TextStyle(color: LigaColors.red, fontSize: 15))),
        Center(child: TextButton(onPressed: _load, child: Text(lt(locale, 'retry')))),
      ];
    }
    final data = _data ?? {};
    final seasons = asMapList(data['seasons']);
    return [
      hero,
      const SizedBox(height: 14),
      _summary(locale, asMap(data['summary'])),
      const SizedBox(height: 14),
      LigaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LigaCardHead(icon: Icons.emoji_events_outlined, title: lt(locale, 'hBySeason')),
            const SizedBox(height: 12),
            if (seasons.isEmpty) _empty(lt(locale, 'hNoSeasons')),
            for (final s in seasons) _seasonCard(locale, s),
          ],
        ),
      ),
      if (seasons.isNotEmpty) ...[const SizedBox(height: 14), _pointsLog(locale)],
    ];
  }

  Widget _summary(String locale, Map<String, dynamic> summary) {
    final items = [
      (Icons.bar_chart_rounded, LigaColors.teal, lt(locale, 'hTotal'), '${summary['total_points'] ?? 0}'),
      (Icons.event_available_rounded, LigaColors.primary, lt(locale, 'hSeasons'), '${summary['seasons'] ?? 0}'),
      (Icons.assignment_outlined, LigaColors.primary, lt(locale, 'hTests'), '${summary['tests'] ?? 0}'),
      (Icons.workspace_premium_rounded, LigaColors.amber, lt(locale, 'hWins'), '${summary['wins'] ?? 0}'),
    ];
    Widget cell((IconData, Color, String, String) item) => Row(
          children: [
            Icon(item.$1, color: item.$2, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$3,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: LigaColors.muted)),
                  Text(item.$4, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                ],
              ),
            ),
          ],
        );
    return LigaCard(
      child: Column(
        children: [
          Row(children: [Expanded(child: cell(items[0])), Expanded(child: cell(items[1]))]),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: cell(items[2])), Expanded(child: cell(items[3]))]),
        ],
      ),
    );
  }

  Widget _seasonCard(String locale, Map<String, dynamic> s) {
    final points = asInt(s['points']);
    final sources = asMap(s['sources']);
    final win = s['win'] is Map ? asMap(s['win']) : null;
    final tests = asMapList(s['tests']);
    final disq = win?['is_disqualified'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LigaColors.rowBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LigaIconBox(icon: Icons.emoji_events_rounded, color: LigaColors.amber, bg: Color(0xFFFFF4DB)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${ltf(locale, 'season', s['number'])} · ${ltf(locale, 'grade', s['grade'])}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                    Text(lt(locale, s['is_closed'] == true ? 'sClosed' : 'sLive'),
                        style: const TextStyle(fontSize: 12, color: LigaColors.muted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ltf(locale, 'ball', points),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: LigaColors.primary)),
                  if (s['rank'] != null)
                    Text(ltf(locale, 'hRank', s['rank'], s['participants_count']),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: LigaColors.muted)),
                ],
              ),
            ],
          ),
          if (win != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: disq ? LigaColors.redSoft : null,
                gradient: disq ? null : const LinearGradient(colors: [Color(0xFFFFF7E6), Color(0xFFFFEFD1)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  LigaMedal(place: asInt(win['place']), size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(disq ? lt(locale, 'hDisq') : ltf(locale, 'hWin', win['place']),
                        style: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w800, color: disq ? LigaColors.red : const Color(0xFF9A5B00))),
                  ),
                  if (!disq)
                    Text('${win['prize_$locale'] ?? win['prize_uz'] ?? ''}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF9A5B00))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              for (final entry in _sources.entries) ...[
                Expanded(child: _sourceTile(locale, entry.value, asInt(sources[entry.key]), points)),
                if (entry.key != 'test') const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(lt(locale, 'hMyTests'), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
          const SizedBox(height: 6),
          if (tests.isEmpty) _empty(lt(locale, 'hNoTests')),
          for (final t in tests)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pushNamed(Routes.ligaTest, arguments: asInt(t['attempt_id'])),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ltf(locale, 'sWeek', t['week_number']),
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                          Text(
                            '${fmtDate(t['finished_at'])} · ${_mmss(t['duration_seconds'])} · '
                            '${ltf(locale, 'hCorrect', t['correct_count'] ?? 0, t['total_questions'] ?? 0)}',
                            style: const TextStyle(fontSize: 11.5, color: LigaColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: LigaColors.primarySoft, borderRadius: BorderRadius.circular(20)),
                      child: Text('${t['score']}/${t['max_score']}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: LigaColors.primary)),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: LigaColors.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sourceTile(String locale, (IconData, String) meta, int value, int total) {
    final ratio = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(meta.$1, size: 14, color: LigaColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(lt(locale, meta.$2),
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: LigaColors.muted)),
            ),
          ]),
          const SizedBox(height: 4),
          Text('$value', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: LigaColors.ink)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: LigaColors.rowBorder,
              color: LigaColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pointsLog(String locale) {
    Widget tab(String? key, String label) {
      final active = _source == key;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pickSource(key),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? LigaColors.primary : LigaColors.soft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : LigaColors.text)),
          ),
        ),
      );
    }

    return LigaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LigaCardHead(icon: Icons.history_rounded, title: lt(locale, 'hPoints'), text: lt(locale, 'hPointsText')),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              tab(null, lt(locale, 'hAll')),
              for (final entry in _sources.entries) tab(entry.key, lt(locale, entry.value.$2)),
            ]),
          ),
          const SizedBox(height: 10),
          if (_logs.isEmpty && !_logsLoading) _empty(lt(locale, 'hNoPoints')),
          for (final log in _logs)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEF2F8)))),
              child: Row(
                children: [
                  LigaIconBox(icon: (_sources[log['source']]?.$1) ?? Icons.bar_chart_rounded, size: 38),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lt(locale, _sources[log['source']]?.$2 ?? 'hAll'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: LigaColors.ink)),
                        Text('${fmtDateTime(log['created_at'])} · ${ltf(locale, 'season', log['season'])}',
                            style: const TextStyle(fontSize: 11.5, color: LigaColors.muted)),
                      ],
                    ),
                  ),
                  Text('+${log['points']}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                ],
              ),
            ),
          if (_logsLoading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Center(child: CircularProgressIndicator(color: LigaColors.primary, strokeWidth: 2.4)),
            )
          else if (_hasMore)
            Center(
              child: TextButton(
                onPressed: () => _loadLogs(),
                child: Text(lt(locale, 'hMore'), style: const TextStyle(fontWeight: FontWeight.w700, color: LigaColors.primary)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _empty(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(14)),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, color: LigaColors.muted)),
      );
}

String _mmss(dynamic seconds) {
  if (seconds == null) return '—';
  final s = asInt(seconds);
  return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}
