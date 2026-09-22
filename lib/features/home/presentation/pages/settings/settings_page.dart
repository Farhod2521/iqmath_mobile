import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/core/widgets/top_notification.dart';
import 'package:my_flutter_template/features/auth/presentation/page_args/auth_args.dart';
import 'package:my_flutter_template/features/home/presentation/page_parts/home_localizations.dart';
import 'package:my_flutter_template/features/home/presentation/pages/settings/widget/account_switcher_widget.dart';
import 'package:my_flutter_template/features/profile/presentation/arguments/edit_profile_page_args.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/app_routes.dart';

import '../../../../../core/app_bloc/app_bloc.dart';
import '../../../../../core/local_source/local_source.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../router/name_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  bool biometricEnabled = true;
  bool vibrationEnabled = true;
  String selectedLanguage = 'O\'zbekcha';
  final localSource = sl<LocalSource>();

  static const _blue = Color(0xFF00008B);
  static const _cardLight = Colors.white;
  static const Color _cardDark = Color(0xFF1C1C1E);
  static const Color _bgDark = Color(0xFF121212);
  static const Color _bgLight = Color(0xFFF2F2F7);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';
        final isDark = appState.themeMode == ThemeMode.dark;
        final bg = isDark ? _bgDark : _bgLight;
        final cardColor = isDark ? _cardDark : _cardLight;
        final labelColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;
        final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final divColor = isDark ? Colors.white12 : Colors.black.withOpacity(0.06);

        String _loc(String key) {
          final uz = {
            'profil': 'PROFIL',
            'sozlamalar': 'SOZLAMALAR',
            'aloqa': 'ALOQA VA YORDAM',
            'profilInfo': 'Profil ma\'lumotlari',
            'kurslarim': 'Kurslarim',
            'sertifikat': 'Sertifikatlarim',
            'faollik': 'Faollik',
            'ilovaTili': 'Ilova tili',
            'qorongu': 'Qorong\'i rejim',
            'tebranish': 'Tebranishlar',
            'yordam': 'Yordam va qo\'llab-quvvatlash',
            'dostlar': 'Do\'stlarni taklif qiling',
            'chiqish': 'Chiqish',
            'uzb': 'O\'zbekcha',
            'rus': 'Русский',
          };
          final ru = {
            'profil': 'ПРОФИЛЬ',
            'sozlamalar': 'НАСТРОЙКИ',
            'aloqa': 'ПОДДЕРЖКА',
            'profilInfo': 'Данные профиля',
            'kurslarim': 'Мои курсы',
            'sertifikat': 'Сертификаты',
            'faollik': 'Активность',
            'ilovaTili': 'Язык приложения',
            'qorongu': 'Тёмный режим',
            'tebranish': 'Вибрация',
            'yordam': 'Помощь и поддержка',
            'dostlar': 'Пригласить друзей',
            'chiqish': 'Выйти',
            'uzb': 'O\'zbekcha',
            'rus': 'Русский',
          };
          return (locale == 'ru' ? ru : uz)[key] ?? key;
        }

        Widget sectionLabel(String text) => Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                  letterSpacing: 0.8,
                ),
              ),
            );

        Widget card(List<Widget> children) => Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(children: children),
            );

        Widget divLine() => Divider(
              height: 1,
              thickness: 1,
              indent: 58,
              color: divColor,
            );

        Widget row(
          IconData icon,
          String title,
          VoidCallback onTap, {
          Widget? trailing,
        }) =>
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _blue.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 19, color: _blue),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      trailing ??
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                    ],
                  ),
                ),
              ),
            );

        Widget switchRow(IconData icon, String title, bool value,
                ValueChanged<bool> onChanged) =>
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _blue.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 19, color: _blue),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  CupertinoSwitch(
                    value: value,
                    onChanged: onChanged,
                    activeColor: _blue,
                  ),
                ],
              ),
            );

        return Drawer(
          width: double.infinity,
          backgroundColor: bg,
          child: SafeArea(
            child: Column(
              children: [
                // ── Profil header ──
                TelegramAccountHeader(
                  token: localSource.getAccessToken() ?? '',
                  currentPhone: localSource.getPhoneNumber() ?? '',
                  currentName: localSource.getFirstName(),
                  onSwitched: () {
                    Navigator.pop(rootNavigatorKey.currentContext!);
                    Navigator.of(rootNavigatorKey.currentContext!)
                        .pushNamedAndRemoveUntil(
                            Routes.screenLockClone, (route) => false);
                  },
                ),

                // ── Scrollable body ──
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                    children: [
                      // ── PROFIL ──
                      sectionLabel(_loc('profil')),
                      card([
                        row(Icons.person_outlined, _loc('profilInfo'), () async {
                          await Navigator.pushNamed(
                            context,
                            Routes.editProfile,
                            arguments: EditProfilePageArgs(
                              firstName: localSource.getFirstName() ?? '',
                              id: localSource.getUserId() ?? '',
                              phoneNumber: localSource.getPhoneNumber() ?? '',
                              profilePhoto: '',
                              address: localSource.getUserAddress() ?? '',
                            ),
                          ).then((value) {
                            if (value != null) {
                              TopNotification.showSuccess(context,
                                  message: value.toString());
                            }
                          });
                        }),
                        divLine(),
                        row(Icons.menu_book_outlined, _loc('kurslarim'), () {
                          Navigator.pop(context);
                        }),
                        divLine(),
                        row(Icons.military_tech_outlined, _loc('sertifikat'),
                            _showComingSoon),
                        divLine(),
                        row(Icons.bar_chart_rounded, _loc('faollik'),
                            _showComingSoon),
                      ]),
                      const SizedBox(height: 24),

                      // ── SOZLAMALAR ──
                      sectionLabel(_loc('sozlamalar')),
                      card([
                        row(
                          Icons.language_rounded,
                          _loc('ilovaTili'),
                          () => _showLanguageSheet(context, locale, cardColor,
                              textColor, appState, isDark),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                locale == 'ru' ? _loc('rus') : _loc('uzb'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded,
                                  size: 20, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                        divLine(),
                        switchRow(
                          Icons.dark_mode_outlined,
                          _loc('qorongu'),
                          isDark,
                          (val) {
                            HapticFeedback.selectionClick();
                            if (val) {
                              context.read<AppBloc>().add(AppThemeSwitchDark(
                                  darkTheme: darkThemes.values.first));
                            } else {
                              context.read<AppBloc>().add(AppThemeSwitchLight(
                                  lightTheme: lightThemes.values.first));
                            }
                          },
                        ),
                        divLine(),
                        switchRow(
                          Icons.vibration_rounded,
                          _loc('tebranish'),
                          vibrationEnabled,
                          (val) {
                            setState(() => vibrationEnabled = val);
                            if (val) HapticFeedback.mediumImpact();
                          },
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // ── ALOQA VA YORDAM ──
                      sectionLabel(_loc('aloqa')),
                      card([
                        row(Icons.support_agent_outlined, _loc('yordam'), () {
                          Navigator.pop(context);
                          _showHelpCenter(locale);
                        }),
                        divLine(),
                        row(Icons.person_add_outlined, _loc('dostlar'),
                            _showComingSoon),
                      ]),
                      const SizedBox(height: 32),

                      // ── Chiqish ──
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            _showLogoutDialog(locale);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.18)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded,
                                    size: 20, color: Colors.red.shade600),
                                const SizedBox(width: 10),
                                Text(
                                  _loc('chiqish'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoon() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tez orada'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLanguageSheet(
    BuildContext ctx,
    String locale,
    Color cardColor,
    Color textColor,
    AppState appState,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            _langOption(ctx, appState.appLocale == 'uz', 'O\'zbekcha',
                'assets/png/uzbek_flag.png', () {
              ctx.read<AppBloc>().add(const AppChangeLocale('uz'));
              Navigator.pop(ctx);
            }, textColor, isDark),
            const SizedBox(height: 12),
            _langOption(ctx, appState.appLocale == 'ru', 'Русский',
                'assets/png/russia_flag.png', () {
              ctx.read<AppBloc>().add(const AppChangeLocale('ru'));
              Navigator.pop(ctx);
            }, textColor, isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _langOption(BuildContext ctx, bool selected, String label,
      String flagAsset, VoidCallback onTap, Color textColor, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF00008B).withOpacity(0.08)
              : (isDark ? Colors.white10 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: const Color(0xFF00008B).withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? const Color(0xFF00008B) : textColor)),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: Color(0xFF00008B)),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    bool showArrow = true,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        highlightColor: context.color.primaryColor1.withOpacity(0.02),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (textColor ?? context.color.primaryColor1)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: textColor ?? context.color.primaryColor1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor ?? Color(0xFF2D3142),
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (showArrow && trailing == null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  // ignore: unused_element
  Widget _buildLanguageOption(
    bool selected,
    String code,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        splashColor: context.color.primaryColor1.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? context.color.primaryColor1
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                  color: selected
                      ? context.color.primaryColor1
                      : Colors.transparent,
                ),
                child: selected
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Text(
                code,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? context.color.primaryColor1
                      : Color(0xFF2D3142),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: context.color.primaryColor1.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.color.primaryColor1.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: context.color.primaryColor1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 60),
      color: Colors.grey[100],
    );
  }

  void _showLogoutDialog(String locale) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(SettingsLocalization.get('logoutTitle', locale)),
          content: Text(SettingsLocalization.get('logoutMessage', locale)),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(SettingsLocalization.get('cancel', locale)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                final localSource = sl<LocalSource>();
                String phoneNumber = localSource.getPhoneNumber() ?? '';
                String password = localSource.getUserPassword() ?? '';
                String pinCode = sl<LocalSource>().getPinCode() ?? '';
                localSource.clear().then((value) async {
                  localSource.setPhoneNumber(phoneNumber);
                  localSource.setUserPassword(password);
                  localSource.setPinCode(pinCode);
                });
                Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(
                        Routes.auth,
                        arguments: AuthPageArgs(),
                        (route) => false);
              },
              child: Text(SettingsLocalization.get('logout', locale)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(String locale) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(SettingsLocalization.get('deleteAccountTitle', locale)),
          content:
              Text(SettingsLocalization.get('deleteAccountMessage', locale)),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(SettingsLocalization.get('cancel', locale)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
                // Kichik delay qo'shamiz
                Future.delayed(Duration(milliseconds: 100), () {
                  if (mounted) {
                    _showPasswordConfirmDialog(locale);
                  }
                });
              },
              child: Text(SettingsLocalization.get('delete', locale)),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordConfirmDialog(String locale) {
    if (!mounted) return;

    final TextEditingController passwordController = TextEditingController();
    bool isLoading = false;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: Text(SettingsLocalization.get('confirmPassword', locale)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  Container(
                    height: 50,
                    child: CupertinoTextField(
                      controller: passwordController,
                      placeholder: SettingsLocalization.get('password', locale),
                      obscureText: true,
                      enabled: !isLoading,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.black,
                      ),
                      placeholderStyle: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                      cursorColor: CupertinoColors.black,
                    ),
                  ),
                  if (isLoading) ...[
                    SizedBox(height: 20),
                    CupertinoActivityIndicator(),
                  ],
                  SizedBox(height: 10),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(SettingsLocalization.get('cancel', locale)),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (passwordController.text.isEmpty) {
                            Navigator.of(dialogContext).pop();
                            Future.delayed(Duration(milliseconds: 100), () {
                              if (mounted) {
                                _showErrorDialog(
                                  locale,
                                  SettingsLocalization.get(
                                      'passwordRequired', locale),
                                );
                              }
                            });
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final localSource = sl<LocalSource>();
                            final token = localSource.getAccessToken();

                            final response = await http.delete(
                              Uri.parse(
                                  'https://api.iqmath.uz/api/v1/auth/student/delete-profile/'),
                              headers: {
                                'Content-Type': 'application/json',
                                'Authorization': '$token',
                              },
                              body: json.encode({
                                'password': passwordController.text,
                              }),
                            );
                            alice.onHttpResponse(response);
                            if (response.statusCode == 200) {
                              String phoneNumber =
                                  localSource.getPhoneNumber() ?? '';
                              String password =
                                  localSource.getUserPassword() ?? '';

                              await localSource.clear();
                              localSource.setPhoneNumber(phoneNumber);
                              localSource.setUserPassword(password);

                              if (mounted) {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(this.context, rootNavigator: true)
                                    .pushNamedAndRemoveUntil(
                                  Routes.auth,
                                  arguments: AuthPageArgs(),
                                  (route) => false,
                                );
                              }
                            } else {
                              setState(() {
                                isLoading = false;
                              });

                              if (mounted) {
                                Navigator.of(dialogContext).pop();
                                Future.delayed(Duration(milliseconds: 100), () {
                                  if (mounted) {
                                    _showErrorDialog(
                                      locale,
                                      SettingsLocalization.get(
                                          'wrongPassword', locale),
                                    );
                                  }
                                });
                              }
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });

                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                              Future.delayed(Duration(milliseconds: 100), () {
                                if (mounted) {
                                  _showErrorDialog(
                                    locale,
                                    SettingsLocalization.get(
                                        'networkError', locale),
                                  );
                                }
                              });
                            }
                          }
                        },
                  child: Text(SettingsLocalization.get('confirm', locale)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String locale, String message) {
    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(SettingsLocalization.get('error', locale)),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(SettingsLocalization.get('ok', locale)),
            ),
          ],
        );
      },
    );
  }

  void _showHelpCenter(String locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.color.primaryColor1.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                size: 48,
                color: context.color.primaryColor1,
              ),
            ),
            SizedBox(height: 20),
            Text(
              SettingsLocalization.get('helpCenterTitle', locale),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3142),
              ),
            ),
            SizedBox(height: 12),
            Text(
              SettingsLocalization.get('helpCenterSubtitle', locale),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 28),
            _buildHelpOption(
              Icons.email_outlined,
              SettingsLocalization.get('email', locale),
              'mail.udea.uz',
              Colors.blue,
              () => BaseFunctions.sendEmail('mail.udea.uz'),
            ),
            SizedBox(height: 12),
            _buildHelpOption(
              Icons.phone_outlined,
              SettingsLocalization.get('phone', locale),
              '+998 88-198-90-00',
              Colors.green,
              () => BaseFunctions.makePhoneCall('+998881989000'),
            ),
            SizedBox(height: 12),
            _buildHelpOption(
              Icons.chat_bubble_outline,
              SettingsLocalization.get('chat', locale),
              SettingsLocalization.get('chatOnline', locale),
              context.color.primaryColor1,
              () {
                debugPrint('Chat tapped');
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
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

// class SettingsBottomSheet extends StatefulWidget {
//   const SettingsBottomSheet({super.key});
//
//   static void show(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const SettingsBottomSheet(),
//     );
//   }
//
//   @override
//   State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
// }
//
// class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
//   bool biometricEnabled = true;
//   String selectedLanguage = 'O\'zbekcha';
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.85,
//       decoration: BoxDecoration(
//         color: Color(0xFFF5F7FA),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Column(
//         children: [
//           // Handle
//           Container(
//             margin: EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//
//           // Header
//           Container(
//             padding: const EdgeInsets.all(24),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: context.color.primaryColor1.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.settings_outlined,
//                     size: 28,
//                     color: context.color.primaryColor1,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Text(
//                   'Sozlamalar',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF2D3142),
//                   ),
//                 ),
//                 Spacer(),
//                 IconButton(
//                   icon: Icon(Icons.close, color: Colors.grey[600]),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//           ),
//
//           // Content
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               children: [
//                 // Language Section
//                 _buildSectionHeader('Til', Icons.translate),
//                 SizedBox(height: 12),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.04),
//                         blurRadius: 15,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildLanguageOption('O\'zbekcha', 'uz'),
//                       _buildDivider(),
//                       _buildLanguageOption('Русский', 'ru'),
//                       _buildDivider(),
//                       _buildLanguageOption('English', 'en'),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Security Section
//                 _buildSectionHeader('Xavfsizlik', Icons.lock_outline),
//                 SizedBox(height: 12),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.04),
//                         blurRadius: 15,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildMenuItem(
//                         icon: Icons.key_outlined,
//                         title: 'Parolni O\'zgartirish',
//                         color: context.color.primaryColor1,
//                         onTap: () {
//                           HapticFeedback.lightImpact();
//                           _showChangePasswordDialog();
//                         },
//                       ),
//                       _buildDivider(),
//                       _buildBiometricToggle(),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Support Section
//                 _buildSectionHeader('Yordam', Icons.help_outline),
//                 SizedBox(height: 12),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.04),
//                         blurRadius: 15,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildMenuItem(
//                         icon: Icons.chat_bubble_outline,
//                         title: 'Ko\'p So\'raladigan Savollar',
//                         color: Color(0xFFFF9800),
//                         onTap: () {
//                           HapticFeedback.lightImpact();
//                           _showFAQ();
//                         },
//                       ),
//                       _buildDivider(),
//                       _buildMenuItem(
//                         icon: Icons.info_outline,
//                         title: 'Yordam Markazi',
//                         color: Color(0xFF2196F3),
//                         onTap: () {
//                           HapticFeedback.lightImpact();
//                           _showHelpCenter();
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//
//           // Version Footer
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Text(
//               'Versiya 1.0.0',
//               style: TextStyle(
//                 fontSize: 13,
//                 color: Colors.grey[500],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, size: 18, color: Colors.grey[600]),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey[700],
//             letterSpacing: 0.5,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLanguageOption(String language, String code) {
//     bool isSelected = selectedLanguage == language;
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           HapticFeedback.selectionClick();
//           setState(() {
//             selectedLanguage = language;
//           });
//         },
//         splashColor: context.color.primaryColor1.withOpacity(0.05),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             children: [
//               Container(
//                 width: 22,
//                 height: 22,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: isSelected ? context.color.primaryColor1 : Colors.grey[300]!,
//                     width: 2,
//                   ),
//                   color: isSelected ? context.color.primaryColor1 : Colors.transparent,
//                 ),
//                 child: isSelected
//                     ? Icon(Icons.check, size: 14, color: Colors.white)
//                     : null,
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 language,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                   color: isSelected ? context.color.primaryColor1 : Color(0xFF2D3142),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMenuItem({
//     required IconData icon,
//     required String title,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         splashColor: color.withOpacity(0.05),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, size: 18, color: color),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF2D3142),
//                   ),
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 size: 16,
//                 color: Colors.grey[400],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBiometricToggle() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Color(0xFF4CAF50).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               Icons.fingerprint_rounded,
//               size: 18,
//               color: Color(0xFF4CAF50),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               'Biometrik Autentifikatsiya',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D3142),
//               ),
//             ),
//           ),
//           Transform.scale(
//             scale: 0.8,
//             child: Switch.adaptive(
//               value: biometricEnabled,
//               activeColor: Color(0xFF4CAF50),
//               onChanged: (value) {
//                 HapticFeedback.selectionClick();
//                 setState(() {
//                   biometricEnabled = value;
//                 });
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDivider() {
//     return Container(
//       height: 1,
//       margin: const EdgeInsets.only(left: 60),
//       color: Colors.grey[100],
//     );
//   }
//
//   void _showChangePasswordDialog() {
//     showCupertinoDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CupertinoAlertDialog(
//           title: const Text('Parolni O\'zgartirish'),
//           content: const Text('Parol o\'zgartirish funksiyasi ishlab chiqilmoqda.'),
//           actions: [
//             CupertinoDialogAction(
//               isDefaultAction: true,
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showFAQ() {
//     Navigator.pop(context);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.8,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         padding: EdgeInsets.all(24),
//         child: Column(
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             SizedBox(height: 20),
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Color(0xFFFF9800).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     Icons.chat_bubble_outline,
//                     size: 24,
//                     color: Color(0xFFFF9800),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Text(
//                   'Ko\'p So\'raladigan Savollar',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF2D3142),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildFAQItem(
//                     'Ilovadan qanday foydalanish kerak?',
//                     'Ilovada asosiy funksiyalar intuitiv tarzda joylashtirilgan. Bosh sahifadan kerakli bo\'limni tanlang va ko\'rsatmalarga amal qiling.',
//                   ),
//                   _buildFAQItem(
//                     'Parolimni unutdim, nima qilishim kerak?',
//                     'Kirish sahifasida "Parolni unutdingizmi?" tugmasini bosing. Telefon raqamingizga tasdiqlash kodi yuboriladi.',
//                   ),
//                   _buildFAQItem(
//                     'Qanday qilib yordam olishim mumkin?',
//                     'Yordam Markazi orqali email, telefon yoki chat orqali murojaat qilishingiz mumkin.',
//                   ),
//                   _buildFAQItem(
//                     'Tangalar qanday ishlatiladi?',
//                     'Tangalar maxsus chegirmalar va bonuslar olish uchun ishlatiladi. Ballar sahifasidan tanga to\'plashingiz mumkin.',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showHelpCenter() {
//     Navigator.pop(context);
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         padding: EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             SizedBox(height: 20),
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Color(0xFF2196F3).withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.support_agent_rounded,
//                 size: 48,
//                 color: Color(0xFF2196F3),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Yordam Markazi',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF2D3142),
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               'Sizga qanday yordam bera olamiz?',
//               style: TextStyle(fontSize: 15, color: Colors.grey[600]),
//             ),
//             SizedBox(height: 28),
//             _buildHelpOption(
//               Icons.email_outlined,
//               'Email',
//               'support@app.uz',
//               Color(0xFF2196F3),
//             ),
//             SizedBox(height: 12),
//             _buildHelpOption(
//               Icons.phone_outlined,
//               'Telefon',
//               '+998 90 123 45 67',
//               Color(0xFF4CAF50),
//             ),
//             SizedBox(height: 12),
//             _buildHelpOption(
//               Icons.chat_bubble_outline,
//               'Chat',
//               'Onlayn chat bilan bog\'laning',
//               context.color.primaryColor1,
//             ),
//             SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFAQItem(String question, String answer) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Color(0xFFF5F7FA),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 margin: EdgeInsets.only(top: 2),
//                 padding: EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Color(0xFFFF9800).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Icon(
//                   Icons.help_outline,
//                   size: 16,
//                   color: Color(0xFFFF9800),
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       question,
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF2D3142),
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       answer,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHelpOption(
//       IconData icon,
//       String title,
//       String subtitle,
//       Color color,
//       ) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.2), width: 1.5),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: Colors.white, size: 24),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D3142),
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//           Icon(
//             Icons.arrow_forward_ios_rounded,
//             size: 16,
//             color: color,
//           ),
//         ],
//       ),
//     );
//   }
// }
