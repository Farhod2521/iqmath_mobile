import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/constants.dart';
import '../../core/widgets/dash_ui.dart';
import '../../injector_container.dart';
import '../../router/name_routes.dart';
import '../home/presentation/pages/home_parent/widget/add_child_dialog.dart';
import '../role_shell/role_shell_page.dart';
import 'parent_child_page.dart';
import 'parent_texts.dart';

const parentHeroImage = 'assets/images/parent_hero.webp';

/// Rasm manzili nisbiy bo'lsa — API domeni qo'shiladi
String absoluteImage(dynamic url) {
  final value = '${url ?? ''}';
  if (value.isEmpty || value.startsWith('http')) return value;
  return 'https://api.iqmath.uz${value.startsWith('/') ? '' : '/'}$value';
}

void openChildPage(BuildContext context, dynamic id, String name) {
  Navigator.of(context, rootNavigator: true).pushNamed(
    Routes.parentChild,
    arguments: ParentChildArgs(id: asInt(id), name: name),
  );
}

/// Farzand qo'shish oynasi; muvaffaqiyatli bo'lsa true qaytadi
Future<bool> showAddChild(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (_) => const AddChildDialog(),
  );
  return result == true;
}

/// Ota-ona bosh sahifasi: barcha ma'lumot bitta API'dan (parent/dashboard)
class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  final Dio _dio = sl<Dio>();
  Map<String, dynamic>? _data;
  bool _error = false;
  String _period = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = false);
    try {
      final res = await _dio.get(
        '${Constants.baseUrl}/func_student/parent/dashboard/',
        queryParameters: {'period': _period},
      );
      final body = asMap(res.data);
      if (body['summary'] == null) throw Exception('empty');
      if (mounted) setState(() => _data = body);
    } catch (_) {
      // Zaxira: dashboard ishlamasa farzandlar eski ro'yxat API'sidan olinadi
      try {
        final res = await _dio.get('${Constants.baseUrl}/auth/parent/confirm-child/list/');
        final list = asMapList(res.data is Map ? res.data['data'] : res.data);
        final subjects = <Map<String, dynamic>>[];
        for (final c in list) {
          final uz = c['subject_name_uz'];
          if (uz != null && !subjects.any((s) => s['name_uz'] == uz)) {
            subjects.add({'name_uz': uz, 'name_ru': c['subject_name_ru']});
          }
        }
        if (mounted) {
          setState(() => _data = {
                'summary': {
                  'children_count': list.length,
                  'subjects': subjects,
                  'activity': {'percent': 0},
                  'solved': {'count': 0},
                },
                'children': [
                  for (final c in list)
                    {
                      'id': c['id'],
                      'full_name': c['full_name'],
                      'class_name': c['class_num'],
                      'is_active': c['remaining_days'] is num ? c['remaining_days'] > 0 : c['status'] == true,
                      'subjects': [],
                    }
                ],
              });
        }
      } catch (_) {
        if (mounted && _data == null) setState(() => _error = true);
      }
    }
  }

  Future<void> _addChild() async {
    if (await showAddChild(context)) _load();
  }

  @override
  Widget build(BuildContext context) {
    final locale = currentLocale(context);
    final data = _data;
    return Scaffold(
      backgroundColor: DashColors.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: DashColors.primary,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              DashTopBar(greeting: pt(locale, 'welcome')),
              const SizedBox(height: 16),
              if (_error && data == null)
                ErrorRetry(message: pt(locale, 'loadError'), retryLabel: pt(locale, 'retry'), onRetry: _load)
              else if (data == null)
                ..._skeleton()
              else ...[
                _Hero(locale: locale),
                const SizedBox(height: 14),
                _Stats(summary: asMap(data['summary']), locale: locale),
                const SizedBox(height: 14),
                _ChildrenCard(items: asMapList(data['children']), locale: locale, onAdd: _addChild),
                const SizedBox(height: 14),
                _SubjectsResultCard(
                  items: asMapList(data['subjects_overall']),
                  locale: locale,
                  period: _period,
                  onPeriod: (value) {
                    setState(() => _period = value);
                    _load();
                  },
                ),
                const SizedBox(height: 14),
                RecentCard(items: asMapList(data['recent']), locale: locale, showChild: true),
                const SizedBox(height: 14),
                _TopTopicsCard(items: asMapList(data['top_topics']), locale: locale),
                const SizedBox(height: 14),
                AchievementsCard(
                  items: asMapList(data['achievements']),
                  locale: locale,
                  childName: asMap(data['achievements_child'])['full_name']?.toString(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _skeleton() => [
        const SkeletonBox(height: 230, radius: 24, color: Color(0xFFEAF1FF)),
        const SizedBox(height: 14),
        const TwoColumnGrid(children: [SkeletonBox(height: 120), SkeletonBox(height: 120)]),
        const SizedBox(height: 10),
        const TwoColumnGrid(children: [SkeletonBox(height: 120), SkeletonBox(height: 120)]),
        const SizedBox(height: 14),
        const SkeletonBox(height: 220),
      ];
}

class _Hero extends StatelessWidget {
  const _Hero({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return HeroBanner(
      image: parentHeroImage,
      alignment: const Alignment(0.75, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.62,
            child: Text(
              pt(locale, 'heroTitle'),
              style: const TextStyle(fontSize: 21, height: 1.2, fontWeight: FontWeight.w800, color: DashColors.navy),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.58,
            child: Text(
              pt(locale, 'heroText'),
              style: const TextStyle(fontSize: 12.5, height: 1.45, color: Color(0xFF475569)),
            ),
          ),
          const SizedBox(height: 14),
          DashButton(
            label: pt(locale, 'heroButton'),
            icon: Icons.arrow_forward_rounded,
            height: 42,
            onTap: () => RoleShell.of(context)?.goTo(1),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.summary, required this.locale});

  final Map<String, dynamic> summary;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final subjects = asMapList(summary['subjects']).map((s) => pickLang(s, 'name', locale)).toList();
    final activity = asMap(summary['activity']);
    final solved = asMap(summary['solved']);
    return TwoColumnGrid(
      children: [
        StatTile(
          icon: Icons.groups_rounded,
          color: DashColors.primary,
          soft: DashColors.primarySoft,
          label: pt(locale, 'childrenCount'),
          value: '${asInt(summary['children_count'])}',
          footerWidget: GestureDetector(
            onTap: () => RoleShell.of(context)?.goTo(1),
            child: Text(
              '${pt(locale, 'viewAll')} →',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DashColors.primary),
            ),
          ),
        ),
        StatTile(
          icon: Icons.menu_book_rounded,
          color: DashColors.green,
          soft: const Color(0xFFE7F8EE),
          label: pt(locale, 'subjectsCount'),
          value: '${subjects.length}',
          footer: subjects.isEmpty ? '—' : subjects.join(', '),
        ),
        StatTile(
          icon: Icons.track_changes_rounded,
          color: const Color(0xFFEF4444),
          soft: const Color(0xFFFEECEC),
          label: pt(locale, 'activity'),
          value: '${asInt(activity['percent'])}%',
          delta: activity['delta'] is num ? activity['delta'] : null,
          deltaSuffix: '%',
          footer: pt(locale, 'vsLastMonth'),
        ),
        StatTile(
          icon: Icons.event_available_rounded,
          color: DashColors.purple,
          soft: DashColors.purpleSoft,
          label: pt(locale, 'solved'),
          value: '${asInt(solved['count'])}',
          delta: solved['delta'] is num ? solved['delta'] : null,
          footer: pt(locale, 'last30'),
        ),
      ],
    );
  }
}

const _subjectTones = [DashColors.primary, Color(0xFF0EA5E9), Color(0xFF4F46E5)];

class _ChildrenCard extends StatelessWidget {
  const _ChildrenCard({required this.items, required this.locale, required this.onAdd});

  final List<Map<String, dynamic>> items;
  final String locale;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.groups_rounded,
            title: pt(locale, 'myChildren'),
            trailing: SizedBox(
              height: 36,
              child: DashButton(label: pt(locale, 'addChild'), icon: Icons.add_rounded, height: 36, onTap: onAdd),
            ),
          ),
          if (items.isEmpty)
            EmptyNote(text: pt(locale, 'noChildren'), icon: Icons.person_add_alt_1_rounded)
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ChildTile(child: items[i], locale: locale),
            ],
        ],
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({required this.child, required this.locale});

  final Map<String, dynamic> child;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final name = '${child['full_name'] ?? ''}';
    final active = child['is_active'] == true;
    final subjects = asMapList(child['subjects']);
    final className = '${child['class_name'] ?? ''}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          openChildPage(context, child['id'], name);
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3EBFA)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F8FF), Colors.white],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
                child: Row(
                  children: [
                    InitialsAvatar(name: name, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: DashColors.ink)),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (className.isNotEmpty)
                                Pill(
                                  text: pt(locale, 'grade', {'grade': className}),
                                  color: DashColors.primary,
                                  background: DashColors.primarySoft,
                                ),
                              Pill(
                                text: pt(locale, active ? 'active' : 'inactive'),
                                dot: true,
                                color: active ? DashColors.green : DashColors.muted,
                                background: active ? DashColors.greenSoft : const Color(0xFFF1F5F9),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: DashColors.subtle),
                  ],
                ),
              ),
              Container(height: 1, color: const Color(0xFFEEF2FA)),
              if (subjects.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(pt(locale, 'noSubjects'),
                        style: const TextStyle(fontSize: 12, color: DashColors.subtle)),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  child: Row(
                    children: [
                      for (var i = 0; i < subjects.length && i < 3; i++)
                        Expanded(
                          child: Column(
                            children: [
                              PercentRing(
                                percent: asNum(subjects[i]['percent']),
                                color: _subjectTones[i % _subjectTones.length],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pickLang(subjects[i], 'name', locale),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: DashColors.text),
                              ),
                            ],
                          ),
                        ),
                      for (var i = subjects.length; i < 3; i++) const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fanlar bo'yicha umumiy natija: 3+ fan bo'lsa radar, ostida barcha fanlar chiziqlari
class _SubjectsResultCard extends StatelessWidget {
  const _SubjectsResultCard({required this.items, required this.locale, required this.period, required this.onPeriod});

  final List<Map<String, dynamic>> items;
  final String locale;
  final String period;
  final ValueChanged<String> onPeriod;

  @override
  Widget build(BuildContext context) {
    final shown = items.take(6).toList();
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.hub_rounded,
            title: pt(locale, 'subjectsOverall'),
            trailing: MiniSelect<String>(
              value: period,
              onChanged: onPeriod,
              options: [
                SelectOption('month', pt(locale, 'thisMonth')),
                SelectOption('all', pt(locale, 'allTime')),
              ],
            ),
          ),
          if (shown.isEmpty)
            EmptyNote(text: pt(locale, 'noData'))
          else ...[
            if (shown.length >= 3) ...[
              RadarChart(
                items: [for (final s in shown) RadarItem(pickLang(s, 'name', locale), asNum(s['percent']))],
              ),
              Container(height: 1, color: DashColors.line, margin: const EdgeInsets.symmetric(vertical: 10)),
            ],
            SubjectBars(items: items, locale: locale),
          ],
        ],
      ),
    );
  }
}

