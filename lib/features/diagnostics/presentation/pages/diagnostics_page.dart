import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/features/diagnostics/data/models/subject.dart';
import 'package:my_flutter_template/features/suggestion/presentation/widget/suggestion_chapter_widget.dart';
import 'dart:convert';
import 'dart:ui';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../generated/assets.dart';
import '../../../../injector_container.dart';
import '../../../../router/app_routes.dart';
import '../../../../router/name_routes.dart';
import '../../../subject/presentation/widget/topic_card.dart';

class DiagnosticsLocalization {
  static Map<String, Map<String, String>> translations = {
    'uz': {
      'diagnostics': 'Diagnostika',
      'diagnosticsSub': 'Bilim darajangizni tekshirib ko\'ring',
      'loading': 'Yuklanmoqda...',
      'loadError': 'Ma\'lumotlarni yuklashda xatolik yuz berdi',
      'internetError': 'Internet bilan bog\'lanishda muammo',
      'tryAgain': 'Iltimos, qaytadan urinib ko\'ring',
      'reload': 'Qaytadan yuklash',
      'all': 'Hammasi',
      'started': 'Boshlangan',
      'notStarted': 'Boshlanmagan',
      'finished': 'Yakunlangan',
      'noBooksFound': 'Darsliklar topilmadi',
      'noAssignedBooks': 'Hozircha sizga tayinlangan darsliklar yo\'q',
      'noFilteredBooks': 'Bu filtrga mos darsliklar topilmadi',
      'new': 'Yangi',
      'start': 'Boshlash',
    },
    'ru': {
      'diagnostics': 'Диагностика',
      'diagnosticsSub': 'Проверьте уровень своих знаний',
      'loading': 'Загрузка...',
      'loadError': 'Ошибка при загрузке данных',
      'internetError': 'Проблема с подключением к интернету',
      'tryAgain': 'Пожалуйста, попробуйте еще раз',
      'reload': 'Перезагрузить',
      'all': 'Все',
      'started': 'Начатые',
      'notStarted': 'Не начатые',
      'finished': 'Завершённые',
      'noBooksFound': 'Учебники не найдены',
      'noAssignedBooks': 'Пока вам не назначены учебники',
      'noFilteredBooks': 'Учебники по этому фильтру не найдены',
      'new': 'Новый',
      'start': 'Начать',
    },
  };

  static String get(String key, String locale) {
    return translations[locale]?[key] ?? translations['uz']![key]!;
  }
}

