import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/constants.dart';
import '../../core/app_bloc/app_bloc.dart';
import '../../core/device/device_model.dart';
import '../../core/device/device_widgets.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/soft_back_button.dart';
import '../../core/widgets/top_notification.dart';
import '../../injector_container.dart';
import '../profile/presentation/pages/payments_page.dart';
import 'extend_subscription_sheet.dart';
import 'parent_home_page.dart';
import 'parent_texts.dart';

class ParentChildArgs {
  const ParentChildArgs({required this.id, required this.name});

  final int id;
  final String name;
}

const _tabs = [
  ('overview', Icons.home_rounded),
  ('subjects', Icons.menu_book_rounded),
  ('payments', Icons.credit_card_rounded),
  ('devices', Icons.devices_rounded),
  ('achievements', Icons.workspace_premium_rounded),
];

/// Ota-ona: farzand sahifasi (saytdagi dashboard/parent/my-children/[id])
class ParentChildPage extends StatefulWidget {
  const ParentChildPage({super.key, required this.args});

  final ParentChildArgs args;

  @override
  State<ParentChildPage> createState() => _ParentChildPageState();
}

class _ParentChildPageState extends State<ParentChildPage> {
  final Dio _dio = sl<Dio>();
  Map<String, dynamic>? _data;
  bool _error = false;
  String _tab = 'overview';

