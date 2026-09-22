import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/features/home/presentation/page_parts/home_localizations.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/book_card_widget.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:my_flutter_template/router/name_routes.dart';
import '../../../../../../injector_container.dart';

class LearningPathWidget extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const LearningPathWidget({
    super.key,
    this.refreshNotifier,
  });

  @override
  State<LearningPathWidget> createState() => _LearningPathWidgetState();
}

class _LearningPathWidgetState extends State<LearningPathWidget> {
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;
  bool _showAll = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStudentStatistics();
    widget.refreshNotifier?.addListener(_onRefresh);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    _fetchStudentStatistics();
  }

  Future<void> _fetchStudentStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.iqmath.uz/api/v1/func_student/student/subjectprogress/app',
        ),
        headers: {
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
          'Content-Type': 'application/json',
        },
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        if (data.isEmpty) {
          setState(() {
            _subjects = [];
            _isLoading = false;
          });
          return;
        }

        final appState = context.read<AppBloc>().state;
        final currentLocale = appState.appLocale ?? 'uz';

        final List<Map<String, dynamic>> subjectsList = [];

        for (var item in data) {
          final id = item['id'] as int;
          final nameUz = item['name_uz'] as String;
          final nameRu = item['name_ru'] as String;
          final subjectCount = item['subject_count'] as int;
          final totalChapters = item['total_chapter_count'] as int;
          final totalTopics = item['total_topic_count'] as int;
          final totalPresent = (item['total_present'] as num).toDouble();

          final int progress = totalPresent.round();

          final int masteredTopics = totalTopics > 0
              ? ((totalPresent / 100) * totalTopics).round()
              : 0;

          subjectsList.add({
            'id': id,
            'name_uz': nameUz,
            'name_ru': nameRu,
            'chapters': totalChapters,
            'topics': totalTopics,
            'mastered_topics': masteredTopics,
            'book_count': subjectCount,
            'progress': progress,
            'color': _getColorForSubject(currentLocale == 'ru' ? nameRu : nameUz),
            'icon': _getIconForSubject(currentLocale == 'ru' ? nameRu : nameUz),
          });
        }

        subjectsList.sort((a, b) {
          final nameA = currentLocale == 'ru'
              ? (a['name_ru'] as String)
              : (a['name_uz'] as String);
          final nameB = currentLocale == 'ru'
              ? (b['name_ru'] as String)
              : (b['name_uz'] as String);
          return nameA.compareTo(nameB);
        });

        setState(() {
          _subjects = subjectsList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'error';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching student statistics: $e');
      setState(() {
        _error = 'internet';
        _isLoading = false;
      });
    }
  }

  int _getColorForSubject(String subjectName) {
    final lowerName = subjectName.toLowerCase();

    if (lowerName.contains('algebra') || lowerName.contains('алгебра')) {
      return 0xFF42A5F5;
    } else if (lowerName.contains('geometr') || lowerName.contains('геометр')) {
      return 0xFF66BB6A;
    } else if (lowerName.contains('matemat') || lowerName.contains('математ')) {
      return 0xFFFFB74D;
    } else if (lowerName.contains('fizika') || lowerName.contains('физика')) {
      return 0xFFEF5350;
    }
    return 0xFF9C27B0;
  }

  String _getIconForSubject(String subjectName) {
    final lowerName = subjectName.toLowerCase();

    if (lowerName.contains('algebra') || lowerName.contains('алгебра')) {
      return 'function';
    } else if (lowerName.contains('geometr') || lowerName.contains('геометр')) {
      return 'triangle';
    } else if (lowerName.contains('matemat') || lowerName.contains('математ')) {
      return 'number';
    } else if (lowerName.contains('fizika') || lowerName.contains('физика')) {
      return 'lightbulb';
    }
    return 'book';
  }

  void _showSubjectDetailsBottomSheet(Map<String, dynamic> subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubjectDetailsBottomSheet(subject: subject),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LearningPathTranslations.t('learningPath', locale),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        _error == 'error'
                            ? LearningPathTranslations.t('errorLoadingData', locale)
                            : LearningPathTranslations.t('internetError', locale),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchStudentStatistics,
                        child: Text(LearningPathTranslations.t('retryButton', locale)),
                      ),
                    ],
                  ),
                ),
              )
            else if (_subjects.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      LearningPathTranslations.t('noDataYet', locale),
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else ...[
                  ...(_showAll ? _subjects : _subjects.take(3)).map(
                        (subject) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubjectCard(
                        subject: subject,
                        locale: locale,
                        onTap: () => _showSubjectDetailsBottomSheet(subject),
                      ),
                    ),
                  ),
                  if (_subjects.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAll = !_showAll;
                            });
                          },
                          icon: Icon(
                            _showAll
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                            size: 16,
                          ),
                          label: Text(
                            _showAll
                                ? LearningPathTranslations.t('showLess', locale)
                                : '${LearningPathTranslations.t('showMore', locale)} (${_subjects.length - 3}+)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF42A5F5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
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
}