/// Fan nomi + foiz + rangli chiziq
class SubjectBars extends StatelessWidget {
  const SubjectBars({super.key, required this.items, required this.locale, this.single = false});

  final List<Map<String, dynamic>> items;
  final String locale;
  final bool single;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          Builder(builder: (_) {
            final color = single ? DashColors.primary : subjectColor('${items[i]['name_uz']}', i);
            final percent = asNum(items[i]['percent']);
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(pickLang(items[i], 'name', locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: DashColors.text)),
                    ),
                    Text('${percent.round()}%',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
                  ],
                ),
                const SizedBox(height: 5),
                ProgressLine(percent: percent, color: color),
              ],
            );
          }),
        ],
      ],
    );
  }
}

const _recentStyle = {
  'login': (Icons.login_rounded, DashColors.green, Color(0xFFE7F8EE)),
  'topic_test': (Icons.assignment_rounded, DashColors.primary, DashColors.primarySoft),
  'diagnostic': (Icons.menu_book_rounded, DashColors.purple, DashColors.purpleSoft),
  'achievement': (Icons.emoji_events_rounded, DashColors.amber, DashColors.amberSoft),
};

/// So'nggi faoliyatlar (bosh sahifa va farzand sahifasi uchun)
class RecentCard extends StatelessWidget {
  const RecentCard({super.key, required this.items, required this.locale, this.showChild = false, this.limit = 5});

