import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home/widgets/payment_screen.dart';
import 'package:my_flutter_template/features/subject/data/models/subject_response.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/topic_card.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:my_flutter_template/router/name_routes.dart';
import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../generated/assets.dart';
import '../bloc/subject_bloc/subject_bloc.dart';
import '../widget/book_card_widget.dart';
import 'package:flutter/material.dart';
import '../widget/subject_stats_widgets.dart';

bool _isGrade(String? className) =>
    className != null && RegExp(r'^\d+$').hasMatch(className);

/// Bitta fan bo'limi (Matematika, Algebra, ...) — sahifa va statistika uchun.
class _SubjectSection {
  final String title;
  final List<SubjectResponse> books;
  final List<SubjectResponse> graded; // faqat sinflarga bo'lingan, tartiblangan
  final SubjectTheme theme;

  _SubjectSection({
    required this.title,
    required this.books,
    required this.theme,
  }) : graded = books.where((b) => _isGrade(b.className)).toList()
          ..sort((a, b) =>
              int.parse(a.className!).compareTo(int.parse(b.className!)));

  int? get firstGrade =>
      graded.isEmpty ? null : int.parse(graded.first.className!);

  int? get lastGrade => graded.isEmpty ? null : int.parse(graded.last.className!);
}

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final Map<int, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    context.read<SubjectBloc>().add(GetSubjectEvent());
  }

  Future<void> _refreshData() async {
    context.read<SubjectBloc>().add(GetSubjectEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  GlobalKey _keyFor(int index) =>
      _sectionKeys.putIfAbsent(index, () => GlobalKey());

  void _scrollToSection(int index) {
    final ctx = _sectionKeys[index]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  List<_SubjectSection> _buildSections(
    Map<String, List<SubjectResponse>>? grouped,
    String? locale,
  ) {
    final entries = (grouped ?? {}).entries.toList();
    return [
      for (var i = 0; i < entries.length; i++)
        _SubjectSection(
          title: BaseFunctions.getLanguageText(
            languageCode: locale,
            uz: entries[i].key,
            ru: entries[i].value.isNotEmpty
                ? (entries[i].value.first.nameRu ?? entries[i].key)
                : entries[i].key,
          ),
          books: entries[i].value,
          theme: SubjectTheme.of(
            entries[i].value.isNotEmpty
                ? (entries[i].value.first.nameUz ?? entries[i].key)
                : entries[i].key,
            i,
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return BlocConsumer<SubjectBloc, SubjectState>(
          listener: (context, state) {},
          builder: (context, state) {
            final sections =
                _buildSections(state.groupedSubjects, appState.appLocale);
            final statsSections = [
              for (var i = 0; i < sections.length; i++)
                if (sections[i].graded.isNotEmpty) i,
            ];

            return CupertinoPageScaffold(
              backgroundColor: const Color(0xFFF6F8FC),
              navigationBar: CupertinoNavigationBar(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF007AFF),
                            Color(0xFF5856D6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF007AFF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        Assets.svgBookBottom,
                        color: context.color.white,
                        width: 28,
                        height: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      localization.subjects,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                bottom: const PreferredSize(
                  preferredSize: Size(
                    double.infinity,
                    8,
                  ),
                  child: SizedBox.shrink(),
                ),
                backgroundColor: CupertinoColors.white,
                automaticBackgroundVisibility: false,
              ),
              child: Stack(
                children: [
                  SafeArea(
                    minimum: const EdgeInsets.only(bottom: 32),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        CupertinoSliverRefreshControl(
                          onRefresh: _refreshData,
                        ),
                        // Barcha bo'limlar bitta blokda quriladi — "Barchasini
                        // ko'rish" bosilganda istalgan bo'limga aylantirish uchun
                        // ularning hammasi doim chizilgan bo'lishi kerak.
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (statsSections.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: StatsCarousel(
                                    children: [
                                      for (final i in statsSections)
                                        _StatsCard(
                                          section: sections[i],
                                          locale: appState.appLocale,
                                          onSeeAll: () => _scrollToSection(i),
                                        ),
                                    ],
                                  ),
                                ),
                              for (var i = 0; i < sections.length; i++)
                                _CategorySection(
                                  key: _keyFor(i),
                                  section: sections[i],
                                  locale: appState.appLocale,
                                  onRefresh: _refreshData,
                                ),
                            ],
                          ),
                        ),
                        const SliverGap(80),
                      ],
                    ),
                  ),
                  if (state.status == SubjectStateStatus.loading)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CupertinoActivityIndicator(radius: 16),
                          const SizedBox(height: 16),
                          Text(
                            localization.loading,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════ Statistika kartasi ═══════════════════════════

/// Fan turi bo'yicha umumiy statistika: darslar holati va sinflar kesimidagi
/// progress (umumiy SubjectStatsCard asosida, saytdagi StatsCard).
class _StatsCard extends StatelessWidget {
  final _SubjectSection section;
  final String? locale;
  final VoidCallback onSeeAll;

  const _StatsCard({
    required this.section,
    required this.locale,
    required this.onSeeAll,
  });

  String _t(String uz, String ru) =>
      BaseFunctions.getLanguageText(languageCode: locale, uz: uz, ru: ru);

  @override
  Widget build(BuildContext context) {
    final graded = section.graded;
    final total = graded.fold<num>(0, (s, b) => s + (b.topicsCount ?? 0));
    final completed =
        graded.fold<num>(0, (s, b) => s + (b.completedTopics ?? 0));
    final inProgress =
        graded.fold<num>(0, (s, b) => s + (b.inProgressTopics ?? 0));
    final notStarted = math.max<num>(0, total - completed - inProgress);

    final first = section.firstGrade;
    final last = section.lastGrade;

    return SubjectStatsCard(
      title: section.title,
      theme: section.theme,
      gradesLabel: first == last
          ? _t('$first-sinf uchun', 'Для $first класса')
          : _t('$first-$last sinflar uchun', 'Для $first-$last классов'),
      overall: subjectPercent(completed, total),
      overallLabel: _t('Umumiy progress', 'Общий прогресс'),
      legend: [
        StatsLegendItem(
            color: section.theme.accent,
            label: _t('Jami darslar', 'Всего уроков'),
            value: total),
        StatsLegendItem(
            color: kStatsCompletedColor,
            label: _t('Yakunlangan', 'Завершено'),
            value: completed),
        StatsLegendItem(
            color: kStatsInProgressColor,
            label: _t('Davom etilmoqda', 'В процессе'),
            value: inProgress),
        StatsLegendItem(
            color: kStatsNotStartedColor,
            label: _t('Boshlanmagan', 'Не начато'),
            value: notStarted),
      ],
      grades: [
        for (final b in graded)
          (
            label: b.className!,
            value: subjectPercent(b.completedTopics ?? 0, b.topicsCount ?? 0),
          ),
      ],
      seeAllLabel: _t("Barchasini ko'rish", 'Смотреть все'),
      onSeeAll: onSeeAll,
    );
  }
}


// ═══════════════════════════ Fan bo'limi va kartalar ═══════════════════════════

class _CategorySection extends StatelessWidget {
  final _SubjectSection section;
  final String? locale;
  final VoidCallback onRefresh;

  const _CategorySection({
    super.key,
    required this.section,
    required this.locale,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final books = section.books;
    final first = section.firstGrade;
    final last = section.lastGrade;
    final subtitle = first == null
        ? ''
        : first == last
            ? BaseFunctions.getLanguageText(
                languageCode: locale,
                uz: '$first-sinf uchun darsliklar va mashqlar',
                ru: 'Учебники и задания для $first класса',
              )
            : BaseFunctions.getLanguageText(
                languageCode: locale,
                uz: '$first-$last sinflar uchun darsliklar va mashqlar',
                ru: 'Учебники и задания для $first-$last классов',
              );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sarlavha: rangli chiziq, nom va izoh
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 5,
                height: 28,
                decoration: BoxDecoration(
                  color: section.theme.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: kSubjectTitleColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style:
                            const TextStyle(fontSize: 12.5, color: kSubjectMutedColor),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2 ustunli setka; bir qatordagi kartalar balandligi teng
          for (var row = 0; row < books.length; row += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildCard(books[row])),
                    const SizedBox(width: 12),
                    Expanded(
                      child: row + 1 < books.length
                          ? _buildCard(books[row + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(SubjectResponse book) {
    final grade = book.className ?? '';
    final isRu = locale == 'ru';
    return BookCard(
      isOpen: book.isOpen ?? true,
      title: BaseFunctions.getLanguageText(
        languageCode: locale,
        uz: book.nameUz ?? '',
        ru: book.nameRu ?? '',
      ),
      gradeLabel: _isGrade(grade) ? (isRu ? '$grade-класс' : '$grade-sinf') : grade,
      topicsCount: book.topicsCount?.toInt() ?? 0,
      questionsCount: book.questionsCount?.toInt() ?? 0,
      progress: math.min(100, math.max(0, book.progress?.round() ?? 0)),
      accentColor: section.theme.accent,
      softColor: section.theme.soft,
      locale: locale,
      imagePath: 'https://api.iqmath.uz${book.imageUz ?? ''}',
      id: book.id.toString(),
      isDiagnostic: book.isDiagnostOpen ?? false,
      onRefresh: onRefresh,
    );
  }
}

class BookCard extends StatefulWidget {
  final String title;
  final String gradeLabel;
  final int topicsCount;
  final int questionsCount;
  final int progress;
  final Color accentColor;
  final Color softColor;
  final String? locale;
  final String imagePath;
  final String id;
  final bool isOpen;
  final bool isDiagnostic;
  final VoidCallback onRefresh;

  const BookCard({
    super.key,
    required this.title,
    required this.gradeLabel,
    required this.topicsCount,
    required this.questionsCount,
    required this.progress,
    required this.accentColor,
    required this.softColor,
    this.locale,
    required this.imagePath,
    required this.id,
    required this.isOpen,
    required this.isDiagnostic,
    required this.onRefresh,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showDiagnosticDialog() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<AppBloc, AppState>(
          builder: (context, appState) {
            return Material(
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag indicator
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              CupertinoColors.systemGrey3.resolveFrom(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Icon
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/shield_icon.png',
                          width: 64,
                          height: 64,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              CupertinoIcons.checkmark_shield_fill,
                              size: 48,
                              color: Color(0xFF007AFF),
                            );
                          },
                        ),
                      ),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          BaseFunctions.getLanguageText(
                            languageCode: appState.appLocale,
                            uz: "Diagnostika testini boshlang",
                            ru: "Начните диагностический тест",
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.label,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          BaseFunctions.getLanguageText(
                            languageCode: appState.appLocale,
                            uz: "Bilimlar darajasini aniqlash uchun diagnostika testini yechishingiz lozim",
                            ru: "Вам необходимо пройти диагностический тест для определения уровня знаний",
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.secondaryLabel,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Start button
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                Navigator.pop(context);
                                HapticFeedback.mediumImpact();
                                await Navigator.pushNamed(
                                  mainRootNavigatorKey.currentContext!,
                                  Routes.questions,
                                  arguments: QuestionPageArguments(
                                    topic: null,
                                    isDiagnostic: true,
                                    taskName: widget.title,
                                    subjectId: widget.id,
                                  ),
                                ).then((value) {
                                  widget.onRefresh();
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF007AFF),
                                      Color(0xFF0051D5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF007AFF)
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  BaseFunctions.getLanguageText(
                                    languageCode: appState.appLocale,
                                    uz: "Boshlash",
                                    ru: "Начать",
                                  ),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Cancel button
                            CupertinoButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                BaseFunctions.getLanguageText(
                                  languageCode: appState.appLocale,
                                  uz: "Bekor qilish",
                                  ru: "Отмена",
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF007AFF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleTap() {
    if (!widget.isOpen) {
      // Agar ochilmagan bo'lsa, tarif rejasi ekraniga o'tish
      Navigator.push(
        mainRootNavigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => const TarifRejasiScreen(),
        ),
      );
    } else if (!widget.isDiagnostic) {
      // Agar diagnostika yechilmagan bo'lsa, dialog ko'rsatish
      _showDiagnosticDialog();
    } else {
      // Agar hammasi ok bo'lsa, oddiy subject detail ga o'tish
      Navigator.pushNamed(
        mainRootNavigatorKey.currentContext!,
        Routes.subjectDetail,
        arguments: SubjectDetailArguments(
          id: widget.id,
          subjectName: widget.title,
        ),
      ).then((value) {
        if (value.toString() == 'Telegram') {
          Navigator.pushNamed(
            mainRootNavigatorKey.currentContext!,
            Routes.telegramBot,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRu = widget.locale == 'ru';
    final accent = widget.accentColor;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        _handleTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEDF0F5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F1B3D).withOpacity(0.07),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rasm — kesilmasdan, to'liq ko'rinadi (saytdagi 1920x819 nisbat)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 1920 / 819,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: const Color(0xFFF4F7FC),
                        child: widget.imagePath.startsWith('http')
                            ? Image.network(
                                widget.imagePath,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child:
                                        CupertinoActivityIndicator(radius: 9),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackIcon(),
                              )
                            : _buildFallbackIcon(),
                      ),
                      if (!widget.isOpen)
                        Container(
                          color: Colors.black.withOpacity(0.2),
                          alignment: Alignment.center,
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(CupertinoIcons.lock_fill,
                                size: 16, color: accent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sinf, fan nomi va strelka
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.gradeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: kSubjectTitleColor,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF5B6478),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.softColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isOpen
                                  ? CupertinoIcons.arrow_right
                                  : CupertinoIcons.lock_fill,
                              size: 14,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Dars va mashq soni
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          _stat(
                            CupertinoIcons.book,
                            '${widget.topicsCount} ${isRu ? 'урок' : 'dars'}',
                          ),
                          _stat(
                            CupertinoIcons.doc_text,
                            '${widget.questionsCount} ${isRu ? 'пример' : 'mashq'}',
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 10),

                      // Progress
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: widget.progress / 100,
                                minHeight: 6,
                                backgroundColor: kSubjectTrackColor,
                                valueColor: AlwaysStoppedAnimation(accent),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.progress}%',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5B6478),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: widget.accentColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kSubjectMutedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(
        CupertinoIcons.book_fill,
        size: 28,
        color: widget.accentColor.withOpacity(0.6),
      ),
    );
  }
}