  String get _base => '${Constants.baseUrl}/func_student/parent/children/${widget.args.id}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = false);
    try {
      final res = await _dio.get('$_base/overview/');
      if (mounted) setState(() => _data = asMap(res.data));
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  void _extend() => showExtendSubscription(context, childId: widget.args.id);

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppBloc>().state.appLocale ?? 'uz';
    final data = _data;
    final profile = asMap(data?['profile']);

    return Scaffold(
      backgroundColor: DashColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: DashColors.primary,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
            children: [
              DashPageTitle(
                leading: const SoftBackButton(size: 46),
                title: pt(locale, 'myChildren'),
                subtitle: _tab == 'overview' ? null : pt(locale, 'tab_$_tab'),
              ),
              const SizedBox(height: 14),
              if (_error && data == null)
                ErrorRetry(message: pt(locale, 'loadError'), retryLabel: pt(locale, 'retry'), onRetry: _load)
              else if (data == null) ...[
                const SkeletonBox(height: 250, radius: 24, color: Color(0xFFEAF1FF)),
                const SizedBox(height: 12),
                const SkeletonBox(height: 170),
                const SizedBox(height: 12),
                const TwoColumnGrid(children: [SkeletonBox(height: 120), SkeletonBox(height: 120)]),
              ] else ...[
                _ChildHero(profile: profile, locale: locale),
                const SizedBox(height: 12),
                _SubscriptionHero(
                  sub: data['subscription'] is Map ? asMap(data['subscription']) : null,
                  locale: locale,
                  onExtend: _extend,
                  onDetails: () => setState(() => _tab = 'payments'),
                ),
                const SizedBox(height: 14),
                _TabBar(current: _tab, locale: locale, onTap: (t) => setState(() => _tab = t)),
                const SizedBox(height: 14),
                ..._tabContent(data, locale),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _tabContent(Map<String, dynamic> data, String locale) {
    final subjects = asMapList(data['subjects']);
    final chapters = asMapList(data['chapters']);
    switch (_tab) {
      case 'subjects':
        return [
          _SubjectResults(items: subjects, locale: locale),
          const SizedBox(height: 14),
          _ChaptersCard(items: chapters, locale: locale),
        ];
      case 'payments':
        return [_PaymentsTab(childId: widget.args.id, locale: locale, onExtend: _extend)];
      case 'devices':
        return [
          _DevicesTab(
            childId: widget.args.id,
            devices: asMapList(data['devices']),
            locale: locale,
            onChanged: _load,
          ),
        ];
      case 'achievements':
        return [
          AchievementsCard(
            items: asMapList(data['achievements']),
            locale: locale,
            childName: '${asMap(data['profile'])['full_name'] ?? ''}',
          ),
        ];
      default:
        final devices = asMapList(data['devices']);
        return [
          _ChildStats(stats: asMap(data['stats']), locale: locale),
          const SizedBox(height: 14),
          _SubjectResults(
            items: subjects,
            locale: locale,
            limit: 3,
            onViewAll: () => setState(() => _tab = 'subjects'),
          ),
          const SizedBox(height: 14),
          _ChaptersCard(items: chapters, locale: locale),
          const SizedBox(height: 14),
          RecentCard(items: asMapList(data['recent']), locale: locale),
          const SizedBox(height: 14),
          ActivityChartCard(days: asMapList(data['activity_days']), locale: locale),
          const SizedBox(height: 14),
          _SubscriptionSummary(
            sub: data['subscription'] is Map ? asMap(data['subscription']) : null,
            payments: asMap(data['payments']),
            locale: locale,
            onViewAll: () => setState(() => _tab = 'payments'),
          ),
          const SizedBox(height: 14),
          _DevicesCard(
            items: devices.take(4).toList(),
            locale: locale,
            onViewAll: devices.isEmpty ? null : () => setState(() => _tab = 'devices'),
          ),
        ];
    }
  }
}

/* ------------------------------------------------------------------ */
/* Yuqori qism                                                        */
/* ------------------------------------------------------------------ */

class _ChildHero extends StatelessWidget {
  const _ChildHero({required this.profile, required this.locale});

  final Map<String, dynamic> profile;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final name = '${profile['full_name'] ?? ''}';
    final grade = '${profile['class_name'] ?? ''}';
    final active = profile['is_active'] == true;
    return HeroBanner(
      image: parentHeroImage,
      alignment: const Alignment(0.65, 0),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: InitialsAvatar(name: name, size: 70, ring: false),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, height: 1.15, fontWeight: FontWeight.w800, color: DashColors.navy)),
                    const SizedBox(height: 3),
                    Text(
                      '${grade.isNotEmpty ? '${pt(locale, 'grade', {'grade': grade})} • ' : ''}ID: ${profile['identification'] ?? '—'}',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Pill(
                          text: pt(locale, active ? 'activeStudent' : 'inactiveStudent'),
                          icon: Icons.verified_rounded,
                          color: active ? DashColors.green : DashColors.muted,
                          background: active ? DashColors.greenSoft : const Color(0xFFF1F5F9),
                        ),
                        if (profile['has_phone'] == false)
                          Pill(
                            text: pt(locale, 'noPhone'),
                            icon: Icons.smartphone_rounded,
                            color: const Color(0xFFB45309),
                            background: const Color(0xFFFEF3C7),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoChip(icon: Icons.calendar_month_rounded, label: pt(locale, 'registered'), value: fmtDate(profile['registered_at'])),
          const SizedBox(height: 8),
          _InfoChip(icon: Icons.schedule_rounded, label: pt(locale, 'lastLogin'), value: fmtDateTime(profile['last_login'])),
          const SizedBox(height: 8),
          _InfoChip(
            icon: Icons.insights_rounded,
            label: pt(locale, 'studyTime'),
            value: fmtDuration(profile['study_time_seconds'], locale),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, size: 21, color: DashColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: DashColors.muted)),
          ),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: DashColors.ink)),
        ],
      ),
    );
  }
}

double _elapsed(Map<String, dynamic>? sub) {
  if (sub == null) return 0;
  final total = asNum(sub['total_days']);
  if (total <= 0) return 0;
  return ((total - asNum(sub['days_left'])) / total * 100).clamp(0, 100).toDouble();
}

/// Obuna kartasi (bannerdan keyin): holat, tarif, qolgan kun, muddat chizig'i va tugmalar
class _SubscriptionHero extends StatelessWidget {
  const _SubscriptionHero({required this.sub, required this.locale, required this.onExtend, required this.onDetails});

