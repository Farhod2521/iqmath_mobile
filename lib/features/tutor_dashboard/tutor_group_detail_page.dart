import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_bloc/app_bloc.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/soft_back_button.dart';
import '../../core/widgets/top_notification.dart';
import '../../injector_container.dart';
import 'tutor_groups_page.dart';
import 'tutor_texts.dart';

const _blue = Color(0xFF5D87FF);

/// O'qituvchi: guruh sahifasi (saytdagi dashboard/tutor/groups/[id])
class TutorGroupDetailPage extends StatefulWidget {
  const TutorGroupDetailPage({super.key, required this.groupId});

  final int groupId;

  @override
  State<TutorGroupDetailPage> createState() => _TutorGroupDetailPageState();
}

class _TutorGroupDetailPageState extends State<TutorGroupDetailPage> {
  final Dio _dio = sl<Dio>();
  Map<String, dynamic>? _group;
  List<Map<String, dynamic>> _invitations = [];
  bool _error = false;
  bool _notFound = false;
  final Set<int> _selected = {};

  String get _url => '$tutorBase/groups/${widget.groupId}/';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = false);
    try {
      final res = await _dio.get(_url);
      final group = asMap(res.data);
      List<Map<String, dynamic>> invitations = [];
      try {
        final inv = await _dio.get('${_url}invitations/');
        invitations = asMapList(inv.data);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _group = group;
        _invitations = invitations;
        final ids = asMapList(group['students']).map((s) => asInt(s['id'])).toSet();
        _selected.removeWhere((id) => !ids.contains(id));
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.response?.statusCode == 404) {
          _notFound = true;
        } else {
          _error = true;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  List<Map<String, dynamic>> get _students => asMapList(_group?['students']);

  Future<void> _mutate(Future<void> Function() action, String success, String locale) async {
    try {
      await action();
      if (mounted) TopNotification.showSuccess(context, message: tt(locale, success));
      _selected.clear();
      await _load();
    } catch (e) {
      if (mounted) TopNotification.showError(context, message: apiError(e, tt(locale, 'errorGeneric')));
    }
  }

  Future<void> _remove(List<Map<String, dynamic>> students, String locale) async {
    final ok = await confirmDash(
      context,
      title: tt(locale, 'removeFromGroup'),
      message: students.length == 1
          ? tt(locale, 'removeStudentConfirm', {'name': students.first['full_name']})
          : tt(locale, 'removeStudentsConfirm', {'count': students.length}),
      confirmLabel: tt(locale, 'remove'),
      cancelLabel: tt(locale, 'cancel'),
      icon: Icons.person_remove_alt_1_rounded,
    );
    if (!ok) return;
    await _mutate(
      () => _dio.delete('${_url}students/', data: {'student_ids': students.map((s) => s['id']).toList()}),
      'studentsRemoved',
      locale,
    );
  }

  Future<void> _move(List<Map<String, dynamic>> students, String locale) async {
    final target = await showDashSheet<int>(
      context,
      title: tt(locale, 'moveToGroup'),
      subtitle: students.map((s) => s['full_name']).join(', '),
      icon: Icons.swap_horiz_rounded,
      iconColor: _blue,
      builder: (_) => _MoveSheet(currentGroupId: widget.groupId, locale: locale),
    );
    if (target == null) return;
    await _mutate(
      () => _dio.post('$tutorBase/groups/$target/students/', data: {'student_ids': students.map((s) => s['id']).toList()}),
      'studentsMoved',
      locale,
    );
  }

  Future<void> _add(String locale) async {
    final ids = await showDashSheet<List<int>>(
      context,
      title: tt(locale, 'addStudents'),
      subtitle: '${_group?['name'] ?? ''}',
      icon: Icons.person_add_alt_1_rounded,
      iconColor: _blue,
      builder: (_) => _AddStudentsSheet(groupId: widget.groupId, locale: locale),
    );
    if (ids == null || ids.isEmpty) return;
    await _mutate(
      () => _dio.post('${_url}students/', data: {'student_ids': ids}),
      'studentsAdded',
      locale,
    );
  }

  Future<void> _invite(String locale) async {
    final sent = await showDashSheet<bool>(
      context,
      title: tt(locale, 'inviteStudent'),
      subtitle: tt(locale, 'inviteStudentSubtitle'),
      icon: Icons.person_search_rounded,
      iconColor: _blue,
      builder: (_) => _InviteSheet(groupId: widget.groupId, locale: locale),
    );
    if (sent == true) _load();
  }

  Future<void> _cancelInvite(Map<String, dynamic> invitation, String locale) async {
    try {
      await _dio.delete('$tutorBase/invitations/${invitation['id']}/');
      if (mounted) TopNotification.showSuccess(context, message: tt(locale, 'inviteCancelled'));
      _load();
    } catch (e) {
      if (mounted) TopNotification.showError(context, message: apiError(e, tt(locale, 'errorGeneric')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppBloc>().state.appLocale ?? 'uz';
    final group = _group;
    final students = _students;
    final selected = students.where((s) => _selected.contains(asInt(s['id']))).toList();
    final allSelected = students.isNotEmpty && selected.length == students.length;

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
                title: group == null ? '...' : '${group['name'] ?? ''}',
                subtitle: tt(locale, 'title'),
              ),
              const SizedBox(height: 14),
              if (_notFound)
                DashCard(child: EmptyNote(text: tt(locale, 'groupNotFound'), icon: Icons.groups_2_rounded))
              else if (_error && group == null)
                ErrorRetry(message: tt(locale, 'loadError'), retryLabel: tt(locale, 'retry'), onRetry: _load)
              else if (group == null) ...[
                const SkeletonBox(height: 170),
                const SizedBox(height: 12),
                const SkeletonBox(height: 260),
              ] else ...[
                _header(group, students.length, locale),
                if (selected.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _selectionBar(selected, locale),
                ],
                const SizedBox(height: 12),
                DashCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CardTitle(
                        icon: Icons.people_alt_rounded,
                        iconColor: _blue,
                        title: '${tt(locale, 'students')} (${students.length})',
                        trailing: students.isEmpty
                            ? null
                            : GestureDetector(
                                onTap: () => setState(() => allSelected
                                    ? _selected.clear()
                                    : _selected.addAll(students.map((s) => asInt(s['id'])))),
                                child: Text(
                                  tt(locale, allSelected ? 'deselectAll' : 'selectAll'),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _blue),
                                ),
                              ),
                      ),
                      if (students.isEmpty)
                        Column(
                          children: [
                            EmptyNote(
                              text: '${tt(locale, 'groupEmptyTitle')}\n${tt(locale, 'groupEmptyDescription')}',
                              icon: Icons.person_add_alt_1_rounded,
                            ),
                            DashButton(
                              label: tt(locale, 'addStudents'),
                              icon: Icons.person_add_alt_1_rounded,
                              color: _blue,
                              onTap: () => _add(locale),
                            ),
                          ],
                        )
                      else
                        for (var i = 0; i < students.length; i++) ...[
                          if (i > 0) Container(height: 1, color: const Color(0xFFF5F5F5)),
                          _studentRow(students[i], i, locale),
                        ],
                    ],
                  ),
                ),
                if (_invitations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DashCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CardTitle(icon: Icons.schedule_send_rounded, iconColor: _blue, title: tt(locale, 'pendingInvitations')),
                        for (var i = 0; i < _invitations.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          _invitationRow(_invitations[i], i, locale),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(Map<String, dynamic> group, int count, String locale) {
    final description = '${group['description'] ?? ''}'.trim();
    final created = '${group['created_at'] ?? ''}';
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconBox(icon: Icons.groups_2_rounded, color: _blue, background: const Color(0xFFEAF0FF), size: 54, radius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${group['name'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF191C1D))),
                    Text(description.isEmpty ? tt(locale, 'noDescription') : description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF8A8A8E))),
                    const SizedBox(height: 3),
                    Text(
                      '${tt(locale, 'studentsCount', {'count': count})}${created.isNotEmpty ? ' · $created' : ''}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5A6A85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DashButton(
            label: tt(locale, 'addStudents'),
            icon: Icons.person_add_alt_1_rounded,
            color: _blue,
            onTap: () => _add(locale),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DashButton(
                  label: tt(locale, 'inviteStudent'),
                  icon: Icons.person_search_rounded,
                  outlined: true,
                  textColor: _blue,
                  height: 42,
                  onTap: () => _invite(locale),
                ),
              ),
              const SizedBox(width: 8),
              _squareAction(Icons.edit_rounded, const Color(0xFF4968F4), const Color(0xFFEAF0FF), () async {
                if (await showGroupForm(context, group: group)) _load();
              }),
              const SizedBox(width: 8),
              _squareAction(Icons.delete_outline_rounded, DashColors.red, const Color(0xFFFEF2F2), () async {
                if (await deleteGroup(context, group) && mounted) Navigator.of(context).pop();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _squareAction(IconData icon, Color color, Color background, VoidCallback onTap) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: SizedBox(width: 42, height: 42, child: Icon(icon, color: color, size: 20)),
      ),
    );
  }

  Widget _selectionBar(List<Map<String, dynamic>> selected, String locale) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E2FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(tt(locale, 'selectedCount', {'count': selected.length}),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF191C1D))),
              ),
              GestureDetector(
                onTap: () => setState(_selected.clear),
                child: Text(tt(locale, 'cancel'),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF5A6A85))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DashButton(
                  label: tt(locale, 'move'),
                  icon: Icons.swap_horiz_rounded,
                  color: Colors.white,
                  textColor: _blue,
                  height: 40,
                  onTap: () => _move(selected, locale),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DashButton(
                  label: tt(locale, 'remove'),
                  icon: Icons.person_remove_alt_1_rounded,
                  color: Colors.white,
                  textColor: DashColors.red,
                  height: 40,
                  onTap: () => _remove(selected, locale),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentRow(Map<String, dynamic> student, int index, String locale) {
    final id = asInt(student['id']);
    final checked = _selected.contains(id);
    final meta = [
      'ID: ${student['identification'] ?? '—'}',
      fmtPhone(student['phone']),
      '${student['class_uz'] ?? ''}',
    ].where((s) => s.isNotEmpty).join(' · ');
    return InkWell(
      onTap: () => setState(() => checked ? _selected.remove(id) : _selected.add(id)),
      child: Container(
        color: checked ? const Color(0xFFF8FAFF) : null,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _Check(checked: checked),
            const SizedBox(width: 10),
            ColorAvatar(name: '${student['full_name']}', index: index),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${student['full_name'] ?? '—'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF191C1D))),
                  Text(meta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF5A6A85))),
                ],
              ),
            ),
            IconButton(
              tooltip: tt(locale, 'moveToGroup'),
              visualDensity: VisualDensity.compact,
              onPressed: () => _move([student], locale),
              icon: const Icon(Icons.swap_horiz_rounded, color: _blue, size: 21),
            ),
            IconButton(
              tooltip: tt(locale, 'removeFromGroup'),
              visualDensity: VisualDensity.compact,
              onPressed: () => _remove([student], locale),
              icon: const Icon(Icons.person_remove_alt_1_rounded, color: DashColors.red, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invitationRow(Map<String, dynamic> invitation, int index, String locale) {
    final student = asMap(invitation['student']);
    final phone = fmtPhone(student['phone']);
    return Row(
      children: [
        ColorAvatar(name: '${student['full_name']}', index: index),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${student['full_name'] ?? '—'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF191C1D))),
              Text('ID: ${student['identification'] ?? '—'}${phone.isNotEmpty ? ' · $phone' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF5A6A85))),
              const SizedBox(height: 3),
              Pill(
                text: tt(locale, 'waitingResponse'),
                icon: Icons.schedule_rounded,
                color: const Color(0xFFB45309),
                background: const Color(0xFFFEF3C7),
                fontSize: 10.5,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _cancelInvite(invitation, locale),
          icon: const Icon(Icons.close_rounded, color: DashColors.red),
        ),
      ],
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.checked, this.disabled = false});

  final bool checked;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? _blue : (disabled ? const Color(0xFFF1F5F9) : Colors.white),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: checked ? _blue : const Color(0xFFD1D5DB), width: 2),
      ),
      child: checked ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
    );
  }
}

