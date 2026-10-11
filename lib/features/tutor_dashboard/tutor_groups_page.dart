import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/constants.dart';
import '../../core/app_bloc/app_bloc.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/top_notification.dart';
import '../../injector_container.dart';
import '../../router/name_routes.dart';
import '../role_shell/role_shell_page.dart';
import 'tutor_texts.dart';

const tutorBase = '${Constants.baseUrl}/tutor/tutor';

const groupTones = [
  (Color(0xFF5D87FF), Color(0xFFEAF0FF)),
  (Color(0xFF7626FB), Color(0xFFF1E9FF)),
  (Color(0xFF0D875E), Color(0xFFE7F8EF)),
  (Color(0xFFF59E0B), Color(0xFFFFF3DD)),
  (Color(0xFFDB2777), Color(0xFFFCE7F3)),
];

const avatarColors = [
  Color(0xFF5D87FF),
  Color(0xFF8B5CF6),
  Color(0xFF22C55E),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
  Color(0xFF0EA5A5),
];

Color averageColor(num percent) {
  if (percent >= 75) return const Color(0xFF22C55E);
  if (percent >= 50) return const Color(0xFF5D87FF);
  return const Color(0xFFF59E0B);
}

/// Backend xato matni (saytdagi apiErrorMessage bilan bir xil tartibda)
String apiError(Object error, String fallback) {
  if (error is DioException && error.response?.data is Map) {
    final body = error.response!.data as Map;
    for (final key in ['error', 'detail', 'name', 'student_ids']) {
      final value = body[key];
      if (value is String && value.isNotEmpty) return value;
      if (value is List && value.isNotEmpty) return '${value.first}';
    }
  }
  return fallback;
}

/// Guruh sahifasini ochadi; qaytilganda Future tugaydi (ro'yxatni yangilash uchun)
Future<void> openGroupDetail(BuildContext context, dynamic id) async {
  await Navigator.of(context, rootNavigator: true).pushNamed(Routes.tutorGroupDetail, arguments: asInt(id));
}

/// Kichik dumaloq avatar (tartib raqamiga qarab rang)
class ColorAvatar extends StatelessWidget {
  const ColorAvatar({super.key, required this.name, required this.index, this.size = 38});

  final String? name;
  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: avatarColors[index % avatarColors.length], shape: BoxShape.circle),
      child: Text(initialsOf(name),
          style: TextStyle(fontSize: size * 0.32, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }
}

/// Guruh yaratish / tahrirlash oynasi. Saqlansa true qaytadi.
Future<bool> showGroupForm(BuildContext context, {Map<String, dynamic>? group}) async {
  final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
  final isEdit = group != null;
  final result = await showDashSheet<bool>(
    context,
    title: tt(locale, isEdit ? 'editGroup' : 'createGroup'),
    subtitle: isEdit ? '${group['name'] ?? ''}' : tt(locale, 'createGroupSubtitle'),
    icon: Icons.groups_2_rounded,
    iconColor: const Color(0xFF5D87FF),
    builder: (sheetContext) => _GroupForm(locale: locale, group: group),
  );
  return result == true;
}

class _GroupForm extends StatefulWidget {
  const _GroupForm({required this.locale, this.group});

  final String locale;
  final Map<String, dynamic>? group;