  final Map<String, dynamic>? sub;
  final String locale;
  final VoidCallback onExtend;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final active = sub?['is_active'] == true;
    final months = sub?['months'];
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, size: 32, color: DashColors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pt(locale, active ? 'activeSub' : 'noSub'),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active ? DashColors.green : DashColors.muted)),
                    Text(
                      months is num ? pt(locale, 'monthsPlan', {'n': months}) : pt(locale, 'plan'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: DashColors.navy),
                    ),
                  ],
                ),
              ),
              if (active)
                Pill(
                  text: pt(locale, 'daysLeft', {'n': asInt(sub?['days_left'])}),
                  color: DashColors.green,
                  background: DashColors.greenSoft,
                  fontSize: 12,
                ),
            ],
          ),
          if (sub != null) ...[
            const SizedBox(height: 14),
            ProgressLine(percent: _elapsed(sub), color: DashColors.primary),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fmtDate(sub!['start_date']), style: const TextStyle(fontSize: 11, color: DashColors.muted)),
                Text(fmtDate(sub!['end_date']), style: const TextStyle(fontSize: 11, color: DashColors.muted)),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: DashButton(label: pt(locale, 'extend'), onTap: onExtend, height: 42)),
              const SizedBox(width: 10),
              Expanded(
                child: DashButton(
                  label: pt(locale, 'details'),
                  color: DashColors.primarySoft,
                  textColor: DashColors.primary,
                  onTap: onDetails,
                  height: 42,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.current, required this.locale, required this.onTap});

  final String current;
  final String locale;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in _tabs) ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(tab.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: current == tab.$1 ? DashColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: current == tab.$1 ? DashColors.primary : const Color(0xFFE5EAF2)),
                ),
                child: Row(
                  children: [
                    Icon(tab.$2, size: 17, color: current == tab.$1 ? Colors.white : DashColors.muted),
                    const SizedBox(width: 6),
                    Text(
                      pt(locale, 'tab_${tab.$1}'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: current == tab.$1 ? Colors.white : DashColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Umumiy ma'lumot                                                    */
/* ------------------------------------------------------------------ */

class _ChildStats extends StatelessWidget {
  const _ChildStats({required this.stats, required this.locale});

  final Map<String, dynamic> stats;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final activity = asMap(stats['activity']);
    final subjects = asMap(stats['subjects']);
    final tests = asMap(stats['tests']);
    final correct = asMap(stats['correct']);
    num? delta(Map m) => m['delta'] is num ? m['delta'] : null;
    return Column(
      children: [
        TwoColumnGrid(
          children: [
            StatTile(
              icon: Icons.calendar_month_rounded,
              color: DashColors.purple,
              soft: DashColors.purpleSoft,
              label: pt(locale, 'activity'),
              value: '${asInt(activity['percent'])}%',
              delta: delta(activity),
              deltaSuffix: '%',
              footer: pt(locale, 'vsLastMonth'),
            ),
            StatTile(
              icon: Icons.menu_book_rounded,
              color: DashColors.green,
              soft: const Color(0xFFE7F8EE),
              label: pt(locale, 'subjectsStudied'),
              value: '${asInt(subjects['studied'])} / ${asInt(subjects['total'])}',
              footer: pt(locale, 'allSubjectsActive'),
            ),
            StatTile(
              icon: Icons.assignment_turned_in_rounded,
              color: DashColors.primary,
              soft: DashColors.primarySoft,
              label: pt(locale, 'testsDone'),
              value: '${asInt(tests['count'])}',
              delta: delta(tests),
              footer: pt(locale, 'allTests'),
            ),
            StatTile(
              icon: Icons.track_changes_rounded,
              color: const Color(0xFFEF4444),
              soft: const Color(0xFFFEECEC),
              label: pt(locale, 'avgResult'),
              value: '${asInt(correct['percent'])}%',
              delta: delta(correct),
              deltaSuffix: '%',
              footer: pt(locale, 'avgResultSub'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StatTile(
          icon: Icons.schedule_rounded,
          color: DashColors.amber,
          soft: DashColors.amberSoft,
          label: pt(locale, 'studyTime'),
          value: fmtDuration(stats['study_time_30'], locale),
          footer: pt(locale, 'last30'),
        ),
      ],
    );
  }
}

class _SubjectResults extends StatelessWidget {
  const _SubjectResults({required this.items, required this.locale, this.limit, this.onViewAll});

  final List<Map<String, dynamic>> items;
  final String locale;
  final int? limit;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final shown = limit == null ? items : items.take(limit!).toList();
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.person_rounded,
            title: pt(locale, 'subjectResults'),
            trailing: onViewAll != null && items.length > (limit ?? 0)
                ? LinkButton(label: pt(locale, 'viewAll'), onTap: onViewAll!)
                : null,
          ),
          if (shown.isEmpty)
            EmptyNote(text: pt(locale, 'noData'))
          else
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _SubjectRow(item: shown[i], index: i, locale: locale),
            ],
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.item, required this.index, required this.locale});

  final Map<String, dynamic> item;
  final int index;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final color = subjectColor('${item['name_uz']}', index);
    final percent = asNum(item['percent']);
    final grade = '${item['class_name'] ?? ''}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashColors.line),
      ),
      child: Row(
        children: [
          IconBox(icon: subjectIcon('${item['name_uz']}'), color: color, background: color.withValues(alpha: 0.1), size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(pickLang(item, 'name', locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: DashColors.ink)),
                    ),
                    if (grade.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Pill(text: pt(locale, 'grade', {'grade': grade}), color: DashColors.primary, background: DashColors.primarySoft, fontSize: 10.5),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Pill(text: '${percent.round()}%', color: color, background: color.withValues(alpha: 0.1)),
                    const SizedBox(width: 8),
                    Expanded(child: ProgressLine(percent: percent, color: color)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${pt(locale, 'testsCount', {'n': asInt(item['tests'])})} • ${pt(locale, 'diagCount', {'n': asInt(item['diagnostics'])})}',
                  style: const TextStyle(fontSize: 11, color: DashColors.subtle),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text.rich(
                TextSpan(
                  text: '${asInt(item['completed_topics'])}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(text: ' / ${asInt(item['total_topics'])}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                style: const TextStyle(fontSize: 13, color: DashColors.ink),
              ),
              Text(pt(locale, 'topics'), style: const TextStyle(fontSize: 10.5, color: DashColors.subtle)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChaptersCard extends StatelessWidget {
  const _ChaptersCard({required this.items, required this.locale});

  final List<Map<String, dynamic>> items;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(icon: Icons.hub_rounded, title: pt(locale, 'chapters')),
          if (items.isEmpty)
            EmptyNote(text: pt(locale, 'noData'))
          else if (items.length >= 3) ...[
            RadarChart(
              items: [for (final c in items.take(8)) RadarItem(pickLang(c, 'name', locale), asNum(c['percent']))],
              height: 260,
            ),
            Container(height: 1, color: DashColors.line, margin: const EdgeInsets.symmetric(vertical: 10)),
            SubjectBars(items: items, locale: locale, single: true),
          ] else
            SubjectBars(items: items, locale: locale, single: true),
        ],
      ),
    );
  }
}

const _monthsUz = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun', 'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'];
const _monthsRu = ['Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'];

String monthShort(int month, String locale) => (locale == 'ru' ? _monthsRu : _monthsUz)[(month - 1).clamp(0, 11)];

/// O'quv faolligi (so'nggi 30 kun): kunlik / haftalik ustunlar
class ActivityChartCard extends StatefulWidget {
  const ActivityChartCard({super.key, required this.days, required this.locale});

  final List<Map<String, dynamic>> days;
  final String locale;

  @override
  State<ActivityChartCard> createState() => _ActivityChartCardState();
}

class _ActivityChartCardState extends State<ActivityChartCard> {
  String _mode = 'daily';

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    String label(dynamic iso) {
      final d = parseDate(iso);
      return d == null ? '' : '${d.day} ${monthShort(d.month, locale)}';
    }

    final points = <BarPoint>[];
    if (_mode == 'weekly') {
      for (var i = 0; i < widget.days.length; i += 7) {
        final chunk = widget.days.sublist(i, (i + 7).clamp(0, widget.days.length));
        points.add(BarPoint(
          pt(locale, 'weekLabel', {'n': points.length + 1}),
          chunk.fold<num>(0, (s, d) => s + asNum(d['count'])),
          tip: '${label(chunk.first['date'])} – ${label(chunk.last['date'])}',
        ));
      }
    } else {
      for (final d in widget.days) {
        points.add(BarPoint(label(d['date']), asNum(d['count'])));
      }
    }
    final hasData = points.any((p) => p.value > 0);

    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.bar_chart_rounded,
            title: pt(locale, 'learningActivity'),
            sub: pt(locale, 'learningActivitySub'),
            trailing: MiniSelect<String>(
              value: _mode,
              onChanged: (v) => setState(() => _mode = v),
              options: [
                SelectOption('daily', pt(locale, 'daily')),
                SelectOption('weekly', pt(locale, 'weekly')),
              ],
            ),
          ),
          if (!hasData)
            EmptyNote(text: pt(locale, 'noData'))
          else
            BarChart(
              points: points,
              labelEvery: _mode == 'weekly' ? 1 : 7,
              unit: pt(locale, 'solvedUnit'),
            ),
        ],
      ),
    );
  }
}

