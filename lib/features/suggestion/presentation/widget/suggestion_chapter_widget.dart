import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../injector_container.dart';

/// Model class for Chapter data
class Chapter {
  final int id;
  final String nameUz;
  final String nameRu;

  Chapter({
    required this.id,
    required this.nameUz,
    required this.nameRu,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int,
      nameUz: json['name_uz'] as String,
      nameRu: json['name_ru'] as String,
    );
  }
}

/// Model class for Topic data
class Topic {
  final int id;
  final String nameUz;
  final String nameRu;

  Topic({
    required this.id,
    required this.nameUz,
    required this.nameRu,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as int,
      nameUz: json['name_uz'] as String,
      nameRu: json['name_ru'] as String,
    );
  }
}

/// Service class to handle API calls
class ChapterService {
  static Future<List<Chapter>> fetchChapters(String token, String id) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/my-diagnost-subject/$id/chapters/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Chapter.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chapters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching chapters: $e');
    }
  }

  static Future<List<Topic>> fetchTopics(String token, int chapterId) async {
    try {
      final url =
          'https://api.iqmath.uz/api/v1/func_student/my-diagnost-chapter/$chapterId/topics/';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Topic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load topics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching topics: $e');
    }
  }
}

class ChapterBottomSheetLocalization {
  final String locale;

  ChapterBottomSheetLocalization(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'selectChapter': 'Bo\'limlarni tanlang',
      'selectTopic': 'Mavzularni tanlang',
      'close': 'Yopish',
      'back': 'Orqaga',
      'errorOccurred': 'Xatolik yuz berdi',
      'cannotLoadData': 'Ma\'lumotlarni yuklab bo\'lmadi',
      'cannotLoadTopics': 'Mavzularni yuklab bo\'lmadi',
      'chaptersNotFound': 'Bo\'limlar topilmadi',
      'topicsNotFound': 'Mavzular topilmadi',
    },
    'ru': {
      'selectChapter': 'Выберите главу',
      'selectTopic': 'Выберите тему',
      'close': 'Закрыть',
      'back': 'Назад',
      'errorOccurred': 'Произошла ошибка',
      'cannotLoadData': 'Не удалось загрузить данные',
      'cannotLoadTopics': 'Не удалось загрузить темы',
      'chaptersNotFound': 'Главы не найдены',
      'topicsNotFound': 'Темы не найдены',
    },
  };

  String translate(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues['uz']![key]!;
  }

  // Getters
  String get selectChapter => translate('selectChapter');

  String get selectTopic => translate('selectTopic');

  String get close => translate('close');

  String get back => translate('back');

  String get errorOccurred => translate('errorOccurred');

  String get cannotLoadData => translate('cannotLoadData');

  String get cannotLoadTopics => translate('cannotLoadTopics');

  String get chaptersNotFound => translate('chaptersNotFound');

  String get topicsNotFound => translate('topicsNotFound');
}

// ==================== HELPER FUNCTION ====================
void showChapterBottomSheet({
  required BuildContext context,
  required String authToken,
  required Function(int topicId) onTopicSelected,
  required String id,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => ChapterBottomSheet(
      authToken: authToken,
      onTopicSelected: onTopicSelected,
      id: id,
    ),
  );
}

// ==================== CHAPTER BOTTOM SHEET ====================
class ChapterBottomSheet extends StatefulWidget {
  final String authToken;
  final Function(int topicId) onTopicSelected;
  final String id;

  const ChapterBottomSheet({
    super.key,
    required this.authToken,
    required this.onTopicSelected,
    required this.id,
  });

  @override
  State<ChapterBottomSheet> createState() => _ChapterBottomSheetState();
}

class _ChapterBottomSheetState extends State<ChapterBottomSheet> {
  late Future<List<Chapter>> _chaptersFuture;
  final ScrollController _scrollController = ScrollController();
  bool _isAtTop = true;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = ChapterService.fetchChapters(widget.authToken, widget.id);

    // Listen to scroll position
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Check if we're at the top of the list
    if (_scrollController.hasClients) {
      final isAtTop = _scrollController.position.pixels <= 0;
      if (_isAtTop != isAtTop) {
        setState(() {
          _isAtTop = isAtTop;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  ChapterBottomSheetLocalization _getLocalization() {
    final appState = context.read<AppBloc>().state;
    return ChapterBottomSheetLocalization(appState.appLocale ?? 'uz');
  }

  void _onChapterSelected(Chapter chapter) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => TopicBottomSheet(
        authToken: widget.authToken,
        chapter: chapter,
        onTopicSelected: widget.onTopicSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final l10n = ChapterBottomSheetLocalization(state.appLocale ?? 'uz');

        return Material(
          type: MaterialType.transparency,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color:
              CupertinoColors.systemGroupedBackground.resolveFrom(context),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 5) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color:
                          CupertinoColors.systemGrey4.resolveFrom(context),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                ),

                // Header with Close button
                _buildHeader(context, l10n),

                // Chapter list with NotificationListener
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        // Agar list tepada bo'lsa va pastga scroll qilinayotgan bo'lsa
                        if (_isAtTop &&
                            notification.metrics.pixels < -60 &&
                            !_isClosing) {
                          _isClosing = true;
                          // Animation tugagandan keyin yopish
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          });
                          return true;
                        }
                      }
                      return false;
                    },
                    child: FutureBuilder<List<Chapter>>(
                      future: _chaptersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildLoadingState();
                        } else if (snapshot.hasError) {
                          return _buildErrorState(l10n);
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyState(l10n);
                        }

