import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/constants.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/top_notification.dart';
import '../../injector_container.dart';
import '../role_shell/role_shell_page.dart';
import 'parent_home_page.dart';
import 'parent_texts.dart';

const _gradeTones = [
  (Color(0xFF0284C7), Color(0xFFE0F2FE)),
  (Color(0xFF16A34A), Color(0xFFDCFCE7)),
  (Color(0xFFEA580C), Color(0xFFFFEDD5)),
  (Color(0xFF7C3AED), Color(0xFFEDE9FE)),
  (Color(0xFF4F46E5), Color(0xFFE0E7FF)),
];

/// "17/09/2026 13:28" -> vaqt belgisi (saralash uchun)
int _timestamp(dynamic value) {
  final text = '${value ?? ''}'.trim();
  if (text.isEmpty) return 0;
  final parts = text.split(' ');
  final d = parts[0].split('/').map((e) => int.tryParse(e) ?? 0).toList();
  final t = (parts.length > 1 ? parts[1] : '00:00').split(':').map((e) => int.tryParse(e) ?? 0).toList();
  if (d.length < 3) return 0;
  return DateTime(d[2], d[1], d[0], t.isNotEmpty ? t[0] : 0, t.length > 1 ? t[1] : 0).millisecondsSinceEpoch;
}

/// Ota-ona: Farzandlarim (saytdagi dashboard/parent/my-children)
class ParentChildrenPage extends StatefulWidget {
  const ParentChildrenPage({super.key});

  @override
  State<ParentChildrenPage> createState() => _ParentChildrenPageState();
}