class _SubscriptionSummary extends StatelessWidget {
  const _SubscriptionSummary({required this.sub, required this.payments, required this.locale, required this.onViewAll});

  final Map<String, dynamic>? sub;
  final Map<String, dynamic> payments;
  final String locale;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final active = sub?['is_active'] == true;
    final months = sub?['months'];
    final som = pt(locale, 'som');
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.receipt_long_rounded,
            title: pt(locale, 'subPayments'),
            trailing: LinkButton(label: pt(locale, 'viewAll'), onTap: onViewAll),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: DashColors.line)),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, size: 26, color: DashColors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(months is num ? pt(locale, 'monthsPlan', {'n': months}) : pt(locale, 'plan'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: DashColors.ink)),
                          Text(
                            sub == null ? pt(locale, 'noSub') : '${fmtDate(sub!['start_date'])} – ${fmtDate(sub!['end_date'])}',
                            style: const TextStyle(fontSize: 11.5, color: DashColors.muted),
                          ),
                        ],
                      ),
                    ),
                    if (active)
                      Text(pt(locale, 'daysLeft', {'n': asInt(sub?['days_left'])}),
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: DashColors.green)),
                  ],
                ),
                if (sub != null) ...[
                  const SizedBox(height: 10),
                  ProgressLine(percent: _elapsed(sub), color: const Color(0xFF22C55E)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Kv(label: pt(locale, 'paidAmount'), value: '${fmtMoney(payments['last_amount'])} $som')),
              Expanded(child: _Kv(label: pt(locale, 'paidDate'), value: fmtDate(payments['last_date']))),
              Expanded(
                child: _Kv(label: pt(locale, 'nextPayment'), value: fmtDate(sub?['next_payment_date'] ?? sub?['end_date'])),
              ),
            ],
          ),
          Container(height: 1, color: DashColors.line, margin: const EdgeInsets.symmetric(vertical: 12)),
          Row(
            children: [
              Expanded(child: _Kv(label: pt(locale, 'totalPaid'), value: '${fmtMoney(payments['total_paid'])} $som')),
              Expanded(child: _Kv(label: pt(locale, 'paymentsCount'), value: '${asInt(payments['count'])}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Kv extends StatelessWidget {
  const _Kv({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: DashColors.muted)),
        const SizedBox(height: 2),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: DashColors.ink)),
      ],
    );
  }
}