  final List<Map<String, dynamic>> items;
  final String locale;
  final bool showChild;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(icon: Icons.timeline_rounded, title: pt(locale, 'recent')),
          if (items.isEmpty)
            EmptyNote(text: pt(locale, 'noData'))
          else
            for (var i = 0; i < items.length && i < limit; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _recentRow(items[i]),
            ],
        ],
      ),
    );
  }

  Widget _recentRow(Map<String, dynamic> item) {
    final type = '${item['type']}';
    final style = _recentStyle[type] ?? _recentStyle['topic_test']!;
    final value = item['value'];
    final sub = [pickLang(item, 'title', locale), pickLang(item, 'subject', locale)]
        .where((s) => s.isNotEmpty)
        .join(' — ');
    final child = '${item['child'] ?? ''}'.split(' ').first;
    return Row(
      children: [
        IconBox(
          icon: type == 'topic_test' && value is num && value >= 80 ? Icons.check_circle_rounded : style.$1,
          color: style.$2,
          background: style.$3,
          size: 38,
          radius: 12,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: pt(locale, 'recent_$type'),
                  children: [
                    if (showChild && child.isNotEmpty)
                      TextSpan(
                        text: ' · $child',
                        style: const TextStyle(fontWeight: FontWeight.w500, color: DashColors.subtle),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DashColors.ink),
              ),
              if (sub.isNotEmpty)
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: DashColors.muted)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (value is num)
              Builder(builder: (_) {
                final colors = scoreColors(value);
                return Pill(text: '${value.round()}%', color: colors.$1, background: colors.$2);
              }),
            const SizedBox(height: 3),
            Text(fmtWhen(item['at'], locale), style: const TextStyle(fontSize: 10.5, color: DashColors.subtle)),
          ],
        ),
      ],
    );
  }
}

