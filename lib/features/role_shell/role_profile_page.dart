import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/constants.dart';
import '../../core/local_source/local_source.dart';
import '../../core/widgets/dash_ui.dart';
import '../../injector_container.dart';
import '../../router/app_routes.dart';
import '../../router/name_routes.dart';
import '../auth/presentation/page_args/auth_args.dart';
import 'role_shell_page.dart';

String _t(String locale, String key) {
  const uz = {
    'title': 'Profil',
    'parent': 'Ota-ona',
    'tutor': "O'qituvchi",
    'info': "Shaxsiy ma'lumotlar",
    'fullName': 'F.I.Sh.',
    'phone': 'Telefon raqam',
    'id': 'ID raqam',
    'registered': "Ro'yxatdan o'tgan",
    'email': 'Email',
    'security': 'Xavfsizlik va sozlamalar',
    'password': "Parolni o'zgartirish",
    'passwordSub': 'Hisobingizni himoyalang',
    'devices': 'Qurilmalarim',
    'devicesSub': "Faol qurilmalar (ko'pi bilan 2 ta)",
    'notifications': 'Bildirishnomalar',
    'notificationsSub': "Yangiliklar va xabarlar",
    'settings': 'Sozlamalar',
    'settingsSub': 'Til, PIN-kod, yordam',
    'logout': 'Chiqish',
    'logoutTitle': 'Hisobdan chiqish',
    'logoutText': 'Haqiqatan ham hisobingizdan chiqmoqchimisiz?',
    'cancel': 'Bekor qilish',
  };
  const ru = {
    'title': 'Профиль',
    'parent': 'Родитель',
    'tutor': 'Учитель',
    'info': 'Личные данные',
    'fullName': 'Ф.И.О.',
    'phone': 'Номер телефона',
    'id': 'ID номер',
    'registered': 'Дата регистрации',
    'email': 'Email',
    'security': 'Безопасность и настройки',
    'password': 'Изменить пароль',
    'passwordSub': 'Защитите свой аккаунт',
    'devices': 'Мои устройства',
    'devicesSub': 'Активные устройства (не более 2)',
    'notifications': 'Уведомления',
    'notificationsSub': 'Новости и сообщения',
    'settings': 'Настройки',
    'settingsSub': 'Язык, PIN-код, помощь',
    'logout': 'Выйти',
    'logoutTitle': 'Выход из аккаунта',
    'logoutText': 'Вы действительно хотите выйти из аккаунта?',
    'cancel': 'Отмена',
  };
  return (locale == 'ru' ? ru : uz)[key] ?? key;
}

/// Ota-ona va o'qituvchi profili (saytdagi dashboard/parent/profile va tutor/profile)
class RoleProfilePage extends StatefulWidget {
  const RoleProfilePage({super.key});

  @override
  State<RoleProfilePage> createState() => _RoleProfilePageState();
}

class _RoleProfilePageState extends State<RoleProfilePage> {
  final _local = sl<LocalSource>();
  Map<String, dynamic> _profile = {};