                        return _buildChapterList(
                            snapshot.data!, state.appLocale ?? 'uz');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, ChapterBottomSheetLocalization l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.selectChapter,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            borderRadius: BorderRadius.circular(20),
            color: CupertinoColors.systemGrey5.resolveFrom(context),
            minSize: 0,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.close,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CupertinoActivityIndicator(radius: 16),
    );
  }

  Widget _buildErrorState(ChapterBottomSheetLocalization l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 48,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cannotLoadData,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ChapterBottomSheetLocalization l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.book_fill,
                size: 48,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.chaptersNotFound,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterList(List<Chapter> chapters, String locale) {
    return CupertinoScrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChapterCard(chapter, locale),
          );
        },
      ),
    );
  }

  Widget _buildChapterCard(Chapter chapter, String locale) {
    final chapterName = locale == 'ru' ? chapter.nameRu : chapter.nameUz;

    return GestureDetector(
      onTap: () => _onChapterSelected(chapter),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onChapterSelected(chapter),
              splashColor: CupertinoColors.systemBlue.withOpacity(0.1),
              highlightColor: CupertinoColors.systemGrey6.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CupertinoColors.systemBlue.resolveFrom(context),
                            CupertinoColors.systemBlue
                                .resolveFrom(context)
                                .withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.book_fill,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        chapterName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.label.resolveFrom(context),
                          height: 1.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6.resolveFrom(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.chevron_right,
                        size: 18,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== TOPIC BOTTOM SHEET ====================
class TopicBottomSheet extends StatefulWidget {
  final String authToken;
  final Chapter chapter;
  final Function(int topicId) onTopicSelected;

  const TopicBottomSheet({
    super.key,
    required this.authToken,
    required this.chapter,
    required this.onTopicSelected,
  });

  @override
  State<TopicBottomSheet> createState() => _TopicBottomSheetState();
}

class _TopicBottomSheetState extends State<TopicBottomSheet> {
  late Future<List<Topic>> _topicsFuture;
  final ScrollController _scrollController = ScrollController();
  bool _isAtTop = true;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _topicsFuture =
        ChapterService.fetchTopics(widget.authToken, widget.chapter.id);

    // Listen to scroll position
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isAtTop = _scrollController.position.pixels <= 0;
      if (_isAtTop != isAtTop) {
        setState(() {
          _isAtTop = isAtTop;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  ChapterBottomSheetLocalization _getLocalization() {
    final appState = context.read<AppBloc>().state;
    return ChapterBottomSheetLocalization(appState.appLocale ?? 'uz');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final l10n = ChapterBottomSheetLocalization(state.appLocale ?? 'uz');
        final chapterName = state.appLocale == 'ru'
            ? widget.chapter.nameRu
            : widget.chapter.nameUz;

        return Material(
          type: MaterialType.transparency,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color:
              CupertinoColors.systemGroupedBackground.resolveFrom(context),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 5) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color:
                          CupertinoColors.systemGrey4.resolveFrom(context),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                ),

                // Header with Back and Close buttons
                _buildHeader(context, l10n, chapterName),

                // Topic list with NotificationListener
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        // Agar list tepada bo'lsa va pastga scroll qilinayotgan bo'lsa
                        if (_isAtTop &&
                            notification.metrics.pixels < -60 &&
                            !_isClosing) {
                          _isClosing = true;
                          // Animation tugagandan keyin yopish
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          });
                          return true;
                        }
                      }
                      return false;
                    },
                    child: FutureBuilder<List<Topic>>(
                      future: _topicsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildLoadingState();
                        } else if (snapshot.hasError) {
                          return _buildErrorState(l10n);
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyState(l10n);
                        }

                        return _buildTopicList(
                            snapshot.data!, state.appLocale ?? 'uz');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context,
      ChapterBottomSheetLocalization l10n,
      String chapterName,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  // Faqat topic sheet'ni yopish (chapters ochiq qoladi)
                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.chevron_left,
                      size: 20,
                      color: CupertinoColors.systemBlue.resolveFrom(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.back,
                      style: TextStyle(
                        fontSize: 17,
                        color: CupertinoColors.systemBlue.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                borderRadius: BorderRadius.circular(20),
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                minSize: 0,
                onPressed: () {
                  // Ikkala sheet'ni ham yopish
                  Navigator.of(context).pop(); // Close topics
                  Navigator.of(context).pop(); // Close chapters
                },
                child: Text(
                  l10n.close,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.selectTopic,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            chapterName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CupertinoActivityIndicator(radius: 16),
    );
  }

  Widget _buildErrorState(ChapterBottomSheetLocalization l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 48,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.errorOccurred,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cannotLoadTopics,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ChapterBottomSheetLocalization l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.doc_text_fill,
                size: 48,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.topicsNotFound,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicList(List<Topic> topics, String locale) {
    return CupertinoScrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTopicCard(topic, locale),
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(Topic topic, String locale) {
    final topicName = locale == 'ru' ? topic.nameRu : topic.nameUz;

    return GestureDetector(
      onTap: () {
        widget.onTopicSelected(topic.id);
        Navigator.of(context).pop(); // Close topics
        Navigator.of(context).pop(); // Close chapters
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                widget.onTopicSelected(topic.id);
                // Navigator.of(context).pop(); // Close topics
                // Navigator.of(context).pop(); // Close chapters
              },
              splashColor: CupertinoColors.systemGreen.withOpacity(0.1),
              highlightColor: CupertinoColors.systemGrey6.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CupertinoColors.systemGreen.resolveFrom(context),
                            CupertinoColors.systemGreen
                                .resolveFrom(context)
                                .withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.doc_text_fill,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        topicName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.label.resolveFrom(context),
                          height: 1.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6.resolveFrom(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.chevron_right,
                        size: 18,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