const _rankStyles = [
  (Color(0xFFD97706), Color(0xFFFEF3C7)),
  (DashColors.purple, Color(0xFFEDE9FE)),
  (DashColors.green, DashColors.greenSoft),
  (DashColors.primary, DashColors.primarySoft),
];

class _TopTopicsCard extends StatefulWidget {
  const _TopTopicsCard({required this.items, required this.locale});

  final List<Map<String, dynamic>> items;
  final String locale;

  @override
  State<_TopTopicsCard> createState() => _TopTopicsCardState();
}

class _TopTopicsCardState extends State<_TopTopicsCard> {
  String _subject = 'all';

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final subjects =
        widget.items.map((i) => pickLang(i, 'subject', locale)).where((s) => s.isNotEmpty).toSet().toList();
    final shown = widget.items
        .where((i) => _subject == 'all' || pickLang(i, 'subject', locale) == _subject)
        .take(4)
        .toList();
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.forum_rounded,
            title: pt(locale, 'topTopics'),
            trailing: subjects.isEmpty
                ? null
                : MiniSelect<String>(
                    value: _subject,
                    onChanged: (v) => setState(() => _subject = v),
                    options: [
                      SelectOption('all', pt(locale, 'allSubjects')),
                      for (final s in subjects) SelectOption(s, s),
                    ],
                  ),
          ),
          if (shown.isEmpty)
            EmptyNote(text: pt(locale, 'noData'))
          else
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: _rankStyles[i].$2, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _rankStyles[i].$1)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(pickLang(shown[i], 'topic', locale),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w700, color: DashColors.ink)),
                            ),
                            Text('${asNum(shown[i]['percent']).round()}%',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w800, color: DashColors.ink)),
                          ],
                        ),
                        Text(pickLang(shown[i], 'subject', locale),
                            style: const TextStyle(fontSize: 11, color: DashColors.subtle)),
                        const SizedBox(height: 5),
                        ProgressLine(
                          percent: asNum(shown[i]['percent']),
                          color: subjectColor('${shown[i]['subject_uz']}', i),
                          height: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}

