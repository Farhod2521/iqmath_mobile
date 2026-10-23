import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/auth/presentation/page_args/auth_args.dart';
import 'package:my_flutter_template/features/profile/presentation/arguments/edit_profile_page_args.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/core/widgets/student_stats_card.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_home_dashboard_usecase.dart';
import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/device/device_widgets.dart';
import '../../../../router/app_routes.dart';
import '../../../../router/name_routes.dart';

/// `ProfileLocalization` bir nechta boshqa sahifalarda (masalan,
/// `home_teacher_page.dart`, `referal_link_page.dart`) ham import qilib
/// ishlatiladi — shuning uchun bu klass saqlanadi.
class ProfileLocalization {
  static Map<String, Map<String, String>> translations = {
    'uz': {
      'products': 'Mahsulotlar',
      'ballsCoins': 'Ballar va Tangalar',
      'conversion': 'Konvertatsiya',
      'chat': 'Chat',
      'coupons': 'Kuponlar',
      'couponUsers': 'Kuponli foydalanuvchilar',
      'inviteFriends': 'Do\'stlarni Taklif Qilish',
      'version': 'Versiya',
      'inviteFriendsTitle': 'Do\'stlarni Taklif Qiling',
      'yourReferralCode': 'Sizning Referal Kodingiz',
      'copy': 'Nusxalash',
      'share': 'Ulashish',
      'referralCodeCopied': 'Referal kod nusxalandi!',
      'shareSubject': 'Referal kodim bilan qo\'shiling',
      'linkAdd': 'Havola orqali qo\'shilganlar',
      'payment': 'To\'lov paneli',
      'tariff': 'Tariflar',
    },
    'ru': {
      'products': 'Продукты',
      'ballsCoins': 'Баллы и Монеты',
      'conversion': 'Конвертация',
      'chat': 'Чат',
      'coupons': 'Купоны',
      'couponUsers': 'Пользователи с купонами',
      'inviteFriends': 'Пригласить друзей',
      'version': 'Версия',
      'inviteFriendsTitle': 'Пригласите друзей',
      'yourReferralCode': 'Ваш реферальный код',
      'copy': 'Копировать',
      'share': 'Поделиться',
      'referralCodeCopied': 'Реферальный код скопирован!',
      'shareSubject': 'Присоединяйтесь с моим реферальным кодом',
      'linkAdd': 'Добавленные по ссылке',
      'payment': 'Платежная панель',
      'tariff': 'Тарифы',
    },
  };

  static String get(String key, String locale) {
    return translations[locale]?[key] ?? translations['uz']![key]!;
  }
}

