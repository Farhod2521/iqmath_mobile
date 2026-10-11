import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/constants.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/top_notification.dart';
import '../../injector_container.dart';
import '../role_shell/role_shell_page.dart';
import 'tutor_groups_page.dart';
import 'tutor_texts.dart';

const tutorHeroImage = 'assets/images/tutor_hero.webp';
const _blue = Color(0xFF5D87FF);
const _monthsUz = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
const _monthsRu = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];

/// O'qituvchi (tutor) bosh sahifasi — saytdagi dashboard/tutor/referrals bilan bir xil
class TutorHomePage extends StatefulWidget {
  const TutorHomePage({super.key});

  @override
  State<TutorHomePage> createState() => _TutorHomePageState();
}

class _TutorHomePageState extends State<TutorHomePage> {
  final Dio _dio = sl<Dio>();
  bool _loading = true;
  bool _error = false;
  String _identification = '';
  List<Map<String, dynamic>> _referrals = [];
  List<Map<String, dynamic>> _groups = [];
  Map<String, dynamic> _overview = {};
  Map<String, dynamic> _chart = {};
  int _shellIndex = -1;

  String get _inviteLink => _identification.isEmpty ? '' : 'https://iqmath.uz/?referral_code=$_identification';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guruhlar bo'limidan qaytilganda ma'lumot yangilanadi
    final index = RoleShell.of(context)?.current ?? -1;
    if (index == 0 && _shellIndex > 0) _load();
    _shellIndex = index;
  }

  Future<dynamic> _get(String url) async {
    try {
      return (await _dio.get(url)).data;
    } catch (_) {
      return null;
    }
  }

  Future<void> _load() async {
    setState(() => _error = false);
    final results = await Future.wait([
      _get('${Constants.baseUrl}/auth/student/profile/'),
      _get('$tutorBase/referral-transactions/'),
      _get('$tutorBase/groups/'),
      _get('$tutorBase/results/overview/'),
      _get('$tutorBase/results/chart/'),
    ]);
    if (!mounted) return;
    final profile = asMap(results[0]);
    setState(() {
      _identification = '${asMap(profile['data'] ?? profile)['identification'] ?? _identification}';
      if (_identification == 'null') _identification = '';
      _referrals = asMapList(results[1]);
      _groups = asMapList(results[2]);
      _overview = asMap(results[3]);
      _chart = asMap(results[4]);
      _loading = false;
      _error = results.skip(1).every((r) => r == null);
    });
  }

  void _copy(String locale) {
    if (_inviteLink.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _inviteLink));
    HapticFeedback.lightImpact();
    TopNotification.showSuccess(context, message: tt(locale, 'linkCopied'));
  }

  void _share(String locale) {
    if (_inviteLink.isEmpty) return;
    SharePlus.instance.share(ShareParams(text: '${tt(locale, 'inviteMessage')}\n$_inviteLink'));
  }

  void _showInvite(String locale) {
    showDashSheet(
      context,
      title: tt(locale, 'addStudentButton'),
      subtitle: tt(locale, 'qrShareDescription'),
      icon: Icons.person_add_alt_1_rounded,
      iconColor: _blue,
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: QrImageView(data: _inviteLink, size: 200, padding: EdgeInsets.zero),
            ),
            const SizedBox(height: 16),
            _LinkPill(link: _inviteLink, onCopy: () => _copy(locale)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DashButton(
                    label: tt(locale, 'copy'),
                    icon: Icons.copy_rounded,
                    color: const Color(0xFFE8F1FD),
                    textColor: const Color(0xFF4968F4),
                    onTap: () => _copy(locale),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DashButton(
                    label: tt(locale, 'share'),
                    icon: Icons.share_rounded,
                    color: _blue,
                    onTap: () => _share(locale),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAllStudents(String locale) {
    showDashSheet(
      context,
      title: tt(locale, 'recentStudentsTitle'),
      subtitle: '${_referrals.length} ${tt(locale, 'studentsJoinedSuffix')}',
      icon: Icons.people_alt_rounded,
      iconColor: _blue,
      builder: (_) => ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        itemCount: _referrals.length,
        separatorBuilder: (_, __) => Container(height: 1, color: const Color(0xFFF5F5F5)),
        itemBuilder: (_, i) => _StudentRow(item: _referrals[i], index: i, locale: locale),
      ),
    );
  }

  Future<void> _createGroup() async {
    if (await showGroupForm(context)) _load();
  }

  @override
  Widget build(BuildContext context) {
    final locale = currentLocale(context);
    final now = DateTime.now();
    final today = locale == 'ru'
        ? '${now.day} ${_monthsRu[now.month - 1]} ${now.year}'
        : '${now.day} ${_monthsUz[now.month - 1]}, ${now.year}';

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
              DashTopBar(greeting: tt(locale, 'greeting')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(tt(locale, 'greetingSubtitle'),
                        style: const TextStyle(fontSize: 13, color: Color(0xFF5A6A85))),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9E9E9)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: _blue),
                        const SizedBox(width: 6),
                        Text(today, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF191C1D))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _hero(locale),
              const SizedBox(height: 14),
              _promoCard(locale),
              const SizedBox(height: 14),
              if (_loading) ...[
                const TwoColumnGrid(children: [SkeletonBox(height: 120), SkeletonBox(height: 120)]),
                const SizedBox(height: 10),
                const TwoColumnGrid(children: [SkeletonBox(height: 120), SkeletonBox(height: 120)]),
                const SizedBox(height: 14),
                const SkeletonBox(height: 220),
              ] else if (_error)
                ErrorRetry(message: tt(locale, 'loadError'), retryLabel: tt(locale, 'retry'), onRetry: _load)
              else ...[
                _stats(locale),
                const SizedBox(height: 14),
                _recentStudents(locale),
                const SizedBox(height: 14),
                _groupsCard(locale),
                const SizedBox(height: 14),
                _resultsChart(locale),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(String locale) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        color: const Color(0xFFEAF1FF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tt(locale, 'heroTitle'),
                      style: const TextStyle(fontSize: 25, height: 1.15, fontWeight: FontWeight.w800, color: Color(0xFF191C1D))),
                  const SizedBox(height: 8),
                  Text(tt(locale, 'heroDescription'),
                      style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF5A6A85))),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DashButton(
                          label: tt(locale, 'addStudentButton'),
                          icon: Icons.person_add_alt_1_rounded,
                          color: _blue,
                          height: 42,
                          onTap: () => _showInvite(locale),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashButton(
                          label: tt(locale, 'createGroupButton'),
                          icon: Icons.create_new_folder_rounded,
                          color: Colors.white,
                          textColor: const Color(0xFF4968F4),
                          height: 42,
                          onTap: _createGroup,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Rasm: pastda, o'ng tomondagi kitob va noutbuk ko'rinadi
            SizedBox(
              height: 120,
              child: Image.asset(tutorHeroImage, fit: BoxFit.cover, alignment: const Alignment(0.75, 0.2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _promoCard(String locale) {
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconBox(icon: Icons.link_rounded, color: _blue, background: Color(0xFFEAF0FF), size: 34, radius: 10),
              const SizedBox(width: 8),
              Expanded(
                child: Text(tt(locale, 'promoTitle'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF191C1D))),
              ),
              IconButton(
                onPressed: () => _share(locale),
                icon: const Icon(Icons.share_rounded, color: _blue, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _LinkPill(link: _inviteLink, onCopy: () => _copy(locale)),
          const SizedBox(height: 14),
          Row(
            children: [
              const IconBox(icon: Icons.people_alt_rounded, color: _blue, background: Color(0xFFEAF0FF), size: 40, radius: 12),
              const SizedBox(width: 10),
              Text('${_referrals.length}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF191C1D))),
              const SizedBox(width: 6),
              Expanded(
                child: Text(tt(locale, 'studentsJoinedSuffix'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5A6A85))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _showInvite(locale),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEF1FF)),
                gradient: const LinearGradient(colors: [Color(0xFFF8F9FE), Color(0xFFEEF1FF)]),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9E9E9)),
                    ),
                    child: _inviteLink.isEmpty
                        ? const Icon(Icons.qr_code_2_rounded, size: 34, color: Color(0xFFB0B6C9))
                        : QrImageView(data: _inviteLink, padding: EdgeInsets.zero),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const IconBox(
                                icon: Icons.qr_code_rounded,
                                color: Colors.white,
                                background: Color(0xFF0EA5A5),
                                size: 24,
                                radius: 7),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(tt(locale, 'qrShareTitle'),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF191C1D))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(tt(locale, 'qrShareDescription'),
                            style: const TextStyle(fontSize: 12, height: 1.3, color: Color(0xFF8A8A8E))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats(String locale) {
    final students = asMap(_overview['students']);
    final groups = asMap(_overview['groups']);
    final topics = asMap(_overview['topics']);
    final average = asMap(_overview['average_result']);
    final total = asInt(students['total']);
    final active = asInt(students['active_in_period']);
    final activePercent = total == 0 ? 0 : (active * 100 / total).round();

    Widget growth(String text) => Row(
          children: [
            const Icon(Icons.arrow_upward_rounded, size: 12, color: Color(0xFF10B981)),
            const SizedBox(width: 2),
            Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
            ),
          ],
        );

    return Column(
      children: [
        TwoColumnGrid(
          children: [
            StatTile(
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF205FFE),
              soft: const Color(0xFFD7E6FE),
              label: tt(locale, 'statTotalStudents'),
              value: '$total',
              footerWidget: growth(tt(locale, 'statTotalStudentsSub', {'count': asInt(students['new_in_period'])})),
            ),
            StatTile(
              icon: Icons.groups_2_rounded,
              color: const Color(0xFF7626FB),
              soft: const Color(0xFFE3D7FE),
              label: tt(locale, 'statGroups'),
              value: '${asInt(groups['total'])}',
              footerWidget: growth(tt(locale, 'statGroupsSub', {'count': asInt(groups['new_in_period'])})),
            ),
            StatTile(
              icon: Icons.monitor_heart_rounded,
              color: const Color(0xFF0D875E),
              soft: const Color(0xFFE7F8EF),
              label: tt(locale, 'statActiveStudents'),
              value: '$active',
              footer: tt(locale, 'statActiveStudentsSub', {'percent': activePercent}),
            ),
            StatTile(
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFFF59E0B),
              soft: const Color(0xFFFFF3DD),
              label: tt(locale, 'statAverageResult'),
              value: '${asNum(average['overall_percent']).round()}%',
              footerWidget: growth(tt(locale, 'statAverageResultSub', {'percent': asNum(average['growth']).round()})),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StatTile(
          icon: Icons.menu_book_rounded,
          color: _blue,
          soft: const Color(0xFFEAF0FF),
          label: tt(locale, 'statCompletedTopics'),
          value: '${asInt(topics['completed_in_period'])}',
          footerWidget: growth(tt(locale, 'statCompletedTopicsSub', {'count': asInt(topics['growth'])})),
        ),
      ],
    );
  }

  Widget _recentStudents(String locale) {
    final items = _referrals.take(5).toList();
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.person_add_alt_1_rounded,
            iconColor: _blue,
            title: tt(locale, 'recentStudentsTitle'),
            trailing: _referrals.length > 5
                ? LinkButton(label: tt(locale, 'viewAll'), color: _blue, onTap: () => _showAllStudents(locale))
                : null,
          ),
          if (items.isEmpty)
            EmptyNote(text: tt(locale, 'recentStudentsEmpty'), icon: Icons.person_add_alt_1_rounded)
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) Container(height: 1, color: const Color(0xFFF5F5F5)),
              _StudentRow(item: items[i], index: i, locale: locale),
            ],
        ],
      ),
    );
  }

  Widget _groupsCard(String locale) {
    final items = _groups.take(4).toList();
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.groups_2_rounded,
            iconColor: _blue,
            title: tt(locale, 'myGroupsTitle'),
            trailing: LinkButton(label: tt(locale, 'viewAll'), color: _blue, onTap: () => RoleShell.of(context)?.goTo(1)),
          ),
          if (items.isEmpty)
            EmptyNote(text: tt(locale, 'emptyTitle'), icon: Icons.groups_2_rounded)
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) Container(height: 1, color: const Color(0xFFF5F5F5)),
              InkWell(
                onTap: () => openGroupDetail(context, items[i]['id']).then((_) => _load()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      IconBox(
                        icon: Icons.groups_2_rounded,
                        color: groupTones[i % groupTones.length].$1,
                        background: groupTones[i % groupTones.length].$2,
                        size: 40,
                        radius: 12,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${items[i]['name'] ?? ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF191C1D))),
                            Text(tt(locale, 'groupsStudentsCount', {'count': asInt(items[i]['student_count'])}),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8E))),
                          ],
                        ),
                      ),
                      PercentRing(
                        percent: asNum(items[i]['average_score']).round(),
                        color: averageColor(asNum(items[i]['average_score'])),
                        size: 40,
                        stroke: 4,
                        fontSize: 9.5,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B6C9)),
                    ],
                  ),
                ),
              ),
            ],
          const SizedBox(height: 10),
          DashButton(
            label: tt(locale, 'createNewGroup'),
            icon: Icons.add_rounded,
            color: const Color(0xFFF1F4FF),
            textColor: _blue,
            height: 42,
            onTap: _createGroup,
          ),
        ],
      ),
    );
  }

  Widget _resultsChart(String locale) {
    final values = (_chart['values'] is List ? _chart['values'] as List : const [])
        .map((v) => asNum(v))
        .toList();
    final labels = (_chart['labels'] is List ? _chart['labels'] as List : const []).map((l) => '$l').toList();
    final hasData = values.any((v) => v > 0);
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            icon: Icons.show_chart_rounded,
            iconColor: _blue,
            title: tt(locale, 'resultsChartTitle'),
            trailing: Pill(
              text: tt(locale, 'resultsChartPeriod'),
              color: const Color(0xFF5A6A85),
              background: const Color(0xFFF1F4FF),
            ),
          ),
          LineChart(values: values, labels: labels),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(tt(locale, 'resultsChartEmpty'),
                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8E))),
            ),
        ],
      ),
    );
  }
}

class _LinkPill extends StatelessWidget {
  const _LinkPill({required this.link, required this.onCopy});

  final String link;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 5, 5, 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(link.isEmpty ? '...' : link,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5A6A85))),
          ),
          Material(
            color: _blue,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onCopy,
              child: const SizedBox(width: 38, height: 38, child: Icon(Icons.copy_rounded, size: 17, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.item, required this.index, required this.locale});

  final Map<String, dynamic> item;
  final int index;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final bonus = item['bonus_amount'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text('${index + 1}', style: const TextStyle(fontSize: 12.5, color: Color(0xFF8A8A8E))),
          ),
          ColorAvatar(name: '${item['student_name'] ?? ''}', index: index, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item['student_name'] ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF191C1D))),
                Text('${item['used_at'] ?? '-'}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A8A8E))),
              ],
            ),
          ),
          if (bonus != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(tt(locale, 'bonus'), style: const TextStyle(fontSize: 10.5, color: Color(0xFF8A8A8E))),
                Text("${fmtMoney(bonus)} ${locale == 'ru' ? 'сум' : "so'm"}",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0D875E))),
              ],
            ),
        ],
      ),
    );
  }
}