/// Yutuqlar: 5 ta nishon, "Barchasini ko'rish" — to'liq ro'yxat oynasi
class AchievementsCard extends StatelessWidget {
  const AchievementsCard({super.key, required this.items, required this.locale, this.childName});

  final List<Map<String, dynamic>> items;
  final String locale;
  final String? childName;

  void _open(BuildContext context) {
    final earned = items.where((i) => i['earned'] == true).length;
    showDashSheet(
      context,
      title: childName != null && childName!.isNotEmpty
          ? pt(locale, 'achievementsOf', {'name': childName})
          : pt(locale, 'achievements'),
      subtitle: pt(locale, 'earned', {'count': earned, 'total': items.length}),
      icon: Icons.workspace_premium_rounded,
      iconColor: DashColors.amber,
      builder: (_) => GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 196,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          final got = item['earned'] == true;
          final desc = pickLang(item, 'description', locale);
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: got ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: got ? const Color(0xFFFDE68A) : DashColors.line),
            ),
            child: Column(
              children: [
                AchievementBadge(item: item, size: 60),
                const SizedBox(height: 8),
                Text(pickLang(item, 'title', locale),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: DashColors.ink)),
                if (desc.isNotEmpty)
                  Text(desc,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: DashColors.muted)),
                const Spacer(),
                if (!got) ...[
                  ProgressLine(percent: asNum(item['progress']), color: DashColors.primary, height: 5),
                  const SizedBox(height: 3),
                  Text('${asInt(item['value'])} / ${asInt(item['threshold'])}',
                      style: const TextStyle(fontSize: 10.5, color: DashColors.subtle)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.workspace_premium_rounded,
            title: pt(locale, 'achievements'),
            trailing: items.isEmpty ? null : LinkButton(label: pt(locale, 'viewAll'), onTap: () => _open(context)),
          ),
          if (items.isEmpty)
            EmptyNote(text: pt(locale, 'noAchievements'))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < 5; i++)
                  Expanded(
                    child: i < items.length
                        ? GestureDetector(
                            onTap: () => _open(context),
                            child: Column(
                              children: [
                                AchievementBadge(item: items[i], size: 52),
                                const SizedBox(height: 6),
                                Text(pickLang(items[i], 'title', locale),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 10.5, height: 1.15, fontWeight: FontWeight.w700, color: DashColors.text)),
                              ],
                            ),
                          )
                        : const SizedBox(),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({super.key, required this.item, this.size = 56});

  final Map<String, dynamic> item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final got = item['earned'] == true;
    final image = absoluteImage(item['image']);
    Widget badge = image.isEmpty
        ? IconBox(
            icon: Icons.workspace_premium_rounded,
            color: DashColors.primary,
            background: DashColors.primarySoft,
            size: size,
            radius: size / 3,
          )
        : Image.network(
            image,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => IconBox(
              icon: Icons.workspace_premium_rounded,
              color: DashColors.primary,
              background: DashColors.primarySoft,
              size: size,
              radius: size / 3,
            ),
          );
    if (!got) {
      badge = Opacity(
        opacity: 0.4,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.33, 0.33, 0.33, 0, 0, //
            0.33, 0.33, 0.33, 0, 0, //
            0.33, 0.33, 0.33, 0, 0, //
            0, 0, 0, 1, 0,
          ]),
          child: badge,
        ),
      );
    }
    return SizedBox(
      width: size + 6,
      height: size + 6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          badge,
          if (!got)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: DashColors.ink.withValues(alpha: 0.12), blurRadius: 6)],
                ),
                child: const Icon(Icons.lock_rounded, size: 12, color: DashColors.muted),
              ),
            ),
        ],
      ),
    );
  }
}