/// O'quvchi qo'shish: o'qituvchining barcha o'quvchilari ro'yxatidan tanlash
class _AddStudentsSheet extends StatefulWidget {
  const _AddStudentsSheet({required this.groupId, required this.locale});

  final int groupId;
  final String locale;

  @override
  State<_AddStudentsSheet> createState() => _AddStudentsSheetState();
}

class _AddStudentsSheetState extends State<_AddStudentsSheet> {
  List<Map<String, dynamic>>? _students;
  final Set<int> _ids = {};
  String _search = '';

  @override
  void initState() {
    super.initState();
    sl<Dio>().get('$tutorBase/my-students/').then((res) {
      if (mounted) setState(() => _students = asMapList(res.data));
    }).catchError((_) {
      if (mounted) setState(() => _students = []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final students = _students;
    if (students == null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: _blue)),
      );
    }
    final query = _search.trim().toLowerCase();
    final filtered = students
        .where((s) =>
            query.isEmpty ||
            '${s['full_name']}'.toLowerCase().contains(query) ||
            '${s['identification']}'.toLowerCase().contains(query))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: DashSearchField(hint: tt(locale, 'searchStudent'), onChanged: (v) => setState(() => _search = v)),
        ),
        Flexible(
          child: filtered.isEmpty
              ? EmptyNote(text: tt(locale, students.isEmpty ? 'noStudentsYet' : 'noSearchResults'))
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Container(height: 1, color: const Color(0xFFF5F5F5)),
                  itemBuilder: (_, i) {
                    final s = filtered[i];
                    final id = asInt(s['id']);
                    final inThis = asInt(s['group_id']) == widget.groupId;
                    final checked = _ids.contains(id);
                    final groupName = '${s['group_name'] ?? ''}';
                    return InkWell(
                      onTap: inThis ? null : () => setState(() => checked ? _ids.remove(id) : _ids.add(id)),
                      child: Opacity(
                        opacity: inThis ? 0.55 : 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              _Check(checked: checked, disabled: inThis),
                              const SizedBox(width: 10),
                              ColorAvatar(name: '${s['full_name']}', index: i, size: 36),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${s['full_name'] ?? '—'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                                    Text(
                                      ['ID: ${s['identification'] ?? '—'}', '${s['class_uz'] ?? ''}']
                                          .where((v) => v.isNotEmpty)
                                          .join(' · '),
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF5A6A85)),
                                    ),
                                  ],
                                ),
                              ),
                              Pill(
                                text: inThis
                                    ? tt(locale, 'alreadyInGroup')
                                    : (groupName.isNotEmpty && s['group_id'] != null ? groupName : tt(locale, 'noGroup')),
                                color: inThis ? DashColors.green : const Color(0xFF5A6A85),
                                background: inThis ? DashColors.greenSoft : const Color(0xFFF1F5F9),
                                fontSize: 10.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Text(tt(locale, 'moveWarning'),
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A8A8E))),
              const SizedBox(height: 10),
              DashButton(
                label: '${tt(locale, 'addSelected')} (${_ids.length})',
                color: _blue,
                onTap: _ids.isEmpty ? null : () => Navigator.of(context).pop(_ids.toList()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Boshqa guruhga o'tkazish: guruh tanlanadi, tanlangan guruh id'si qaytariladi
class _MoveSheet extends StatefulWidget {
  const _MoveSheet({required this.currentGroupId, required this.locale});

  final int currentGroupId;
  final String locale;

  @override
  State<_MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends State<_MoveSheet> {
  List<Map<String, dynamic>>? _groups;
  int? _target;

  @override
  void initState() {
    super.initState();
    sl<Dio>().get('$tutorBase/groups/').then((res) {
      if (mounted) {
        setState(() => _groups =
            asMapList(res.data).where((g) => asInt(g['id']) != widget.currentGroupId).toList());
      }
    }).catchError((_) {
      if (mounted) setState(() => _groups = []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final groups = _groups;
    if (groups == null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: _blue)),
      );
    }
    if (groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: EmptyNote(text: tt(locale, 'noOtherGroups'), icon: Icons.groups_2_rounded),
      );
    }
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          GestureDetector(
            onTap: () => setState(() => _target = asInt(groups[i]['id'])),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _target == asInt(groups[i]['id']) ? const Color(0xFFF4F7FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _target == asInt(groups[i]['id']) ? _blue : const Color(0xFFE5EAF2),
                  width: _target == asInt(groups[i]['id']) ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  IconBox(
                    icon: Icons.groups_2_rounded,
                    color: groupTones[i % groupTones.length].$1,
                    background: groupTones[i % groupTones.length].$2,
                    size: 40,
                    radius: 12,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${groups[i]['name'] ?? ''}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        Text(tt(locale, 'studentsCount', {'count': asInt(groups[i]['student_count'])}),
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A8A8E))),
                      ],
                    ),
                  ),
                  Icon(
                    _target == asInt(groups[i]['id'])
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: _target == asInt(groups[i]['id']) ? _blue : DashColors.subtle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        DashButton(
          label: tt(locale, 'move'),
          icon: Icons.swap_horiz_rounded,
          color: _blue,
          onTap: _target == null ? null : () => Navigator.of(context).pop(_target),
        ),
      ],
    );
  }
}