/// Profil sahifa ranglari — bosh sahifa bilan bir xil palitra.
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF64748B);
const Color _kPrimary = Color(0xFF2563EB);
const Color _kBgBottom = Color(0xFFF7FAFE);
const String _imgCover = 'assets/images/homepage.png';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _score = 0;
  int _coin = 0;
  int _sum = 0;
  bool _statsLoading = true;
  int? _streak; // bosh sahifa API'sidagi header'dan

  @override
  void initState() {
    super.initState();
    _fetchMyScore();
    _fetchStreak();
  }

  Future<void> _fetchStreak() async {
    final result = await sl<GetHomeDashboardUseCase>()(GetHomeDashboardParams());
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _streak = 0),
      (data) => setState(() => _streak = data.header?.streakDays ?? 0),
    );
  }

  Future<void> _fetchMyScore() async {
    final token = sl<LocalSource>().getAccessToken();
    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/func_student/my-score/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          _score = data['score'] ?? 0;
          _coin = data['coin'] ?? 0;
          _sum = data['sum'] ?? 0;
          _statsLoading = false;
        });
      } else if (mounted) {
        setState(() => _statsLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  void _openRoute(String route, {Object? arguments}) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      mainRootNavigatorKey.currentContext!,
      route,
      arguments: arguments,
    ).then((_) {
      // Tahrirlashdan qaytganda yangi profil rasmi darhol ko'rinsin
      if (mounted) setState(() {});
    });
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

  String _t(String locale, String key) {
    const uz = {
      'profilInfo': 'Profil ma\'lumotlari',
      'profilInfoSub': 'Ism, telefon raqam va boshqa ma\'lumotlar',
      'myPayments': "To'lovlarim",
      'myPaymentsSub': "Obuna to'lovlari va cheklar",
      'certificates': 'Sertifikatlarim',
      'certificatesSub': 'Olingan sertifikatlar',
      'logout': 'Ilovadan chiqish',
      'logoutSub': 'Tizimdan chiqib ketish',
      'logoutTitle': 'Tizimdan chiqish',
      'logoutMessage': 'Haqiqatan ham tizimdan chiqmoqchimisiz?',
      'cancel': 'Bekor qilish',
      'sectionProfile': 'PROFIL',
      'sectionSettings': 'SOZLAMALAR',
      'sectionSupport': 'ALOQA VA YORDAM',
      'language': 'Ilova tili',
      'languageSub': 'Ilova interfeysi tili',
      'help': 'Yordam va qo\'llab-quvvatlash',
      'helpSub': 'Savollar va texnik yordam',
      'privacy': 'Maxfiylik siyosati',
      'privacySub': 'Ma\'lumotlaringiz xavfsizligi',
      'editProfile': 'Profilni tahrirlash',
      'guest': 'O\'quvchi',
      'uzbek': 'O\'zbekcha',
      'russian': 'Русча',
    };

    const ru = {
      'profilInfo': 'Информация профиля',
      'profilInfoSub': 'Имя, номер телефона и другая информация',
      'myPayments': 'Мои платежи',
      'myPaymentsSub': 'Оплаты подписки и чеки',
      'certificates': 'Мои сертификаты',
      'certificatesSub': 'Полученные сертификаты',
      'logout': 'Выйти из приложения',
      'logoutSub': 'Выйти из системы',
      'logoutTitle': 'Выход из системы',
      'logoutMessage': 'Вы действительно хотите выйти?',
      'cancel': 'Отмена',
      'sectionProfile': 'ПРОФИЛЬ',
      'sectionSettings': 'НАСТРОЙКИ',
      'sectionSupport': 'СВЯЗЬ И ПОДДЕРЖКА',
      'language': 'Язык приложения',
      'languageSub': 'Язык интерфейса',
      'help': 'Помощь и поддержка',
      'helpSub': 'Вопросы и техподдержка',
      'privacy': 'Политика конфиденциальности',
      'privacySub': 'Безопасность ваших данных',
      'editProfile': 'Редактировать профиль',
      'guest': 'Ученик',
      'uzbek': 'O\'zbekcha',
      'russian': 'Русский',
    };

    final map = locale == 'ru' ? ru : uz;
    return map[key] ?? key;
  }

  String _fullName(String locale) {
    final localSource = sl<LocalSource>();
    final parts = [
      (localSource.getFirstName() ?? '').trim(),
      (localSource.getLastName() ?? '').trim(),
    ].where((part) => part.isNotEmpty && part != 'empty');

    if (parts.isEmpty) return _t(locale, 'guest');
    return parts.join(' ');
  }

  void _openEditProfile(String locale) {
    final localSource = sl<LocalSource>();
    _openRoute(
      Routes.editProfile,
      arguments: EditProfilePageArgs(
        firstName: _fullName(locale),
        id: localSource.getUserId() ?? '',
        phoneNumber: localSource.getPhoneNumber() ?? '',
        profilePhoto: localSource.getAvatarUrl() ?? '',
        address: localSource.getUserAddress() ?? '',
      ),
    );
  }

  void _showLanguageSheet(String locale) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      // Profil tabining o'z ichki Navigator'i bor — useRootNavigator
      // bo'lmasa, modal shu tab ichida "qamalib" qoladi va pastki
      // navigatsiya / suzuvchi f(x) tugmasi ustidan emas, yonidan chiqib
      // qoladi. Root navigator orqali butun ekranni qoplab chiqadi.
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        Widget option(String code, String label) {
          final selected = locale == code;
          return ListTile(
            onTap: () {
              sheetContext.read<AppBloc>().add(AppChangeLocale(code));
              Navigator.of(sheetContext).pop();
            },
            title: Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? _kPrimary : _kInk,
              ),
            ),
            trailing: selected
                ? const Icon(Icons.check_circle_rounded, color: _kPrimary)
                : null,
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                option('uz', _t(locale, 'uzbek')),
                option('ru', _t(locale, 'russian')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(String locale) {
    HapticFeedback.lightImpact();
    showCupertinoDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(_t(locale, 'logoutTitle')),
        content: Text(_t(locale, 'logoutMessage')),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(_t(locale, 'cancel')),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              final localSource = sl<LocalSource>();
              final phoneNumber = localSource.getPhoneNumber() ?? '';
              final password = localSource.getUserPassword() ?? '';
              final pinCode = localSource.getPinCode() ?? '';
              await localSource.clear();
              localSource.setPhoneNumber(phoneNumber);
              localSource.setUserPassword(password);
              localSource.setPinCode(pinCode);
              Navigator.of(dialogContext).pop();
              Navigator.of(rootNavigatorKey.currentContext!,
                      rootNavigator: true)
                  .pushNamedAndRemoveUntil(
                Routes.auth,
                (route) => false,
                arguments: AuthPageArgs(),
              );
            },
            child: Text(_t(locale, 'logout')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';
        final localSource = sl<LocalSource>();
        final fullName = _fullName(locale);
        final phone = localSource.getPhoneNumber() ?? '';
        final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A';

        return Scaffold(
          backgroundColor: _kBgBottom,
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(locale, fullName, phone, initial),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: StudentStatsCard(
                    locale: locale,
                    streak: _streak,
                    score: _statsLoading ? null : _score,
                    coin: _statsLoading ? null : _coin,
                    sum: _statsLoading ? null : _sum,
                    onTap: () => _openRoute(Routes.balls),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel(_t(locale, 'sectionProfile')),
                      _card([
                        _menuRow(
                          icon: Icons.person_rounded,
                          iconColor: _kPrimary,
                          iconBg: const Color(0xFFEAF0FF),
                          title: _t(locale, 'profilInfo'),
                          subtitle: _t(locale, 'profilInfoSub'),
                          onTap: () => _openEditProfile(locale),
                        ),
                        _divider(),
                        _menuRow(
                          icon: Icons.receipt_long_rounded,
                          iconColor: const Color(0xFF16A34A),
                          iconBg: const Color(0xFFE7F8EF),
                          title: _t(locale, 'myPayments'),
                          subtitle: _t(locale, 'myPaymentsSub'),
                          onTap: () => _openRoute(Routes.payments),
                        ),
                        _divider(),
                        _menuRow(
                          icon: Icons.workspace_premium_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          iconBg: const Color(0xFFFEF3C7),
                          title: _t(locale, 'certificates'),
                          subtitle: _t(locale, 'certificatesSub'),
                          onTap: _showComingSoon,
                        ),
                      ]),
                      const SizedBox(height: 22),
                      _sectionLabel(_t(locale, 'sectionSettings')),
                      _card([
                        // 2 ta qurilma cheklovi faqat o'quvchilarga tegishli
                        if ((sl<LocalSource>().getUserRole() ?? 'student') ==
                            'student') ...[
                          _menuRow(
                            icon: Icons.devices_rounded,
                            iconColor: const Color(0xFF0EA5E9),
                            iconBg: const Color(0xFFE0F2FE),
                            title: DeviceTexts.get(locale, 'tab'),
                            subtitle: DeviceTexts.get(locale, 'tabSub'),
                            onTap: () => _openRoute(Routes.devices),
                          ),
                          _divider(),
                        ],
                        _menuRow(
                          icon: Icons.language_rounded,
                          iconColor: _kPrimary,
                          iconBg: const Color(0xFFEAF0FF),
                          title: _t(locale, 'language'),
                          subtitle: _t(locale, 'languageSub'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                locale == 'ru'
                                    ? _t(locale, 'russian')
                                    : _t(locale, 'uzbek'),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: _kMuted,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 18, color: _kMuted),
                            ],
                          ),
                          onTap: () => _showLanguageSheet(locale),
                        ),
                      ]),
                      const SizedBox(height: 22),
                      _sectionLabel(_t(locale, 'sectionSupport')),
                      _card([
                        _menuRow(
                          icon: Icons.support_agent_rounded,
                          iconColor: const Color(0xFFE11D48),
                          iconBg: const Color(0xFFFCE7E9),
                          title: _t(locale, 'help'),
                          subtitle: _t(locale, 'helpSub'),
                          onTap: () => _openRoute(Routes.faq),
                        ),
                        _divider(),
                        _menuRow(
                          icon: Icons.shield_rounded,
                          iconColor: const Color(0xFF16A34A),
                          iconBg: const Color(0xFFDCFCE7),
                          title: _t(locale, 'privacy'),
                          subtitle: _t(locale, 'privacySub'),
                          onTap: _showComingSoon,
                        ),
                        _divider(),
                        _menuRow(
                          icon: Icons.logout_rounded,
                          iconColor: const Color(0xFFE11D48),
                          iconBg: const Color(0xFFFCE7E9),
                          title: _t(locale, 'logout'),
                          subtitle: _t(locale, 'logoutSub'),
                          onTap: () => _showLogoutDialog(locale),
                        ),
                      ]),
                    ],
                  ),
                ),
                // Pastdagi suzuvchi navigatsiya paneli va f(x) tugmasi
                // kontentni berkitib qo'ymasligi uchun bo'sh joy —
                // aks holda oxirgi qator (Ilovadan chiqish) bosilmay qoladi.
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Sarlavha: homepage.png foni + avatar + ism/telefon + tahrirlash tugmasi
  // ---------------------------------------------------------------------
  Widget _buildHeader(
    String locale,
    String fullName,
    String phone,
    String initial,
  ) {
    // Butun identifikatsiya bloki (avatar + ism + tugma) endi rasm
    // ICHIDA, uning pastki chetiga yaqin joylashadi — oq fon qismiga
    // "kirib" ketmaydi, shu sababli hech narsa berkitilmaydi.
    const photoHeight = 200.0;

    return SizedBox(
      height: photoHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: photoHeight,
            width: double.infinity,
            child: Image.asset(
              _imgCover,
              fit: BoxFit.cover,
              // Noutbuk rasmning eng o'ng chetida — markazdan biroz
              // chapga siljitib, gul va kitoblar ko'proq ko'rinadigan,
              // noutbuk esa kadrdan deyarli chiqib ketadigan qilib kesamiz.
              alignment: const Alignment(-0.15, 0),
              cacheWidth: 1400,
              errorBuilder: (_, __, ___) => const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B2BC9), Color(0xFF1B2FA8)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _buildBackButton(),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAvatar(locale, initial),
                      const SizedBox(height: 8),
                      Text(
                        fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: _kMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildEditProfileButton(locale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Profil endi chap tomondan slayd bo'lib ochiladigan drawer sifatida
  // ko'rsatiladi (qarang: MainPage.drawer) — shu sababli uni yopish uchun
  // orqaga qaytish tugmasi kerak.
  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          mainScaffoldKey.currentState?.closeDrawer();
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E1A4C).withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: _kPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileButton(String locale) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openEditProfile(locale),
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E1A4C).withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_outlined, size: 13, color: _kPrimary),
              const SizedBox(width: 5),
              Text(
                _t(locale, 'editProfile'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kPrimary,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right_rounded,
                  size: 14, color: _kPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String locale, String initial) {
    return GestureDetector(
      onTap: () => _openEditProfile(locale),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _kPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0E1A4C).withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            // Profil rasmi bo'lsa — rasm, bo'lmasa ismning bosh harfi
            child: sl<LocalSource>().getAvatarUrl() != null
                ? Image.network(
                    sl<LocalSource>().getAvatarUrl()!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Text(
                      initial,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  )
                : Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0E1A4C).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.edit_rounded, size: 12, color: _kPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Umumiy bo'lim widgetlari
  // ---------------------------------------------------------------------
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: _kMuted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E1A4C).withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Divider(height: 1, color: Color(0xFFF0F0F0)),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: _kMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  const Icon(Icons.chevron_right_rounded,
                      size: 20, color: _kMuted),
            ],
          ),
        ),
      ),
    );
  }
}
