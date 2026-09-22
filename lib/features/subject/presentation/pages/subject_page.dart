import 'dart:ui';

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

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubjectBloc>().add(GetSubjectEvent());
  }

  Future<void> _refreshData() async {
    context.read<SubjectBloc>().add(GetSubjectEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return BlocConsumer<SubjectBloc, SubjectState>(
          listener: (context, state) {},
          builder: (context, state) {
            return CupertinoPageScaffold(
              backgroundColor: CupertinoColors.systemGroupedBackground,
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
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final category = state.groupedSubjects?.keys
                                    .elementAt(index);
                                final books =
                                    state.groupedSubjects?[category] ?? [];

                                return CategorySection(
                                  categoryTitle: BaseFunctions.getLanguageText(
                                    languageCode: appState.appLocale,
                                    uz: category,
                                    ru: books.isNotEmpty
                                        ? books.first.nameRu
                                        : category,
                                  ),
                                  books: books,
                                  onRefresh: _refreshData,
                                );
                              },
                              childCount: state.groupedSubjects?.length ?? 0,
                            ),
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

class CategorySection extends StatelessWidget {
  final String categoryTitle;
  final List<SubjectResponse> books;
  final VoidCallback onRefresh;

  const CategorySection({
    super.key,
    required this.categoryTitle,
    required this.books,
    required this.onRefresh,
  });

  // Saytdagi CardSubject.jsx bilan bir xil zaxira palitra — rasmdan
  // avtomatik rang olish mobile tomonda yo'q, shu sababli guruh ichida
  // indeks bo'yicha aylanadigan sobit ranglar ishlatiladi.
  static const List<Color> _kCardAccents = [
    Color(0xFFEC4899),
    Color(0xFFF97316),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFF06B6D4),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Rasm 4:3 landshaft nisbatida to'liq ko'rinishi uchun karta ham
    // gorizontal (kengroq) bo'lishi kerak — avvalgi tor-baland (portret)
    // karta rasmni keskin kesib tashlar edi.
    final cardWidth = screenWidth * 0.62;

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF007AFF),
                          Color(0xFF0051D5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      categoryTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.label,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.book_fill,
                          size: 20,
                          color: Color(0xFF007AFF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${books.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: cardWidth * 0.75 + 78,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final grade = books[index].className ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: cardWidth,
                      child: BookCard(
                        isOpen: books[index].isOpen ?? true,
                        title: BaseFunctions.getLanguageText(
                          languageCode: appState.appLocale,
                          uz: books[index].nameUz ?? '',
                          ru: books[index].nameRu ?? '',
                        ),
                        gradeLabel: appState.appLocale == 'ru'
                            ? '$grade-класс'
                            : '$grade-sinf',
                        topicsCount: books[index].topicsCount?.toInt() ?? 0,
                        questionsCount:
                            books[index].questionsCount?.toInt() ?? 0,
                        accentColor:
                            _kCardAccents[index % _kCardAccents.length],
                        locale: appState.appLocale,
                        imagePath:
                            'https://api.iqmath.uz${books[index].imageUz ?? ''}',
                        id: books[index].id.toString(),
                        isDiagnostic: books[index].isDiagnostOpen ?? false,
                        onRefresh: onRefresh,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class BookCard extends StatefulWidget {
  final String title;
  final String gradeLabel;
  final int topicsCount;
  final int questionsCount;
  final Color accentColor;
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
    required this.accentColor,
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
      end: 0.95,
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
                          // Rasmingizni shu yerga qo'ying
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
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          // 'Diagnostika testini boshlang',
                          BaseFunctions.getLanguageText(
                            languageCode: appState.appLocale,
                            uz: "Diagnostika testini boshlang",
                            ru: "Начните диагностический тест",
                          ),
                          style: TextStyle(
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
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          // 'Bilimlar darajasini aniqlash uchun diagnostika testini yechishingiz lozim',
                          BaseFunctions.getLanguageText(
                            languageCode: appState.appLocale,
                            uz: "Bilimlar darajasini aniqlash uchun diagnostika testini yechishingiz lozim",
                            ru: "Вам необходимо пройти диагностический тест для определения уровня знаний",
                          ),
                          style: TextStyle(
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
                                child:  Text(
                                  // 'Boshlash',
                                  BaseFunctions.getLanguageText(
                                    languageCode: appState.appLocale,
                                    uz: "Boshlash",
                                    ru: "Начать",
                                  ),
                                  style: TextStyle(
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
                              child:  Text(
                                // 'Bekor qilish',
                                BaseFunctions.getLanguageText(
                                  languageCode: appState.appLocale,
                                  uz: "Bekor qilish",
                                  ru: "Отмена",
                                ),
                                style: TextStyle(
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

  static const Color iosBlue = CupertinoColors.systemBlue;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isRu = widget.locale == 'ru';

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isOpen) return;
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
        _handleTap();
      },
      onTapCancel: () {
        if (!widget.isOpen) return;
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isOpen ? _scaleAnimation.value : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rasm bloki — 4:3 landshaft, saytdagi kabi to'liq ko'rinadi
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: widget.imagePath.startsWith('http')
                                ? Image.network(
                                    widget.imagePath,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: CupertinoActivityIndicator(
                                          radius: screenHeight * 0.015,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildFallbackIcon(screenHeight);
                                    },
                                  )
                                : _buildFallbackIcon(screenHeight),
                          ),

                          // Blur + Lock overlay when isOpen = false
                          if (!widget.isOpen)
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.25),
                                        Colors.white.withOpacity(0.15),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        CupertinoIcons.lock_fill,
                                        color: Colors.white,
                                        size: screenHeight * 0.05,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Sinf belgisi + fan nomi — rasm ustida, saytdagiday
                          Positioned(
                            left: 10,
                            right: 10,
                            top: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.accentColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.gradeLabel,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF191C1D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pastki bo'lim — dars/mashq soni + strelka tugmasi
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _statPill(
                              icon: CupertinoIcons.book,
                              text:
                                  '${widget.topicsCount} ${isRu ? 'урок' : 'dars'}',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _statPill(
                              icon: CupertinoIcons.doc_text,
                              text: '${widget.questionsCount} '
                                  '${isRu ? 'пример' : 'mashq'}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.arrow_right,
                              size: 13,
                              color: Colors.white,
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
        },
      ),
    );
  }

  Widget _statPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iosBlue),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5768),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(double screenHeight) {
    return Center(
      child: Container(
        width: screenHeight * 0.1,
        height: screenHeight * 0.1,
        decoration: BoxDecoration(
          color: iosBlue.withOpacity(0.15),
          borderRadius: BorderRadius.circular(screenHeight * 0.05),
        ),
        child: Icon(
          CupertinoIcons.book_fill,
          size: screenHeight * 0.045,
          color: iosBlue,
        ),
      ),
    );
  }
}