class _ParentChildrenPageState extends State<ParentChildrenPage> {
  final Dio _dio = sl<Dio>();
  List<Map<String, dynamic>>? _children;
  bool _error = false;
  String _search = '';
  String _filter = 'all';
  String _sort = 'login';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = false);
    try {
      final res = await _dio.get('${Constants.baseUrl}/auth/parent/confirm-child/list/');
      final data = res.data is Map ? (res.data['data'] ?? res.data['results']) : res.data;
      if (mounted) setState(() => _children = asMapList(data));
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  bool _active(Map<String, dynamic> c) => c['status'] == true;

  List<Map<String, dynamic>> _visible(String locale) {
    final query = _search.trim().toLowerCase();
    final list = (_children ?? []).where((c) {
      if (_filter == 'active' && !_active(c)) return false;
      if (_filter == 'inactive' && _active(c)) return false;
      if (query.isEmpty) return true;
      return [c['full_name'], c['identification'], c['class_num'], c['subject_name_uz'], c['subject_name_ru']]
          .where((v) => v != null)
          .any((v) => '$v'.toLowerCase().contains(query));
    }).toList();
    switch (_sort) {
      case 'login':
        list.sort((a, b) => _timestamp(b['last_login_time']).compareTo(_timestamp(a['last_login_time'])));
      case 'name':
        list.sort((a, b) => '${a['full_name']}'.compareTo('${b['full_name']}'));
      case 'class':
        list.sort((a, b) => asInt(b['class_num']).compareTo(asInt(a['class_num'])));
      case 'days':
        list.sort((a, b) => asInt(b['remaining_days']).compareTo(asInt(a['remaining_days'])));
    }
    return list;
  }

  Future<void> _add() async {
    if (await showAddChild(context)) _load();
  }

  Future<void> _remove(Map<String, dynamic> child, String locale) async {
    final ok = await confirmDash(
      context,
      title: pt(locale, 'removeTitle'),
      message: pt(locale, 'removeText', {'name': child['full_name']}),
      confirmLabel: pt(locale, 'remove'),
      cancelLabel: pt(locale, 'cancel'),
      icon: Icons.person_remove_alt_1_rounded,
    );
    if (!ok) return;
    try {
      await _dio.delete('${Constants.baseUrl}/auth/parent/children/${child['id']}/');
      if (mounted) TopNotification.showSuccess(context, message: pt(locale, 'removed'));
      _load();
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
      TopNotification.showError(context, message: '${detail ?? pt(locale, 'genericError')}');
    }
  }

  Future<void> _certificate(Map<String, dynamic> child, String locale) async {
    try {
      final res = await _dio.post<List<int>>(
        '${Constants.baseUrl}/func_student/certificate/download/',
        data: {'student_id': child['id']},
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) throw Exception('empty');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Certificate_${child['id']}.pdf');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], title: '${child['full_name']}'));
    } catch (_) {
      if (mounted) TopNotification.showError(context, message: pt(locale, 'certificateError'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = currentLocale(context);
    final children = _children;
    final visible = _visible(locale);
    final counts = {
      'all': children?.length ?? 0,
      'active': children?.where(_active).length ?? 0,
      'inactive': children?.where((c) => !_active(c)).length ?? 0,
    };

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
              HeroBanner(
                image: parentHeroImage,
                alignment: const Alignment(0.7, 0.2),
                child: SizedBox(
                  height: 108,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(pt(locale, 'childrenTitle'),
                          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: DashColors.navy)),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(pt(locale, 'childrenSubtitle'),
                            style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF475569))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DashSearchField(hint: pt(locale, 'search'), onChanged: (v) => setState(() => _search = v)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final tab in [
                      ('all', pt(locale, 'all'), DashColors.primary, const Color(0xFFF1F5FF), const Color(0xFFDCE8FF)),
                      ('active', pt(locale, 'active'), DashColors.green, const Color(0xFFE7F8EE), const Color(0xFFBBF7D0)),
                      ('inactive', pt(locale, 'inactive'), DashColors.red, const Color(0xFFFEECEC), const Color(0xFFFECACA)),
                    ]) ...[
                      _FilterChip(
                        label: tab.$2,
                        count: counts[tab.$1] ?? 0,
                        color: tab.$3,
                        idle: tab.$4,
                        selectedColor: tab.$5,
                        selected: _filter == tab.$1,
                        onTap: () => setState(() => _filter = tab.$1),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: MiniSelect<String>(
                        value: _sort,
                        icon: Icons.swap_vert_rounded,
                        onChanged: (v) => setState(() => _sort = v),
                        options: [
                          SelectOption('login', pt(locale, 'sortLogin')),
                          SelectOption('name', pt(locale, 'sortName')),
                          SelectOption('class', pt(locale, 'sortClass')),
                          SelectOption('days', pt(locale, 'sortDays')),
                        ],
                      ),
                    ),
                  ),
                  DashButton(label: pt(locale, 'addChild'), icon: Icons.add_rounded, height: 38, onTap: _add),
                ],
              ),
              const SizedBox(height: 14),
              if (_error && children == null)
                ErrorRetry(message: pt(locale, 'loadError'), retryLabel: pt(locale, 'retry'), onRetry: _load)
              else if (children == null)
                ...[for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 190))]
              else if (children.isEmpty)
                DashCard(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 26),
                  child: Column(
                    children: [
                      const IconBox(
                          icon: Icons.person_add_alt_1_rounded,
                          color: DashColors.primary,
                          background: DashColors.primarySoft,
                          size: 64,
                          radius: 32),
                      const SizedBox(height: 14),
                      Text(pt(locale, 'emptyTitle'),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: DashColors.ink)),
                      const SizedBox(height: 4),
                      Text(pt(locale, 'emptyText'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: DashColors.muted)),
                      const SizedBox(height: 16),
                      DashButton(label: pt(locale, 'addChild'), icon: Icons.add_rounded, onTap: _add),
                    ],
                  ),
                )
              else if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(pt(locale, 'notFound'),
                      textAlign: TextAlign.center, style: const TextStyle(color: DashColors.muted)),
                )
              else ...[
                for (final child in visible) ...[
                  _ChildCard(
                    child: child,
                    locale: locale,
                    onOpen: () => openChildPage(context, child['id'], '${child['full_name'] ?? ''}'),
                    onCertificate: () => _certificate(child, locale),
                    onRemove: () => _remove(child, locale),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(pt(locale, 'total', {'n': visible.length}),
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: DashColors.muted)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.idle,
    required this.selectedColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final Color idle;
  final Color selectedColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding: const EdgeInsets.only(left: 16, right: 6),
        decoration: BoxDecoration(
          color: selected ? selectedColor : idle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 24),
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.locale,
    required this.onOpen,
    required this.onCertificate,
    required this.onRemove,
  });

  final Map<String, dynamic> child;
  final String locale;
  final VoidCallback onOpen;
  final VoidCallback onCertificate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = '${child['full_name'] ?? ''}';
    final active = child['status'] == true;
    final grade = '${child['class_num'] ?? ''}';
    final subject = locale == 'ru'
        ? '${child['subject_name_ru'] ?? child['subject_name_uz'] ?? ''}'
        : '${child['subject_name_uz'] ?? ''}';
    final login = '${child['last_login_time'] ?? ''}'.trim();
    final days = asInt(child['remaining_days']);
    final subEnd = '${child['subscription_end_date'] ?? ''}'.trim();
    final tone = _gradeTones[asInt(grade) % _gradeTones.length];
    final subjectTone = subjectColor('${child['subject_name_uz']}');

    return DashCard(
      padding: const EdgeInsets.all(14),
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InitialsAvatar(name: name, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: DashColors.ink)),
                    Text('ID: ${child['identification'] ?? '—'}',
                        style: const TextStyle(fontSize: 12, color: DashColors.muted)),
                  ],
                ),
              ),
              Pill(
                text: pt(locale, active ? 'active' : 'inactive'),
                dot: true,
                color: active ? DashColors.green : DashColors.red,
                background: active ? DashColors.greenSoft : DashColors.redSoft,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (grade.isNotEmpty)
                Pill(text: pt(locale, 'grade', {'grade': grade}), color: tone.$1, background: tone.$2, fontSize: 12),
              if (subject.isNotEmpty)
                Pill(
                  text: subject,
                  icon: subjectIcon('${child['subject_name_uz']}'),
                  color: subjectTone,
                  background: subjectTone.withValues(alpha: 0.1),
                  fontSize: 12,
                ),
              if (child['has_phone'] == false)
                Pill(
                  text: pt(locale, 'noPhone'),
                  icon: Icons.smartphone_rounded,
                  color: const Color(0xFFB45309),
                  background: const Color(0xFFFEF3C7),
                  fontSize: 12,
                ),
            ],
          ),
          Container(height: 1, color: DashColors.line, margin: const EdgeInsets.symmetric(vertical: 12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Info(label: pt(locale, 'colLastLogin'), value: login.isEmpty ? '—' : login),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Info(label: pt(locale, 'colSubEnd'), value: subEnd.isEmpty ? '—' : subEnd),
                    if (days > 0) ...[
                      const SizedBox(height: 4),
                      Pill(
                        text: pt(locale, 'daysLeftShort', {'n': days}),
                        color: DashColors.green,
                        background: DashColors.greenSoft,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DashButton(
                  label: pt(locale, 'details'),
                  icon: Icons.visibility_rounded,
                  color: DashColors.primarySoft,
                  textColor: DashColors.primary,
                  height: 42,
                  onTap: onOpen,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (v) => v == 'cert' ? onCertificate() : onRemove(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'cert',
                    child: Row(children: [
                      const Icon(Icons.download_rounded, size: 18, color: DashColors.primary),
                      const SizedBox(width: 10),
                      Text(pt(locale, 'certificate'), style: const TextStyle(fontSize: 13.5)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(children: [
                      const Icon(Icons.person_remove_alt_1_rounded, size: 18, color: DashColors.red),
                      const SizedBox(width: 10),
                      Text(pt(locale, 'remove'), style: const TextStyle(fontSize: 13.5, color: DashColors.red)),
                    ]),
                  ),
                ],
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5EAF2)),
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: DashColors.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: DashColors.muted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: DashColors.ink)),
      ],
    );
  }
}
