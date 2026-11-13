import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_bloc/app_bloc.dart';
import '../../core/widgets/dash_ui.dart';
import '../../router/name_routes.dart';
import 'liga_api.dart';
import 'liga_texts.dart';
import 'liga_widgets.dart';

/// O'quvchi: mavsumlar (tugagan va joriy), sinf g'oliblari va haftalik test g'oliblari
/// (saytdagi /dashboard/student/liga/seasons bilan bir xil).
class LigaSeasonsPage extends StatefulWidget {
  const LigaSeasonsPage({super.key});

  @override
  State<LigaSeasonsPage> createState() => _LigaSeasonsPageState();
}

class _LigaSeasonsPageState extends State<LigaSeasonsPage> {
  Map<String, dynamic>? _list;
  Map<String, dynamic>? _result;
  int? _seasonId;
  int? _grade;
  bool _loading = true;
  bool _fetching = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    setState(() => _error = false);
    try {
      final list = await LigaApi.seasons();
      final seasons = asMapList(list['seasons']);
      if (!mounted) return;
      setState(() {
        _list = list;
        _loading = false;
        if (seasons.isNotEmpty) {
          // Avval tugagan oxirgi mavsum, bo'lmasa joriysi
          final first = seasons.firstWhere((s) => s['is_closed'] == true, orElse: () => seasons.first);
          _seasonId ??= asInt(first['id']);
        }
        if (_grade == null && list['grade_id'] != null) _grade = asInt(list['grade_id']);
      });
      if (_seasonId != null) await _loadResult();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  Future<void> _loadResult() async {
    final seasonId = _seasonId;
    if (seasonId == null) return;
    setState(() => _fetching = true);
    try {
      final result = await LigaApi.seasonResults(seasonId, _grade);
      if (!mounted || seasonId != _seasonId) return;
      setState(() => _result = result);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  void _pickSeason(int id) {
    if (id == _seasonId) return;
    setState(() => _seasonId = id);
    _loadResult();
  }

  void _pickGrade(int id) {
    if (id == _grade) return;
    setState(() => _grade = id);
    _loadResult();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<AppBloc, String>((b) => b.state.appLocale ?? 'uz');
    final result = _result;
    final body = _loading
        ? const Center(child: CircularProgressIndicator(color: LigaColors.primary))
        : RefreshIndicator(
            color: LigaColors.primary,
            onRefresh: _loadList,
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
        child: result?['viewer'] != null ? LigaWatermark(viewer: '${result!['viewer']}', child: body) : body,
      ),
    );
  }

  List<Widget> _content(String locale) {
    void back() => Navigator.of(context).maybePop();
    final hero = LigaHero(title: lt(locale, 'sTitle'), subtitle: lt(locale, 'sSub'), onBack: back);
    if (_error) {
      return [
        hero,
        const SizedBox(height: 60),
        Center(child: Text(lt(locale, 'error'), style: const TextStyle(color: LigaColors.red, fontSize: 15))),
        Center(child: TextButton(onPressed: _loadList, child: Text(lt(locale, 'retry')))),
      ];
    }
    final seasons = asMapList(_list?['seasons']);
    if (seasons.isEmpty) {
      return [hero, const SizedBox(height: 40), _empty(lt(locale, 'sNoSeasons'))];
    }
    final result = _result;
    final closed = asMap(result?['season'])['is_closed'] == true;
    final me = result?['me'] is Map ? asMap(result!['me']) : null;

    return [
      hero,
      const SizedBox(height: 14),
      _filters(locale, seasons),
      const SizedBox(height: 14),
      AnimatedOpacity(
        opacity: _fetching ? 0.6 : 1,
        duration: const Duration(milliseconds: 150),
        child: result == null
            ? const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: LigaColors.primary)),
              )
            : Column(
                children: [
                  _stats(locale, result, me),
                  const SizedBox(height: 14),
                  _winners(locale, result, closed),
                  const SizedBox(height: 14),
                  _weeks(locale, result),
                ],
              ),
      ),
    ];
  }

  Widget _filters(String locale, List<Map<String, dynamic>> seasons) {
    final grades = asMapList(_list?['grades']);
    return LigaCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final s in seasons)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _seasonChip(locale, s),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('${lt(locale, 'gradeLabel')}:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: LigaColors.muted)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final g in grades)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _gradeChip(g),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seasonChip(String locale, Map<String, dynamic> s) {
    final active = asInt(s['id']) == _seasonId;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _pickSeason(asInt(s['id'])),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? LigaColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? LigaColors.primary : LigaColors.rowBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, size: 20, color: active ? Colors.white : LigaColors.amber),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ltf(locale, 'season', s['number']),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: active ? Colors.white : LigaColors.ink)),
                Text(lt(locale, s['is_closed'] == true ? 'sClosed' : 'sLive'),
                    style: TextStyle(fontSize: 11.5, color: active ? Colors.white70 : LigaColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradeChip(Map<String, dynamic> g) {
    final active = asInt(g['id']) == _grade;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _pickGrade(asInt(g['id'])),
      child: Container(
        constraints: const BoxConstraints(minWidth: 42),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? LigaColors.primarySoft : LigaColors.soft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? LigaColors.primary : Colors.transparent),
        ),
        child: Text('${g['name'] ?? ''}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: active ? LigaColors.primary : LigaColors.text)),
      ),
    );
  }

  Widget _stats(String locale, Map<String, dynamic> result, Map<String, dynamic>? me) {
    final items = [
      (Icons.groups_rounded, LigaColors.primary, lt(locale, 'sParticipantsLabel'), '${result['participants_count'] ?? '—'}'),
      (Icons.emoji_events_outlined, LigaColors.amber, lt(locale, 'rank'), me?['rank'] != null ? '#${me!['rank']}' : '—'),
      (Icons.bar_chart_rounded, LigaColors.teal, lt(locale, 'points'), me != null ? '${me['points']}' : '—'),
    ];
    return LigaCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: Column(
                children: [
                  Icon(item.$1, color: item.$2, size: 26),
                  const SizedBox(height: 6),
                  Text(item.$4, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                  Text(item.$3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: LigaColors.muted)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _winners(String locale, Map<String, dynamic> result, bool closed) {
    final winners = asMapList(result['winners']);
    final grade = result['grade'];
    return LigaCard(
      child: Column(
        children: [
          LigaCardHead(
            icon: closed ? Icons.emoji_events_outlined : Icons.military_tech_outlined,
            title: lt(locale, closed ? 'sWinners' : 'sLeaders'),
            text: closed ? (grade != null ? ltf(locale, 'grade', grade) : null) : lt(locale, 'sLeadersText'),
          ),
          const SizedBox(height: 12),
          if (winners.isEmpty) _empty(lt(locale, 'sNoWinners')),
          for (final w in winners)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  LigaMedal(place: asInt(w['place'])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${w['full_name'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: w['is_disqualified'] == true ? const Color(0xFF94A3B8) : LigaColors.ink,
                              decoration: w['is_disqualified'] == true ? TextDecoration.lineThrough : null,
                            )),
                        Text(ltf(locale, 'ball', asInt(w['points'])),
                            style: const TextStyle(fontSize: 12, color: LigaColors.muted)),
                      ],
                    ),
                  ),
                  if (closed)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: Text(
                        w['is_disqualified'] == true ? lt(locale, 'disqualified') : '${w['prize_$locale'] ?? w['prize_uz'] ?? ''}',
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: LigaColors.muted),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _weeks(String locale, Map<String, dynamic> result) {
    final weeks = asMapList(result['weeks']);
    return LigaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LigaCardHead(icon: Icons.event_available_rounded, title: lt(locale, 'sWeeks'), text: lt(locale, 'sWeeksText')),
          const SizedBox(height: 12),
          if (weeks.isEmpty) _empty(lt(locale, 'sNoWeeks')),
          for (final w in weeks) _weekCard(locale, w),
        ],
      ),
    );
  }

  Widget _weekCard(String locale, Map<String, dynamic> week) {
    final finished = week['status'] == 'finished';
    final top = asMapList(week['top']);
    final my = week['my'] is Map ? asMap(week['my']) : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LigaColors.rowBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ltf(locale, 'sWeek', week['week_number']),
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                    const SizedBox(height: 2),
                    Text('${fmtDate(week['start_at'])} – ${fmtDate(week['end_at'])}',
                        style: const TextStyle(fontSize: 12, color: LigaColors.muted)),
                  ],
                ),
              ),
              if (finished)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: LigaColors.chip, borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.groups_outlined, size: 14, color: LigaColors.muted),
                    const SizedBox(width: 4),
                    Text(ltf(locale, 'sParticipants', week['participants'] ?? 0),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: LigaColors.muted)),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!finished)
            _empty(lt(locale, 'sNotFinished'))
          else if (top.isEmpty)
            _empty(lt(locale, 'sNoAttempts'))
          else
            for (final row in top)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    LigaMedal(place: asInt(row['rank']), size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${row['full_name'] ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: LigaColors.ink)),
                    ),
                    const Icon(Icons.schedule_rounded, size: 13, color: LigaColors.muted),
                    const SizedBox(width: 3),
                    Text(_mmss(row['duration_seconds']), style: const TextStyle(fontSize: 12, color: LigaColors.muted)),
                    const SizedBox(width: 8),
                    _scorePill('${row['score']}/${row['max_score']}'),
                  ],
                ),
              ),
          if (my != null)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pushNamed(Routes.ligaTest, arguments: asInt(my['attempt_id'])),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFD7FB)),
                ),
                child: Row(
                  children: [
                    Text('${lt(locale, 'sYou')}: #${my['rank']}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: LigaColors.primary)),
                    const Spacer(),
                    Text('${my['score']}/${my['max_score']}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: LigaColors.ink)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: LigaColors.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _scorePill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: LigaColors.primarySoft, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: LigaColors.primary)),
      );

  Widget _empty(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(14)),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13.5, color: LigaColors.muted)),
      );
}

String _mmss(dynamic seconds) {
  if (seconds == null) return '—';
  final s = asInt(seconds);
  return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}