class _SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final String? locale;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    this.locale,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'number':
        return CupertinoIcons.number;
      case 'triangle':
        return CupertinoIcons.triangle;
      case 'function':
        return CupertinoIcons.function;
      case 'book':
        return CupertinoIcons.book;
      case 'lightbulb':
        return CupertinoIcons.lightbulb;
      default:
        return CupertinoIcons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color subjectColor = Color(subject['color'] as int);
    final IconData subjectIcon = _getIconData(subject['icon'] as String);
    final int topics = subject['topics'] as int;
    final int masteredTopics = subject['mastered_topics'] as int;
    final int chapters = subject['chapters'] as int;
    final int bookCount = subject['book_count'] as int;

    final chapterText = LearningPathTranslations.t('chapter', locale);
    final topicText = LearningPathTranslations.t('topic', locale);
    final bookText = locale == 'ru' ? 'книг' : 'ta kitob';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                subjectIcon,
                color: subjectColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale == 'ru'
                        ? (subject['name_ru'] as String)
                        : (subject['name_uz'] as String),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$bookCount $bookText • $chapters $chapterText • $masteredTopics/$topics $topicText',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: (subject['progress'] as int) / 100,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: subjectColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${subject['progress']}%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: subjectColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom Sheet Widget
class SubjectDetailsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> subject;

  const SubjectDetailsBottomSheet({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectDetailsBottomSheet> createState() =>
      _SubjectDetailsBottomSheetState();
}

class _SubjectDetailsBottomSheetState extends State<SubjectDetailsBottomSheet> {
  bool _isLoading = true;
  String? _error;
  SubjectCategoryDetailModel? _details;

  @override
  void initState() {
    super.initState();
    _fetchSubjectDetails();
  }

  Future<void> _fetchSubjectDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://api.iqmath.uz/api/v1/func_student/student/subject-category-detail/app',
        ),
        headers: {
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'category_id': widget.subject['id'],
        }),
      );

      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _details = SubjectCategoryDetailModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'error';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching subject details: $e');
      setState(() {
        _error = 'internet';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;
        final Color subjectColor = Color(widget.subject['color'] as int);

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(widget.subject['icon'] as String),
                        color: subjectColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale == 'ru'
                                ? (widget.subject['name_ru'] as String)
                                : (widget.subject['name_uz'] as String),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.subject['book_count']} ${locale == 'ru' ? 'книг' : 'ta kitob'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(CupertinoIcons.xmark),
                      color: const Color(0xFF718096),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error == 'error'
                            ? LearningPathTranslations.t(
                            'errorLoadingData', locale)
                            : LearningPathTranslations.t(
                            'internetError', locale),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchSubjectDetails,
                        child: Text(
                          LearningPathTranslations.t(
                              'retryButton', locale),
                        ),
                      ),
                    ],
                  ),
                )
                    : _buildSubjectsList(locale, subjectColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectsList(String? locale, Color subjectColor) {
    if (_details == null || _details!.subjects.isEmpty) {
      return Center(
        child: Text(
          LearningPathTranslations.t('noDataYet', locale),
          style: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _details!.subjects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final subject = _details!.subjects[index];
        return _SubjectDetailCard(
          subject: subject,
          locale: locale,
          color: subjectColor,
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'number':
        return CupertinoIcons.number;
      case 'triangle':
        return CupertinoIcons.triangle;
      case 'function':
        return CupertinoIcons.function;
      case 'book':
        return CupertinoIcons.book;
      case 'lightbulb':
        return CupertinoIcons.lightbulb;
      default:
        return CupertinoIcons.book;
    }
  }
}

class _SubjectDetailCard extends StatelessWidget {
  final SubjectDetailModel subject;
  final String? locale;
  final Color color;

  const _SubjectDetailCard({
    required this.subject,
    this.locale,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chapterText = LearningPathTranslations.t('chapter', locale);
    final topicText = LearningPathTranslations.t('topic', locale);
    final questionText = locale == 'ru' ? 'вопросов' : 'ta savol';

    return GestureDetector(
      onTap: () {
        print('Tapped on class: ${subject.className}');
        Navigator.pushNamed(
          mainRootNavigatorKey.currentContext!,
          Routes.subjectDetail,
          arguments: SubjectDetailArguments(
            id: subject.id.toString(),
            subjectName: BaseFunctions.getLanguageText(
              languageCode: locale,
              uz: '${subject.className}-sinf ${subject.nameUz}',
              ru: '${subject.className} класс ${subject.nameRu}',
            ),
          ),
        ).then((value) {
          if (value.toString() == 'Telegram') {
            Navigator.pushNamed(
              mainRootNavigatorKey.currentContext!,
              Routes.telegramBot,
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  subject.className,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale == 'ru'
                        ? '${subject.nameRu} - ${subject.className} класс'
                        : '${subject.nameUz} - ${subject.className}-sinf',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _InfoChip(
                        icon: CupertinoIcons.book,
                        text: '${subject.chaptersCount} $chapterText',
                        color: color,
                      ),
                      _InfoChip(
                        icon: CupertinoIcons.square_list,
                        text: '${subject.topicsCount} $topicText',
                        color: color,
                      ),
                      _InfoChip(
                        icon: CupertinoIcons.question_circle,
                        text: '${subject.questionsCount} $questionText',
                        color: color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectCategoryDetailModel {
  final int id;
  final String nameUz;
  final String nameRu;
  final int subjectsCount;
  final List<SubjectDetailModel> subjects;

  SubjectCategoryDetailModel({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.subjectsCount,
    required this.subjects,
  });

  factory SubjectCategoryDetailModel.fromJson(Map<String, dynamic> json) {
    return SubjectCategoryDetailModel(
      id: json['id'] as int? ?? 0,
      nameUz: json['name_uz'] as String? ?? '',
      nameRu: json['name_ru'] as String? ?? '',
      subjectsCount: json['subjects_count'] as int? ?? 0,
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((item) => SubjectDetailModel.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_uz': nameUz,
      'name_ru': nameRu,
      'subjects_count': subjectsCount,
      'subjects': subjects.map((s) => s.toJson()).toList(),
    };
  }
}

class SubjectDetailModel {
  final int id;
  final String nameUz;
  final String nameRu;
  final String className;
  final int chaptersCount;
  final int topicsCount;
  final int questionsCount;

  SubjectDetailModel({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.className,
    required this.chaptersCount,
    required this.topicsCount,
    required this.questionsCount,
  });

  factory SubjectDetailModel.fromJson(Map<String, dynamic> json) {
    return SubjectDetailModel(
      id: json['id'] as int? ?? 0,
      nameUz: json['name_uz'] as String? ?? '',
      nameRu: json['name_ru'] as String? ?? '',
      className: json['class_name'] as String? ?? '',
      chaptersCount: json['chapters_count'] as int? ?? 0,
      topicsCount: json['topics_count'] as int? ?? 0,
      questionsCount: json['questions_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_uz': nameUz,
      'name_ru': nameRu,
      'class_name': className,
      'chapters_count': chaptersCount,
      'topics_count': topicsCount,
      'questions_count': questionsCount,
    };
  }
}