  @override
  State<_GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends State<_GroupForm> {
  late final _name = TextEditingController(text: '${widget.group?['name'] ?? ''}');
  late final _description = TextEditingController(text: '${widget.group?['description'] ?? ''}');
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final locale = widget.locale;
    final name = _name.text.trim();
    if (name.isEmpty) {
      TopNotification.showError(context, message: tt(locale, 'nameRequired'));
      return;
    }
    setState(() => _saving = true);
    final data = {'name': name, 'description': _description.text.trim()};
    try {
      if (widget.group != null) {
        await sl<Dio>().patch('$tutorBase/groups/${widget.group!['id']}/', data: data);
      } else {
        await sl<Dio>().post('$tutorBase/groups/', data: data);
      }
      if (!mounted) return;
      TopNotification.showSuccess(context, message: tt(locale, widget.group != null ? 'groupUpdated' : 'groupCreated'));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        TopNotification.showError(context, message: apiError(e, tt(locale, 'errorGeneric')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashTextField(
            controller: _name,
            label: '${tt(locale, 'groupName')} *',
            hint: tt(locale, 'groupNamePlaceholder'),
            autofocus: widget.group == null,
          ),
          const SizedBox(height: 14),
          DashTextField(
            controller: _description,
            label: tt(locale, 'groupDescription'),
            hint: tt(locale, 'groupDescriptionPlaceholder'),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DashButton(
                  label: tt(locale, 'cancel'),
                  color: const Color(0xFFF1F4FF),
                  textColor: const Color(0xFF5A6A85),
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashButton(
                  label: tt(locale, widget.group != null ? 'save' : 'create'),
                  color: const Color(0xFF5D87FF),
                  loading: _saving,
                  onTap: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Guruhni o'chirish (tasdiqlash bilan). O'chirilsa true qaytadi.
Future<bool> deleteGroup(BuildContext context, Map<String, dynamic> group) async {
  final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
  final ok = await confirmDash(
    context,
    title: tt(locale, 'deleteGroup'),
    message: tt(locale, 'deleteGroupConfirm', {'name': group['name']}),
    confirmLabel: tt(locale, 'delete'),
    cancelLabel: tt(locale, 'cancel'),
  );
  if (!ok) return false;
  try {
    await sl<Dio>().delete('$tutorBase/groups/${group['id']}/');
    if (context.mounted) TopNotification.showSuccess(context, message: tt(locale, 'groupDeleted'));
    return true;
  } catch (e) {
    if (context.mounted) TopNotification.showError(context, message: apiError(e, tt(locale, 'errorGeneric')));
    return false;
  }
}

/// O'qituvchi: Mening guruhlarim (saytdagi dashboard/tutor/groups)
class TutorGroupsPage extends StatefulWidget {
  const TutorGroupsPage({super.key});

  @override
  State<TutorGroupsPage> createState() => _TutorGroupsPageState();
}

class _TutorGroupsPageState extends State<TutorGroupsPage> {
  final Dio _dio = sl<Dio>();
  List<Map<String, dynamic>>? _groups;
  List<Map<String, dynamic>> _students = [];
  bool _error = false;
  String _search = '';
  int _shellIndex = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Bo'limga har safar qaytilganda ro'yxat yangilanadi
    final index = RoleShell.of(context)?.current ?? -1;
    if (index == 1 && _shellIndex != -1 && _shellIndex != 1) _load();
    _shellIndex = index;
  }

  Future<void> _load() async {
    setState(() => _error = false);
    try {
      final results = await Future.wait([
        _dio.get('$tutorBase/groups/'),
        _dio.get('$tutorBase/my-students/').catchError((_) => Response(requestOptions: RequestOptions(), data: [])),
      ]);
      if (!mounted) return;
      setState(() {
        _groups = asMapList(results[0].data);
        _students = asMapList(results[1].data);
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  Future<void> _create() async {
    if (await showGroupForm(context)) _load();
  }

  @override
  Widget build(BuildContext context) {
    final locale = currentLocale(context);
    final groups = _groups;
    final query = _search.trim().toLowerCase();
    final filtered = (groups ?? []).where((g) => query.isEmpty || '${g['name']}'.toLowerCase().contains(query)).toList();
    final inGroups = (groups ?? []).fold<int>(0, (s, g) => s + asInt(g['student_count']));
    final withoutGroup = _students.where((s) => s['group_id'] == null).length;

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
              DashPageTitle(
                title: tt(locale, 'title'),
                subtitle: tt(locale, 'subtitle'),
                trailing: Material(
                  color: const Color(0xFF5D87FF),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _create,
                    child: const SizedBox(width: 46, height: 46, child: Icon(Icons.add_rounded, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _GroupStat(
                      icon: Icons.groups_2_rounded,
                      tone: groupTones[0],
                      value: '${groups?.length ?? 0}',
                      label: tt(locale, 'statGroups'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GroupStat(
                      icon: Icons.people_alt_rounded,
                      tone: groupTones[2],
                      value: '$inGroups',
                      label: tt(locale, 'statStudentsInGroups'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GroupStat(
                      icon: Icons.person_off_rounded,
                      tone: groupTones[3],
                      value: '$withoutGroup',
                      label: tt(locale, 'statStudentsWithoutGroup'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DashSearchField(hint: tt(locale, 'searchGroup'), onChanged: (v) => setState(() => _search = v)),
              const SizedBox(height: 14),
              if (_error && groups == null)
                ErrorRetry(message: tt(locale, 'loadError'), retryLabel: tt(locale, 'retry'), onRetry: _load)
              else if (groups == null)
                ...[for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 150))]
              else if (filtered.isEmpty)
                DashCard(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 26),
                  child: Column(
                    children: [
                      const IconBox(
                        icon: Icons.groups_2_rounded,
                        color: Color(0xFF5D87FF),
                        background: Color(0xFFEAF0FF),
                        size: 60,
                        radius: 30,
                      ),
                      const SizedBox(height: 12),
                      Text(tt(locale, query.isEmpty ? 'emptyTitle' : 'noSearchResults'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: DashColors.ink)),
                      if (query.isEmpty) ...[
                        const SizedBox(height: 4),
                        Text(tt(locale, 'emptyDescription'),
                            textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: DashColors.muted)),
                        const SizedBox(height: 16),
                        DashButton(
                          label: tt(locale, 'createGroup'),
                          icon: Icons.add_rounded,
                          color: const Color(0xFF5D87FF),
                          onTap: _create,
                        ),
                      ],
                    ],
                  ),
                )
              else
                for (var i = 0; i < filtered.length; i++) ...[
                  _GroupCard(
                    group: filtered[i],
                    index: i,
                    locale: locale,
                    onChanged: _load,
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupStat extends StatelessWidget {
  const _GroupStat({required this.icon, required this.tone, required this.value, required this.label});

  final IconData icon;
  final (Color, Color) tone;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon: icon, color: tone.$1, background: tone.$2, size: 38, radius: 12),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF191C1D))),
          Text(label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, height: 1.2, color: Color(0xFF5A6A85))),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.index, required this.locale, required this.onChanged});

  final Map<String, dynamic> group;
  final int index;
  final String locale;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tone = groupTones[index % groupTones.length];
    final percent = asNum(group['average_score']).round();
    final color = averageColor(percent);
    final description = '${group['description'] ?? ''}'.trim();
    return DashCard(
      onTap: () => openGroupDetail(context, group['id']).then((_) => onChanged()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconBox(icon: Icons.groups_2_rounded, color: tone.$1, background: tone.$2, size: 48, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${group['name'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF191C1D))),
                    Text(
                      description.isEmpty ? tt(locale, 'noDescription') : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8E)),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF8A8A8E)),
                onSelected: (value) async {
                  final changed = value == 'edit'
                      ? await showGroupForm(context, group: group)
                      : await deleteGroup(context, group);
                  if (changed) onChanged();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF5D87FF)),
                      const SizedBox(width: 10),
                      Text(tt(locale, 'edit')),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline_rounded, size: 18, color: DashColors.red),
                      const SizedBox(width: 10),
                      Text(tt(locale, 'delete'), style: const TextStyle(color: DashColors.red)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          Container(height: 1, color: const Color(0xFFF5F5F5), margin: const EdgeInsets.symmetric(vertical: 12)),
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, size: 16, color: Color(0xFF8A8A8E)),
              const SizedBox(width: 5),
              Text('${asInt(group['student_count'])}',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF5A6A85))),
              const SizedBox(width: 10),
              Pill(
                text: '$percent%',
                icon: Icons.trending_up_rounded,
                color: color,
                background: color.withValues(alpha: 0.1),
              ),
              const Spacer(),
              LinkButton(
                label: tt(locale, 'open'),
                color: const Color(0xFF5D87FF),
                onTap: () => openGroupDetail(context, group['id']).then((_) => onChanged()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