  bool get _isParent => _local.getUserRole() == 'parent';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final url = _isParent ? '/auth/parent/profile/' : '/auth/student/profile/';
      final res = await sl<Dio>().get('${Constants.baseUrl}$url');
      final body = asMap(res.data);
      if (mounted) setState(() => _profile = asMap(body['data'] ?? body));
    } catch (_) {}
  }

  void _logout(String locale) async {
    final ok = await confirmDash(
      context,
      title: _t(locale, 'logoutTitle'),
      message: _t(locale, 'logoutText'),
      confirmLabel: _t(locale, 'logout'),
      cancelLabel: _t(locale, 'cancel'),
      icon: Icons.logout_rounded,
    );
    if (!ok || !mounted) return;
    // Sozlamalardagi chiqish bilan bir xil: login ma'lumotlari va PIN saqlab qolinadi
    final phone = _local.getPhoneNumber() ?? '';
    final password = _local.getUserPassword() ?? '';
    final pin = _local.getPinCode() ?? '';
    await _local.clear();
    _local.setPhoneNumber(phone);
    _local.setUserPassword(password);
    _local.setPinCode(pin);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil(Routes.auth, arguments: AuthPageArgs(), (route) => false);
  }

  void _push(String route) => Navigator.of(context, rootNavigator: true).pushNamed(route);

  @override
  Widget build(BuildContext context) {
    final locale = currentLocale(context);
    final localName = [_local.getFirstName(), _local.getLastName()]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' ');
    final name = '${_profile['full_name'] ?? ''}'.trim().isNotEmpty ? '${_profile['full_name']}' : localName;
    final phone = fmtPhone(_profile['phone'] ?? _local.getPhoneNumber());
    final id = '${_profile['identification'] ?? ''}';
    final registered = '${_profile['parent_date'] ?? _profile['student_date'] ?? ''}';
    final email = '${_profile['email'] ?? ''}';

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
              DashPageTitle(title: _t(locale, 'title')),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  boxShadow: [
                    BoxShadow(color: DashColors.primary.withValues(alpha: 0.3), blurRadius: 22, offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  children: [
                    InitialsAvatar(name: name.isEmpty ? '?' : name, size: 70),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.isEmpty ? '—' : name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
                          if (phone.isNotEmpty)
                            Text(phone, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                          const SizedBox(height: 8),
                          Pill(
                            text: _t(locale, _isParent ? 'parent' : 'tutor'),
                            icon: _isParent ? Icons.family_restroom_rounded : Icons.school_rounded,
                            color: Colors.white,
                            background: Colors.white.withValues(alpha: 0.18),
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              DashCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CardTitle(icon: Icons.badge_rounded, title: _t(locale, 'info')),
                    _InfoRow(icon: Icons.person_rounded, label: _t(locale, 'fullName'), value: name),
                    _InfoRow(icon: Icons.phone_rounded, label: _t(locale, 'phone'), value: phone),
                    if (id.isNotEmpty)
                      _InfoRow(
                        icon: Icons.tag_rounded,
                        label: _t(locale, 'id'),
                        value: id,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: id));
                          HapticFeedback.lightImpact();
                        },
                      ),
                    if (email.isNotEmpty) _InfoRow(icon: Icons.mail_rounded, label: _t(locale, 'email'), value: email),
                    if (registered.isNotEmpty)
                      _InfoRow(icon: Icons.calendar_month_rounded, label: _t(locale, 'registered'), value: registered),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              DashCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CardTitle(icon: Icons.shield_rounded, title: _t(locale, 'security')),
                    _MenuRow(
                      icon: Icons.lock_rounded,
                      color: DashColors.purple,
                      title: _t(locale, 'password'),
                      sub: _t(locale, 'passwordSub'),
                      onTap: () => _push(Routes.changePassword),
                    ),
                    _MenuRow(
                      icon: Icons.devices_rounded,
                      color: DashColors.primary,
                      title: _t(locale, 'devices'),
                      sub: _t(locale, 'devicesSub'),
                      onTap: () => _push(Routes.devices),
                    ),
                    _MenuRow(
                      icon: Icons.notifications_rounded,
                      color: DashColors.amber,
                      title: _t(locale, 'notifications'),
                      sub: _t(locale, 'notificationsSub'),
                      onTap: () => _push(Routes.notification),
                    ),
                    _MenuRow(
                      icon: Icons.settings_rounded,
                      color: DashColors.green,
                      title: _t(locale, 'settings'),
                      sub: _t(locale, 'settingsSub'),
                      onTap: () => mainScaffoldKey.currentState?.openDrawer(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              DashButton(
                label: _t(locale, 'logout'),
                icon: Icons.logout_rounded,
                color: DashColors.redSoft,
                textColor: DashColors.red,
                onTap: () => _logout(locale),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            IconBox(icon: icon, color: DashColors.primary, background: DashColors.primarySoft, size: 38, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11.5, color: DashColors.muted)),
                  Text(value.isEmpty ? '—' : value,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DashColors.ink)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.copy_rounded, size: 17, color: DashColors.subtle),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.color, required this.title, required this.sub, required this.onTap});

  final IconData icon;
  final Color color;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            IconBox(icon: icon, color: color, background: color.withValues(alpha: 0.1), size: 42, radius: 14),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DashColors.ink)),
                  Text(sub, style: const TextStyle(fontSize: 12, color: DashColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22, color: DashColors.subtle),
          ],
        ),
      ),
    );
  }
}