class _DevicesCard extends StatelessWidget {
  const _DevicesCard({required this.items, required this.locale, this.onViewAll});

  final List<Map<String, dynamic>> items;
  final String locale;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.devices_rounded,
            title: pt(locale, 'devices'),
            trailing: onViewAll == null ? null : LinkButton(label: pt(locale, 'viewAll'), onTap: onViewAll!),
          ),
          if (items.isEmpty)
            EmptyNote(text: pt(locale, 'noDevices'))
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _DeviceRow(device: items[i], locale: locale),
            ],
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.device, required this.locale, this.onKick});

  final Map<String, dynamic> device;
  final String locale;
  final VoidCallback? onKick;

  @override
  Widget build(BuildContext context) {
    final active = device['is_active'] == true;
    final meta = [device['browser'], device['os'], device['ip_address']]
        .where((v) => v != null && '$v'.isNotEmpty)
        .join(' · ');
    return Row(
      children: [
        DeviceIcon(type: '${device['device_type'] ?? 'other'}', active: active),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${device['device_name'] ?? '—'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: DashColors.ink)),
              Text(meta.isEmpty ? '—' : meta,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: DashColors.muted)),
              Text('${pt(locale, 'devLastSeen')}: ${fmtDateTime(device['last_used_at'])}',
                  style: const TextStyle(fontSize: 11, color: DashColors.subtle)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Pill(
              text: pt(locale, active ? 'currentSession' : 'loggedOut'),
              color: active ? DashColors.green : DashColors.muted,
              background: active ? DashColors.greenSoft : const Color(0xFFF1F5F9),
            ),
            if (active && onKick != null) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onKick,
                child: Text(pt(locale, 'devKick'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DashColors.red)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/* ------------------------------------------------------------------ */
/* Qurilmalar tabi                                                    */
/* ------------------------------------------------------------------ */

class _DevicesTab extends StatelessWidget {
  const _DevicesTab({required this.childId, required this.devices, required this.locale, required this.onChanged});

  final int childId;
  final List<Map<String, dynamic>> devices;
  final String locale;
  final Future<void> Function() onChanged;

  Future<void> _kick(BuildContext context, Map<String, dynamic> device) async {
    final ok = await confirmDash(
      context,
      title: pt(locale, 'devConfirmTitle'),
      message: pt(locale, 'devConfirmText', {'name': device['device_name']}),
      confirmLabel: pt(locale, 'devKick'),
      cancelLabel: pt(locale, 'cancel'),
      icon: Icons.logout_rounded,
    );
    if (!ok || !context.mounted) return;
    try {
      await sl<Dio>().delete(
        '${Constants.baseUrl}/func_student/parent/children/$childId/devices/${device['id']}/',
      );
      if (context.mounted) TopNotification.showSuccess(context, message: pt(locale, 'devKicked'));
      await onChanged();
    } catch (_) {
      if (context.mounted) TopNotification.showError(context, message: pt(locale, 'devKickError'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = devices.where((d) => d['is_active'] == true).length;
    final items = devices.map(DeviceItem.fromJson).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _MiniStat(value: '${items.length}', label: pt(locale, 'devTotal'), color: DashColors.primary)),
            const SizedBox(width: 8),
            Expanded(child: _MiniStat(value: '$active', label: pt(locale, 'devActive'), color: DashColors.green)),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStat(value: '${items.length - active}', label: pt(locale, 'devRemoved'), color: DashColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: DashColors.primarySoft, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: DashColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(pt(locale, 'devLimit'),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DashCard(
          child: devices.isEmpty
              ? EmptyNote(text: '${pt(locale, 'noDevices')}\n${pt(locale, 'devEmptyHint')}', icon: Icons.devices_rounded)
              : Column(
                  children: [
                    for (var i = 0; i < devices.length; i++) ...[
                      if (i > 0) Container(height: 1, color: DashColors.line, margin: const EdgeInsets.symmetric(vertical: 12)),
                      _DeviceRow(device: devices[i], locale: locale, onKick: () => _kick(context, devices[i])),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: DashColors.muted)),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* To'lovlar tabi                                                     */
/* ------------------------------------------------------------------ */

class _PaymentsTab extends StatefulWidget {
  const _PaymentsTab({required this.childId, required this.locale, required this.onExtend});

  final int childId;
  final String locale;
  final VoidCallback onExtend;

  @override
  State<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<_PaymentsTab> {
  Map<String, dynamic>? _data;
  bool _error = false;
  int _months = 6;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = false);
    try {
      final res = await sl<Dio>().get(
        '${Constants.baseUrl}/func_student/parent/children/${widget.childId}/payments/',
        queryParameters: {'months': _months},
      );
      if (mounted) setState(() => _data = asMap(res.data));
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    if (_error && _data == null) {
      return ErrorRetry(message: pt(locale, 'loadError'), retryLabel: pt(locale, 'retry'), onRetry: _load);
    }
    final data = _data;
    if (data == null) {
      return const Column(children: [SkeletonBox(height: 150), SizedBox(height: 12), SkeletonBox(height: 220)]);
    }
    final current = data['current'] is Map ? asMap(data['current']) : null;
    final summary = asMap(data['summary']);
    final monthly = asMapList(data['monthly']);
    final history = asMapList(data['history']).map(PaymentRecord.fromHistory).toList();
    final som = pt(locale, 'som');
    final subjects = current == null
        ? ''
        : asMapList(current['subjects']).map((s) => pickLang(s, 'name', locale)).where((s) => s.isNotEmpty).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Joriy tarif — ko'k gradient karta
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            boxShadow: [BoxShadow(color: DashColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFBBF24), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      current?['months'] is num ? pt(locale, 'monthsPlan', {'n': current!['months']}) : pt(locale, 'plan'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  Pill(
                    text: current?['is_active'] == true ? pt(locale, 'active') : pt(locale, 'noSub'),
                    color: Colors.white,
                    background: Colors.white.withValues(alpha: 0.18),
                  ),
                ],
              ),
              if (subjects.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(subjects, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
              ],
              if (current != null) ...[
                const SizedBox(height: 14),
                ProgressLine(
                  percent: _elapsed(current),
                  color: Colors.white,
                  track: Colors.white.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(fmtDate(current['start_date']), style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
                    Text(pt(locale, 'daysLeft', {'n': asInt(current['days_left'])}),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(fmtDate(current['end_date']), style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              DashButton(
                label: pt(locale, 'extend'),
                color: Colors.white,
                textColor: DashColors.primary,
                height: 42,
                onTap: widget.onExtend,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TwoColumnGrid(
          children: [
            StatTile(
              icon: Icons.account_balance_wallet_rounded,
              color: DashColors.green,
              soft: const Color(0xFFE7F8EE),
              label: pt(locale, 'totalPaid'),
              value: '${fmtMoney(summary['total_paid'])} $som',
            ),
            StatTile(
              icon: Icons.receipt_long_rounded,
              color: DashColors.primary,
              soft: DashColors.primarySoft,
              label: pt(locale, 'paymentsCount'),
              value: '${asInt(summary['success_count'])}',
            ),
            StatTile(
              icon: Icons.calendar_view_month_rounded,
              color: DashColors.purple,
              soft: DashColors.purpleSoft,
              label: pt(locale, 'monthly'),
              value: '${fmtMoney(summary['monthly_equivalent'])} $som',
            ),
            StatTile(
              icon: Icons.payments_rounded,
              color: DashColors.amber,
              soft: DashColors.amberSoft,
              label: pt(locale, 'lastAmount'),
              value: '${fmtMoney(summary['last_amount'])} $som',
              footer: [fmtDate(summary['last_date']), '${summary['last_gateway'] ?? ''}']
                  .where((s) => s.isNotEmpty && s != '—')
                  .join(' · '),
            ),
          ],
        ),
        if (monthly.any((m) => asNum(m['amount']) > 0)) ...[
          const SizedBox(height: 12),
          DashCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CardTitle(
                  icon: Icons.bar_chart_rounded,
                  title: pt(locale, 'payStats'),
                  trailing: MiniSelect<int>(
                    value: _months,
                    onChanged: (v) {
                      setState(() => _months = v);
                      _load();
                    },
                    options: [
                      SelectOption(6, locale == 'ru' ? 'Последние 6 мес.' : "So'nggi 6 oy"),
                      SelectOption(12, locale == 'ru' ? 'Последние 12 мес.' : "So'nggi 12 oy"),
                    ],
                  ),
                ),
                BarChart(
                  points: [
                    for (final m in monthly)
                      BarPoint(
                        monthShort(asInt(m['month']), locale),
                        (asNum(m['amount']) / 1000).round(),
                        tip: '${monthShort(asInt(m['month']), locale)} ${m['year']}',
                      ),
                  ],
                  labelEvery: _months == 12 ? 2 : 1,
                  unit: locale == 'ru' ? ' тыс. сум' : " ming so'm",
                  height: 140,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Text(pt(locale, 'payHistory'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: DashColors.ink)),
        const SizedBox(height: 10),
        if (history.isEmpty)
          DashCard(child: EmptyNote(text: pt(locale, 'payEmpty'), icon: Icons.receipt_long_rounded))
        else
          for (final item in history) ...[
            PaymentCard(item: item, locale: locale, onDetails: () => showPaymentReceipt(context, item, locale)),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}