class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  List<Subject> subjects = [];
  Map<String, List<Subject>> categorizedSubjects = {};
  bool isLoading = true;
  String? errorMessage;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  List<String> getFilters(String locale) {
    return [
      DiagnosticsLocalization.get('all', locale),
      DiagnosticsLocalization.get('started', locale),
      DiagnosticsLocalization.get('notStarted', locale),
      DiagnosticsLocalization.get('finished', locale),
    ];
  }

  Future<void> _fetchSubjects() async {
    var token = sl<LocalSource>().getAccessToken();
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/my-diagnost-subjects/'),
        headers: {
          'Authorization': '$token',
        },
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          subjects = data.map((json) => Subject.fromJson(json)).toList();
          _categorizeSubjects();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'loadError';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'internetError';
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  void _categorizeSubjects() {
    categorizedSubjects.clear();

    List<Subject> filteredList;
    if (selectedFilter == 'all') {
      filteredList = subjects;
    } else if (selectedFilter == 'started') {
      filteredList = subjects
          .where((s) => s.progressPercent > 0 && s.progressPercent < 100)
          .toList();
    } else if (selectedFilter == 'finished') {
      filteredList =
          subjects.where((s) => s.progressPercent >= 100).toList();
    } else {
      filteredList = subjects.where((s) => s.progressPercent == 0).toList();
    }

    for (var subject in filteredList) {
      if (!categorizedSubjects.containsKey(subject.nameUz)) {
        categorizedSubjects[subject.nameUz] = [];
      }
      categorizedSubjects[subject.nameUz]!.add(subject);
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      _categorizeSubjects();
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      errorMessage = null;
    });
    await _fetchSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';
        final filters = getFilters(locale);

        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          navigationBar: CupertinoNavigationBar(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
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
                        color: Color(0xFF007AFF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    Assets.svgChartDiagram,
                    color: context.color.white,
                    width: 28,
                    height: 28,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  DiagnosticsLocalization.get('diagnostics', locale),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size(double.infinity, 8),
              child: SizedBox.shrink(),
            ),
            backgroundColor: CupertinoColors.white,
            automaticBackgroundVisibility: false,
          ),
          child: SafeArea(
            bottom: false,
            child: isLoading && subjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(radius: 16),
                        SizedBox(height: 16),
                        Text(
                          DiagnosticsLocalization.get('loading', locale),
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  )
                : errorMessage != null && subjects.isEmpty
                    ? _buildErrorView(locale)
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          CupertinoSliverRefreshControl(
                            onRefresh: _refreshData,
                          ),
                          SliverToBoxAdapter(
                            child: _buildFilterChips(locale, filters),
                          ),
                          if (categorizedSubjects.isEmpty)
                            SliverFillRemaining(
                              child: _buildEmptyView(locale),
                            )
                          else
                            ...categorizedSubjects.entries.map((entry) {
                              return SliverToBoxAdapter(
                                child: CategorySection(
                                  // categoryTitle: entry.key,
                                  categoryTitle: BaseFunctions.getLanguageText(
                                    languageCode: appState.appLocale,
                                    uz: entry.key,
                                    ru: entry.value.first.nameRu,
                                  ),
                                  books: entry.value,
                                  locale: locale,
                                ),
                              );
                            }),
                          const SliverGap(100),
                        ],
                      ),
          ),
        );
      },
    );
  }

  // Har bir filtrga mos ikonka va aksent rang — holatni bir qarashda
  // ajratish uchun (Hammasi/Boshlangan/Boshlanmagan/Yakunlangan).
  static const List<IconData> _kFilterIcons = [
    CupertinoIcons.square_grid_2x2_fill,
    CupertinoIcons.play_fill,
    CupertinoIcons.time,
    CupertinoIcons.star_fill,
  ];

  static const List<Color> _kFilterColors = [
    Color(0xFF007AFF), // Hammasi — ko'k
    Color(0xFF34C759), // Boshlangan — yashil
    Color(0xFFFF9500), // Boshlanmagan — apelsin
    Color(0xFFAF52DE), // Yakunlangan — binafsha
  ];

  Widget _buildFilterChips(String locale, List<String> filters) {
    const filterKeys = ['all', 'started', 'notStarted', 'finished'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: List.generate(filters.length, (index) {
          final filterKey = filterKeys[index];
          final isSelected = selectedFilter == filterKey;
          final accent = _kFilterColors[index];

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == filters.length - 1 ? 0 : 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _applyFilter(filterKey);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [accent, accent.withOpacity(0.82)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected ? accent : CupertinoColors.systemGrey)
                            .withOpacity(isSelected ? 0.35 : 0.1),
                        blurRadius: isSelected ? 14 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.25)
                              : accent.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _kFilterIcons[index],
                          size: 14,
                          color: isSelected ? Colors.white : accent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        filters[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? CupertinoColors.white
                              : CupertinoColors.label,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorView(String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF3B30).withOpacity(0.2),
                    const Color(0xFFFF3B30).withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 40,
                color: Color(0xFFFF3B30),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              DiagnosticsLocalization.get(errorMessage!, locale),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiagnosticsLocalization.get('tryAgain', locale),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 24),
            CupertinoButton(
              onPressed: _refreshData,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF007AFF),
              child: Text(
                DiagnosticsLocalization.get('reload', locale),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemGrey.withOpacity(0.2),
                    CupertinoColors.systemGrey.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.book_fill,
                size: 50,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              DiagnosticsLocalization.get('noBooksFound', locale),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedFilter == 'all'
                  ? DiagnosticsLocalization.get('noAssignedBooks', locale)
                  : DiagnosticsLocalization.get('noFilteredBooks', locale),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Part 2 - CategorySection va DiagnosticBookCard

class CategorySection extends StatelessWidget {
  final String categoryTitle;
  final List<Subject> books;
  final String locale;

  const CategorySection({
    super.key,
    required this.categoryTitle,
    required this.books,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    // Rasm 4:3 landshaft nisbatida to'liq ko'rinishi uchun karta ham
    // gorizontal (kengroq) — Fanlar sahifasidagi kartalar bilan bir xil.
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.62;
    final cardHeight = cardWidth * 0.75 + 40;

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.book_fill,
                          size: 20,
                          color: const Color(0xFF007AFF),
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
              height: cardHeight + 24,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final grade = books[index].className;
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: DiagnosticBookCard(
                        subject: books[index],
                        gradeLabel: appState.appLocale == 'ru'
                            ? '$grade-класс'
                            : '$grade-sinf',
                        locale: locale,
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          await Navigator.pushNamed(
                            mainRootNavigatorKey.currentContext!,
                            Routes.questions,
                            arguments: QuestionPageArguments(
                              topic: null,
                              isDiagnostic: true,
                              // taskName: books[index].classUz,
                              taskName: BaseFunctions.getLanguageText(
                                languageCode: appState.appLocale,
                                uz: books[index].classUz,
                                ru: books[index].classRu,
                              ),
                              subjectId: books[index].id.toString(),
                            ),
                          ).then((value) {
                            if (value != null) {
                              if (value as bool) {
                                _openChapterSelection(
                                    books[index].id.toString(), context);
                              }
                            }
                          });
                        },
                        refreshOnTap: () async {
                          HapticFeedback.mediumImpact();
                          await Navigator.pushNamed(
                            mainRootNavigatorKey.currentContext!,
                            Routes.questions,
                            arguments: QuestionPageArguments(
                              topic: null,
                              isDiagnostic: true,
                              taskName: BaseFunctions.getLanguageText(
                                languageCode: appState.appLocale,
                                uz: books[index].nameUz,
                                ru: books[index].nameRu,
                              ),
                              subjectId: books[index].id.toString(),
                            ),
                          ).then((value) {
                            if (value != null) {
                              if (value as bool) {
                                _openChapterSelection(
                                    books[index].id.toString(), context);
                              }
                            }
                          });
                        },
                        eyeOnTap: () {
                          _openChapterSelection(
                              books[index].id.toString(), context);
                        },
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

  void _openChapterSelection(String id, BuildContext context) {
    var token = sl<LocalSource>().getAccessToken();
    showChapterBottomSheet(
      context: context,
      authToken: token ?? '',
      onTopicSelected: (int topicId) {},
      id: id,
    );
  }
}

class DiagnosticBookCard extends StatefulWidget {
  final Subject subject;
  final String gradeLabel;
  final String locale;
  final VoidCallback onTap;
  final VoidCallback eyeOnTap;
  final VoidCallback refreshOnTap;

  const DiagnosticBookCard({
    super.key,
    required this.subject,
    required this.gradeLabel,
    required this.locale,
    required this.onTap,
    required this.eyeOnTap,
    required this.refreshOnTap,
  });

  @override
  State<DiagnosticBookCard> createState() => _DiagnosticBookCardState();
}

class _DiagnosticBookCardState extends State<DiagnosticBookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isRefreshPressed = false;
  bool _isEyePressed = false;
  bool _isStartPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getButtonGradient() {
    return [const Color(0xFF007AFF), const Color(0xFF0051D5)];
  }

  List<Color> _getProgressGradient(int progress) {
    if (progress == 0) {
      return [const Color(0xFF8E8E93), const Color(0xFF636366)];
    } else if (progress < 30) {
      return [const Color(0xFFFF6B6B), const Color(0xFFFF3B30)];
    } else if (progress < 60) {
      return [const Color(0xFFFFB444), const Color(0xFFFF9500)];
    } else if (progress < 90) {
      return [const Color(0xFFFFD60A), const Color(0xFFFFCC00)];
    } else {
      return [const Color(0xFF34C759), const Color(0xFF30B350)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final imageUrl = widget.subject.imageUz.isNotEmpty
    //     ? 'https://api.iqmath.uz${widget.subject.imageUz}'
    //     : '';
    final progress = widget.subject.progressPercent.toInt();
    final progressGradient = _getProgressGradient(progress);
    final buttonGradient = _getButtonGradient();

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  // Rasm 4:3 landshaft nisbatida to'liq ko'rinadi —
                  // avvalgi pastki ko'k panel rasmning katta qismini
                  // yopib turar edi, endi sinf belgisi kichik badge
                  // sifatida rasm USTIDA (yuqorida) ko'rsatiladi.
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: (widget.subject.imageUz.isNotEmpty
                                      ? 'https://api.iqmath.uz${widget.subject.imageUz}'
                                      : '')
                                  .startsWith('http')
                              ? Image.network(
                                  widget.subject.imageUz.isNotEmpty
                                      ? 'https://api.iqmath.uz${BaseFunctions.getLanguageText(
                                          languageCode: appState.appLocale,
                                          uz: widget.subject.imageUz,
                                          ru: widget.subject.imageRu,
                                        )}'
                                      : '',
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CupertinoActivityIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildFallbackIcon(
                                        screenHeight, buttonGradient);
                                  },
                                )
                              : _buildFallbackIcon(screenHeight, buttonGradient),
                        ),

                        if (!widget.subject.hasTakenDiagnostic)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _buildNewBadge(),
                          ),

                        // Sinf + fan nomi — Fanlar sahifasidagi bilan bir xil
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
                                  gradient: LinearGradient(colors: buttonGradient),
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
                                  BaseFunctions.getLanguageText(
                                    languageCode: appState.appLocale,
                                    uz: widget.subject.nameUz,
                                    ru: widget.subject.nameRu,
                                  ),
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
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (widget.subject.hasTakenDiagnostic) ...[
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.refreshOnTap,
                    onTapDown: (_) => setState(() => _isRefreshPressed = true),
                    onTapUp: (_) {
                      setState(() => _isRefreshPressed = false);
                      HapticFeedback.lightImpact();
                    },
                    onTapCancel: () =>
                        setState(() => _isRefreshPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: _isRefreshPressed
                            ? CupertinoColors.systemGrey5
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: _isRefreshPressed
                                ? buttonGradient[0].withOpacity(0.2)
                                : CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: _isRefreshPressed ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.refresh_thick,
                        size: 16,
                        color: buttonGradient[0],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.eyeOnTap,
                    onTapDown: (_) => setState(() => _isEyePressed = true),
                    onTapUp: (_) {
                      setState(() => _isEyePressed = false);
                      HapticFeedback.lightImpact();
                    },
                    onTapCancel: () => setState(() => _isEyePressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: _isEyePressed
                            ? CupertinoColors.systemGrey5
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: _isEyePressed
                                ? buttonGradient[0].withOpacity(0.2)
                                : CupertinoColors.systemGrey.withOpacity(0.1),
                            blurRadius: _isEyePressed ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.eye_fill,
                        size: 16,
                        color: buttonGradient[0],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: progressGradient,
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: progressGradient[0].withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$progress%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: progressGradient[0],
                    ),
                  ),
                ],
              ),
            ] else ...[
              GestureDetector(
                onTapDown: (_) {
                  setState(() => _isStartPressed = true);
                  _controller.forward();
                },
                onTapUp: (_) {
                  setState(() => _isStartPressed = false);
                  _controller.reverse();
                  HapticFeedback.mediumImpact();
                  widget.onTap();
                },
                onTapCancel: () {
                  setState(() => _isStartPressed = false);
                  _controller.reverse();
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _isStartPressed
                              ? buttonGradient[0].withOpacity(0.2)
                              : CupertinoColors.systemGrey.withOpacity(0.1),
                          blurRadius: _isStartPressed ? 12 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.play_fill,
                            size: 14,
                            color: buttonGradient[0],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DiagnosticsLocalization.get('start', widget.locale),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: buttonGradient[0],
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNewBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.sparkles,
                size: 12,
                color: CupertinoColors.white,
              ),
              SizedBox(width: 4),
              Text(
                DiagnosticsLocalization.get('new', widget.locale),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(double screenHeight, List<Color> colors) {
    return Center(
      child: Container(
        width: screenHeight * 0.1,
        height: screenHeight * 0.1,
        decoration: BoxDecoration(
          color: colors[0].withOpacity(0.15),
          borderRadius: BorderRadius.circular(screenHeight * 0.05),
        ),
        child: Icon(
          CupertinoIcons.book_fill,
          size: screenHeight * 0.045,
          color: colors[0],
        ),
      ),
    );
  }
}