/// Telefon yoki ID bo'yicha o'quvchini qidirib, guruhga taklif yuborish
class _InviteSheet extends StatefulWidget {
  const _InviteSheet({required this.groupId, required this.locale});

  final int groupId;
  final String locale;

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _query = TextEditingController();
  String _type = 'phone';
  bool _searching = false;
  bool _searched = false;
  bool _inviting = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _query.text.trim();
    if (query.isEmpty || _searching) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _searched = true;
    });
    try {
      final res = await sl<Dio>().get(
        '$tutorBase/students/search/',
        queryParameters: {'query': query, 'type': _type, 'group_id': widget.groupId},
      );
      if (mounted) setState(() => _result = asMap(res.data));
    } catch (e) {
      if (mounted) {
        setState(() => _result = null);
        final notFound = e is DioException && e.response?.statusCode == 404;
        if (!notFound) {
          TopNotification.showError(context, message: apiError(e, tt(widget.locale, 'errorGeneric')));
        }
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _send() async {
    final student = asMap(_result?['student']);
    if (student['id'] == null || _inviting) return;
    setState(() => _inviting = true);
    try {
      await sl<Dio>().post('$tutorBase/groups/${widget.groupId}/invitations/', data: {'student_id': student['id']});
      if (!mounted) return;
      TopNotification.showSuccess(context, message: tt(widget.locale, 'inviteSent'));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        TopNotification.showError(context, message: apiError(e, tt(widget.locale, 'errorGeneric')));
        setState(() => _inviting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final student = asMap(_result?['student']);
    final warning = '${_result?['warning'] ?? ''}';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF1F4FF), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                for (final tab in [('phone', tt(locale, 'searchByPhone')), ('identification', tt(locale, 'searchById'))])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _type = tab.$1;
                        _query.clear();
                        _result = null;
                        _searched = false;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _type == tab.$1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(tab.$2,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _type == tab.$1 ? _blue : const Color(0xFF8A8A8E),
                            )),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DashTextField(
                  controller: _query,
                  hint: tt(locale, _type == 'phone' ? 'searchPlaceholderPhone' : 'searchPlaceholderId'),
                  prefixText: _type == 'phone' ? '+998 ' : null,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              DashButton(
                label: tt(locale, 'search'),
                color: _blue,
                height: 48,
                loading: _searching,
                onTap: _search,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_searched && !_searching && student['id'] == null)
            EmptyNote(text: tt(locale, 'studentNotFound'), icon: Icons.person_off_rounded)
          else if (student['id'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5EAF2)),
              ),
              child: Row(
                children: [
                  ColorAvatar(name: '${student['full_name']}', index: 0, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${student['full_name'] ?? '—'}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        Text(
                          [
                            'ID: ${student['identification'] ?? '—'}',
                            fmtPhone(student['phone']),
                            '${student['class_uz'] ?? ''}',
                          ].where((v) => v.isNotEmpty).join(' · '),
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF5A6A85)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (warning.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                child: Text(warning, style: const TextStyle(fontSize: 12, color: Color(0xFFB45309))),
              ),
            ],
            const SizedBox(height: 12),
            DashButton(
              label: tt(locale, 'sendInvite'),
              icon: Icons.send_rounded,
              color: _blue,
              loading: _inviting,
              onTap: _result?['can_invite'] == false ? null : _send,
            ),
          ],
        ],
      ),
    );
  }
}
