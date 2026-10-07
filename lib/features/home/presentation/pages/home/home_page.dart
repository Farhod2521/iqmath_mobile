import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/home_dashboard_model.dart';
import 'package:my_flutter_template/features/home_dashboard/domain/usecases/get_home_dashboard_usecase.dart';
import 'package:my_flutter_template/features/main/presentation/bloc/main_bloc.dart';
import 'package:my_flutter_template/features/subject/data/models/topic_model.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/topic_card.dart'
    show QuestionPageArguments;
import 'package:my_flutter_template/generated/assets.dart';
import 'package:my_flutter_template/features/home/presentation/widgets/notifications_popup.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:my_flutter_template/router/name_routes.dart';

/// Bosh sahifa ranglari
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF64748B);
const Color _kPrimary = Color(0xFF2563EB);
const Color _kIconBg = Color(0xFFEAF1FE);
const Color _kBgTop = Color(0xFFE9F0FB);
const Color _kBgBottom = Color(0xFFF7FAFE);

/// 3D illyustratsiyalar — `assets/images/` ichidagi raqamli PNG'lar.
/// 1, 2, 3 allaqachon mavjud; 4–7 qo'shilishi bilan avtomatik ko'rinadi
/// (mavjud bo'lmasa ikonka fallback ishlaydi).
const String _imgCourses = 'assets/images/1.png'; // kitoblar + bitiruv shapkasi
const String _imgDiagnostics = 'assets/images/2.png'; // planshet + belgilar
const String _imgAlgebra = 'assets/images/3.png'; // kitoblar + x²
const String _imgDailyTest = 'assets/images/5.png'; // nishon + o'q
const String _imgQuickTest = 'assets/images/6.png'; // kub
const String _imgRating = 'assets/images/7.png'; // kubok
const String _imgBattle = 'assets/images/4.png'; // battle uchun
const String _imgWelcome = 'assets/images/homepage.png'; // salomlashuv foni
const String _imgAiBackground =
    'assets/images/ai-background.png'; // AI banner foni

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<HomeDashboardModel?> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<HomeDashboardModel?> _loadDashboard() async {
    final result =
        await sl<GetHomeDashboardUseCase>()(GetHomeDashboardParams());
    return result.fold((_) => null, (data) => data);
  }

  Future<void> _refresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
    await _dashboardFuture;
  }

  void _openProfile() {
    HapticFeedback.lightImpact();
    // Logotibga bosilganda pastdagi navbar tabini almashtirish o'rniga —
    // chap tomondan slayd bo'lib ochiladigan drawer sifatida ko'rsatiladi
    // (profil endi alohida bottom-nav tabi emas).
    mainScaffoldKey.currentState?.openDrawer();
  }

  void _switchMainPage(MainPages page) {
    HapticFeedback.lightImpact();
    context.read<MainBloc>().add(MainPageChangeEvent(page));
  }

  /// "Davom etish" bosilganda — frontenddagi
  /// /dashboard/student/subjects/{subjectId}/{chapterId}/{topicId} bilan
  /// bir xil — to'g'ridan-to'g'ri o'sha mavzuning savollariga o'tkazadi.
  /// QuestionPage faqat `topic.id`ni o'qiydi, shu sababli boshqa
  /// maydonlar uchun to'liq TopicModel qayta so'ralmaydi.
  void _openContinueLearning(
    ContinueLearningModel? continueLearning,
    String locale,
  ) {
    HapticFeedback.lightImpact();
    final topicId = continueLearning?.topicId;
    if (topicId == null) {
      _switchMainPage(MainPages.subjects);
      return;
    }

    Navigator.pushNamed(
      mainRootNavigatorKey.currentContext!,
      Routes.questions,
      arguments: QuestionPageArguments(
        topic: TopicModel(
          id: topicId,
          chapter: continueLearning?.chapterId ?? 0,
          nameUz: continueLearning?.chapterNameUz ?? '',
          nameRu: continueLearning?.chapterNameRu ?? '',
          videoUrlUz: '',
          videoUrlRu: '',
          contentUz: '',
          contentRu: '',
          isLocked: false,
          isOpen: true,
          score: 0.0,
        ),
        isDiagnostic: false,
        taskName: continueLearning?.chapterName(locale),
      ),
    );
  }

  void _showComingSoon() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tez orada"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _t(String locale, String key) {
    const uz = {
      'continueLabel': 'DAVOM ETING',
      'startPrompt': "O'qishni boshlang",
      'continueButton': 'Davom etish',
      'courses': 'Kurslar',
      'coursesSub': 'Bilimingizni oshiring',
      'battle': 'Battle',
      'battleSub': "Do'stlaringiz bilan bellashing",
      'diagnostics': 'Diagnostika',
      'diagnosticsSub': 'Bilim darajangizni testing orqali biling',
      'new': 'YANGI',
      'grade7': '7-sinf Algebra',
      'grade7Sub': "O'rganishni davom ettiring",
      'view': "Ko'rish",
      'premiumTitle': 'AI yordamchi',
      'premiumSubtitle': "Matematikani mukammal o'rganing! Tez kunda",
      'premiumButton': 'Batafsil',
      'sectionTitle': "O'zingizni sinab ko'ring",
      'dailyTest': 'Kunlik test',
      'dailyTestSub': 'Har kuni yangi savollar',
      'quickTest': 'Tezkor savollar',
      'quickTestSub': 'Tezkor bilim sinovi',
      'rating': 'Reyting',
      'ratingSub': "O'z natijalaringizni kuzating",
    };

    const ru = {
      'continueLabel': 'ПРОДОЛЖИТЬ',
      'startPrompt': 'Начните обучение',
      'continueButton': 'Продолжить',
      'courses': 'Курсы',
      'coursesSub': 'Повышайте свои знания',
      'battle': 'Battle',
      'battleSub': 'Сражайтесь с друзьями',
      'diagnostics': 'Диагностика',
      'diagnosticsSub': 'Узнайте свой уровень через тест',
      'new': 'НОВОЕ',
      'grade7': '7-класс Алгебра',
      'grade7Sub': 'Продолжайте обучение',
      'view': 'Открыть',
      'premiumTitle': 'AI помощник',
      'premiumSubtitle': 'Изучайте математику идеально! Уже скоро',
      'premiumButton': 'Подробнее',
      'sectionTitle': 'Проверьте себя',
      'dailyTest': 'Тест дня',
      'dailyTestSub': 'Каждый день новые вопросы',
      'quickTest': 'Быстрые вопросы',
      'quickTestSub': 'Быстрая проверка знаний',
      'rating': 'Рейтинг',
      'ratingSub': 'Следите за своими результатами',
    };

    final map = locale == 'ru' ? ru : uz;
    return map[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale ?? 'uz';

        return Scaffold(
          backgroundColor: _kBgBottom,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_kBgTop, _kBgBottom],
                stops: [0.0, 0.45],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(onRefresh: _refresh),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(locale),
                          const SizedBox(height: 16),
                          _buildContinueLearningBanner(locale),
                          const SizedBox(height: 16),
                          _buildPrimaryCards(locale),
                          const SizedBox(height: 14),
                          _buildSecondaryCards(locale),
                          const SizedBox(height: 20),
                          _buildAiBanner(locale),
                          const SizedBox(height: 24),
                          _buildSectionHeader(_t(locale, 'sectionTitle')),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildChallengeCards(locale)),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Yuqori panel: avatar + salomlashuv, bildirishnoma, til va statistika kartasi
  // ---------------------------------------------------------------------------
  String _h(String locale, String key) {
    const uz = {
      'hello': 'Salom,',
    };
    const ru = {
      'hello': 'Привет,',
    };
    return (locale == 'ru' ? ru : uz)[key] ?? key;
  }

  Widget _buildTopBar(String locale) {
    return FutureBuilder<HomeDashboardModel?>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final header = data?.header;
        final storedName = sl<LocalSource>().getFirstName() ?? '';
        final name = (header?.firstName.isNotEmpty ?? false)
            ? header!.firstName
            : _greetingName(storedName);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _avatar(storedName.isNotEmpty ? storedName : name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _h(locale, 'hello'),
                        style: const TextStyle(fontSize: 14, color: _kMuted),
                      ),
                      Text(
                        name.isEmpty ? '' : '$name!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _bellButton(locale),
                const SizedBox(width: 8),
                _languageButton(locale),
              ],
            ),
          ],
        );
      },
    );
  }

  /// "ABDIKARIMOV FARHOD" -> "Farhod"
  String _greetingName(String fullName) {
    final parts = fullName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final word = parts.length > 1 ? parts[1] : parts[0];
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  Widget _avatar(String fullName) {
    final letters = fullName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return GestureDetector(
      onTap: _openProfile,
      child: Container(
        width: 62,
        height: 62,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7DB4FF), Color(0xFF2563EB)],
            ),
          ),
          child: Text(
            letters.isEmpty ? '?' : letters,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundWhite({
    required Widget child,
    required void Function(Rect anchor) onTap,
  }) {
    return Builder(
      builder: (buttonContext) => Material(
        color: Colors.white,
        shape: const StadiumBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            // Tugmaning ekrandagi o'rni — ochiladigan oyna shu tugma ostida chiqadi
            final box = buttonContext.findRenderObject() as RenderBox;
            onTap(box.localToGlobal(Offset.zero) & box.size);
          },
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0E1A4C).withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _bellButton(String locale) {
    return _roundWhite(
      onTap: (anchor) => showNotificationsPopup(
        context,
        anchor: anchor,
        locale: locale,
        onOpenAll: () => Navigator.pushNamed(
          mainRootNavigatorKey.currentContext!,
          Routes.notification,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded, size: 24, color: _kInk),
          Positioned(
            right: 1,
            top: 1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Til tugmasi: bosilganda ostida UZ / RU tanlash ro'yxati ochiladi
  Future<void> _openLanguageMenu(Rect anchor, String locale) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      elevation: 10,
      shadowColor: const Color(0x330E1A4C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      constraints: const BoxConstraints(minWidth: 170),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(anchor.left, anchor.bottom + 6, anchor.width, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        _languageItem('uz', "O'zbekcha", Assets.pngUzbek, locale == 'uz'),
        _languageItem('ru', 'Русский', Assets.pngRussia, locale == 'ru'),
      ],
    );
    if (!mounted || selected == null || selected == locale) return;
    context.read<AppBloc>().add(AppChangeLocale(selected));
  }

  PopupMenuItem<String> _languageItem(
      String value, String title, String flag, bool isSelected) {
    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(flag, width: 24, height: 24, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? _kPrimary : _kInk,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, size: 20, color: _kPrimary),
        ],
      ),
    );
  }

  Widget _languageButton(String locale) {
    return _roundWhite(
      onTap: (anchor) => _openLanguageMenu(anchor, locale),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(
              locale == 'ru' ? Assets.pngRussia : Assets.pngUzbek,
              width: 22,
              height: 22,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            locale == 'ru' ? 'RU' : 'UZ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _kInk),
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // "Davom eting" banneri: homepage.png rasmi TO'LIQ (kesilmagan holda)
  // ko'rinadi — banner balandligi rasmning haqiqiy nisbatiga moslanadi.
  // Ustiga frontenddagi (iqmath_student) bilan bir xil "continue learning"
  // ma'lumotlari — fan, bob, progress va "Davom etish" tugmasi chiqadi.
  // ---------------------------------------------------------------------------
  Widget _buildContinueLearningBanner(String locale) {
    return FutureBuilder<HomeDashboardModel?>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final continueLearning = snapshot.data?.continueLearning;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        final subjectTitle = continueLearning?.subjectName(locale) ?? '';
        final chapterTitle = continueLearning?.chapterName(locale) ?? '';
        final percent = (continueLearning?.percent ?? 0).clamp(0, 100);

        return GestureDetector(
          onTap: () => _openContinueLearning(continueLearning, locale),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B2FA8).withOpacity(0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                // Oldingi versiyada rasm nisbatiga qattiq bog'langan edi
                // (kesilishning oldini olish uchun), lekin natijada banner
                // juda ingichka chiqqan edi. Endi balandlikni ko'proq
                // beramiz — rasm ham, matn ham kattaroq va ko'zga
                // tashlanadigan bo'ladi; noutbuk shu bilan birga kadrdan
                // chiqib ketadigan alignment saqlanadi.
                height: 172,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _imgWelcome,
                      fit: BoxFit.cover,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _t(locale, 'continueLabel'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _kPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isLoading
                                      ? '...'
                                      : (subjectTitle.isEmpty
                                          ? _t(locale, 'startPrompt')
                                          : subjectTitle),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _kInk,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (chapterTitle.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    chapterTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _kMuted,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: SizedBox(
                                        width: 90,
                                        height: 5,
                                        child: LinearProgressIndicator(
                                          value: percent / 100,
                                          backgroundColor:
                                              const Color(0xFFE7EEFB),
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                  _kPrimary),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$percent%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _kPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _kPrimary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _t(locale, 'continueButton'),
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 1-qator: Kurslar + Kalkulyator
  // ---------------------------------------------------------------------------
  Widget _buildPrimaryCards(String locale) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _featureCard(
              onTap: () => _switchMainPage(MainPages.subjects),
              title: _t(locale, 'courses'),
              subtitle: _t(locale, 'coursesSub'),
              linkText: _t(locale, 'view'),
              image: _imgCourses,
              fallbackIcon: Icons.menu_book_rounded,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _featureCard(
              // Kalkulyator endi pastdagi suzuvchi f(x) tugmasi orqali
              // har doim ochiq — shu o'rinni "Battle" egallaydi.
              onTap: () => Navigator.pushNamed(
                mainRootNavigatorKey.currentContext!,
                Routes.battle,
              ),
              title: _t(locale, 'battle'),
              subtitle: _t(locale, 'battleSub'),
              linkText: _t(locale, 'view'),
              image: _imgBattle,
              fallbackIcon: Icons.emoji_events_rounded,
              badge: _t(locale, 'new'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2-qator: Diagnostika + davom etayotgan kurs
  // ---------------------------------------------------------------------------
  Widget _buildSecondaryCards(String locale) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _featureCard(
              onTap: () => _switchMainPage(MainPages.diagnostics),
              title: _t(locale, 'diagnostics'),
              subtitle: _t(locale, 'diagnosticsSub'),
              linkText: _t(locale, 'view'),
              image: _imgDiagnostics,
              fallbackIcon: Icons.fact_check_rounded,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _featureCard(
              onTap: () => _switchMainPage(MainPages.subjects),
              title: _t(locale, 'grade7'),
              subtitle: _t(locale, 'grade7Sub'),
              linkText: _t(locale, 'view'),
              image: _imgAlgebra,
              fallbackIcon: Icons.functions_rounded,
              progress: 0.33,
            ),
          ),
        ],
      ),
    );
  }

  /// 2x2 gridning universal kartasi
  Widget _featureCard({
    required VoidCallback onTap,
    required String title,
    required String subtitle,
    required String linkText,
    required String image,
    required IconData fallbackIcon,
    String? badge,
    double? progress,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E1A4C).withOpacity(0.07),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _illustration(
                            image,
                            fallbackIcon,
                            size: 52,
                          ),
                          if (badge != null) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _kIconBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _kPrimary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                      if (progress != null) ...[
                        const SizedBox(height: 10),
                        _progressRow(progress),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: _kMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            linkText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kPrimary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: _kPrimary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _progressRow(double progress) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE7EEFB),
                valueColor: const AlwaysStoppedAnimation(_kPrimary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).round()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // AI yordamchi banneri
  // ---------------------------------------------------------------------------
  Widget _buildAiBanner(String locale) {
    return GestureDetector(
      onTap: () => _switchMainPage(MainPages.products),
      child: Container(
        // Vertikal jihatdan ixchamlashtirildi; rasm butun kenglikni egallaydi
        height: 148,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B2BC9).withOpacity(0.26),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fon: ai-background.png — 100% kenglik, o'ngdagi robot ko'rinib turadi
              Image.asset(
                _imgAiBackground,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: 1100,
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
              // Matn kontrasti uchun chapdan yengil qoraytirish
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF221FA8).withOpacity(0.55),
                      const Color(0xFF221FA8).withOpacity(0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 0.8],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 53,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _t(locale, 'premiumTitle'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _t(locale, 'premiumSubtitle'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.88),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 9, 12, 9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _t(locale, 'premiumButton'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B2FA8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: Color(0xFF1B2FA8),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // O'ng tomon robot uchun bo'sh qoladi
                    const Spacer(flex: 47),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.2,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // "O'zingizni sinab ko'ring" — gorizontal kartalar
  // ---------------------------------------------------------------------------
  Widget _buildChallengeCards(String locale) {
    final items = <_ChallengeItem>[
      _ChallengeItem(
        title: _t(locale, 'dailyTest'),
        subtitle: _t(locale, 'dailyTestSub'),
        image: _imgDailyTest,
        fallbackIcon: Icons.track_changes_rounded,
        background: const Color(0xFFEDE7FE),
        accent: const Color(0xFF7C5CFB),
      ),
      _ChallengeItem(
        title: _t(locale, 'quickTest'),
        subtitle: _t(locale, 'quickTestSub'),
        image: _imgQuickTest,
        fallbackIcon: Icons.view_in_ar_rounded,
        background: const Color(0xFFDCEAFE),
        accent: _kPrimary,
      ),
      _ChallengeItem(
        title: _t(locale, 'rating'),
        subtitle: _t(locale, 'ratingSub'),
        image: _imgRating,
        fallbackIcon: Icons.emoji_events_rounded,
        background: const Color(0xFFFEF0CE),
        accent: const Color(0xFFE9A319),
      ),
    ];

    return SizedBox(
      height: 232,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _challengeCard(items[index]),
      ),
    );
  }

  Widget _challengeCard(_ChallengeItem item) {
    return GestureDetector(
      onTap: _showComingSoon,
      child: Container(
        width: 168,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: item.background,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: _illustration(
                  item.image,
                  item.fallbackIcon,
                  size: 92,
                  fallbackColor: item.accent,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _kInk,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: _kMuted,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// PNG illyustratsiya; fayl hali qo'shilmagan bo'lsa — ikonka bilan almashadi.
  Widget _illustration(
    String asset,
    IconData fallbackIcon, {
    required double size,
    Color? fallbackColor,
  }) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // PNG'lar ~1200px, ekranda esa 100px atrofida — dekodlashni cheklaymiz
      cacheWidth: (size * 3).round(),
      errorBuilder: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(
            fallbackIcon,
            size: size * 0.55,
            color: (fallbackColor ?? _kPrimary).withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}

class _ChallengeItem {
  final String title;
  final String subtitle;
  final String image;
  final IconData fallbackIcon;
  final Color background;
  final Color accent;

  const _ChallengeItem({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.fallbackIcon,
    required this.background,
    required this.accent,
  });
}
