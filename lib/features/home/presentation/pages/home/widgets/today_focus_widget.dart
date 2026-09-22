import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/parent_assimilation_page.dart';
import 'package:my_flutter_template/features/subject/presentation/localization/subject_localization.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/topic_card.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/youtube_link_widget.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:my_flutter_template/router/name_routes.dart';

import '../../../../../subject/data/models/topic_model.dart';
import '../../../page_parts/home_localizations.dart';

class TodaysFocusWidget extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const TodaysFocusWidget({
    super.key,
    this.refreshNotifier,
  });

  @override
  State<TodaysFocusWidget> createState() => _TodaysFocusWidgetState();
}

class _TodaysFocusWidgetState extends State<TodaysFocusWidget> {
  bool _isLoading = true;
  bool _hasError = false;

  // API dan kelgan ma'lumotlar
  int? _topicId;
  String _subjectNameUz = '';
  String _subjectNameRu = '';
  String _chapterNameUz = '';
  String _chapterNameRu = '';
  String _topicNameUz = '';
  String _topicNameRu = '';
  double _score = 0.0;
  String _reminder = '';

  @override
  void initState() {
    super.initState();
    _fetchNextTopic();

    // RefreshNotifier listener qo'shish
    widget.refreshNotifier?.addListener(_onRefresh);
  }

  @override
  void dispose() {
    // Listener olib tashlash
    widget.refreshNotifier?.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    // Refresh chaqirilganda ma'lumotlarni qayta yuklash
    _fetchNextTopic();
  }

  Future<void> _fetchNextTopic() async {
    final token = sl<LocalSource>().getAccessToken();
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final response = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/student/next-topic/app'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );

      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _topicId = data['topic_id'];
          _subjectNameUz = data['subject_name_uz'] ?? '';
          _subjectNameRu = data['subject_name_ru'] ?? '';
          _chapterNameUz = data['chapter_name_uz'] ?? '';
          _chapterNameRu = data['chapter_name_ru'] ?? '';
          _topicNameUz = data['topic_name_uz'] ?? '';
          _topicNameRu = data['topic_name_ru'] ?? '';
          _score = (data['score'] ?? 0.0).toDouble();
          _reminder = data['reminder'] ?? '';

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String _getDescription(String? locale) {
    if (_reminder.isNotEmpty) {
      return _reminder;
    } else if (_score > 0) {
      return '${TodaysFocusTranslations.t('score', locale)}: ${_score.toStringAsFixed(1)}';
    } else {
      return TodaysFocusTranslations.t('startAndLearn', locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;

        // Agar loading yoki error bo'lsa, hech narsa ko'rsatmaymiz
        if (_isLoading || _hasError) {
          return const SizedBox.shrink();
        }

        // Tilga qarab to'g'ri nomlarni tanlaymiz
        final subjectName = locale == 'ru' ? _subjectNameRu : _subjectNameUz;
        final topicName = locale == 'ru' ? _topicNameRu : _topicNameUz;
        final chapterName = locale == 'ru' ? _chapterNameRu : _chapterNameUz;

        // Agar ma'lumot bo'sh bo'lsa, hech narsa ko'rsatmaymiz
        if (subjectName.isEmpty || topicName.isEmpty) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            if (_topicId != null) {
              print(
                  "Topic ID: $_topicId - $subjectName - $topicName bo'limiga o'tish");
              _showTopicDetails(
                TopicModel(
                  id: _topicId!,
                  nameUz: _topicNameUz,
                  nameRu: _topicNameRu,
                  chapter: 0,
                  videoUrlUz: '',
                  videoUrlRu: '',
                  contentUz: '',
                  contentRu: '',
                  isLocked: false,
                  isOpen: true,
                  score: _score,
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎯 ${TodaysFocusTranslations.t('todaysGoal', locale)}: $subjectName',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        topicName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDescription(locale),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTopicDetails(TopicModel topic) {
    var locale = BlocProvider.of<AppBloc>(context).state.appLocale;
    final topicName = locale == 'ru' ? topic?.nameRu : topic?.nameUz;
    final videoUrl = locale == 'ru' ? topic?.videoUrlRu : topic?.videoUrlUz;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          topicName ?? '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        message: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Text(
                '${ChapterTopicsTranslations.t('score', locale)}: ${topic.score}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pushNamed(
                mainRootNavigatorKey.currentContext!,
                Routes.questions,
                arguments: QuestionPageArguments(
                  topic: topic,
                  isDiagnostic: false,
                  taskName: topicName,
                ),
              );
            },
            isDefaultAction: true,
            child: Text(
              topic.progress > 0
                  ? ChapterTopicsTranslations.t('continue', locale)
                  : ChapterTopicsTranslations.t('examples', locale),
            ),
          ),
          if (videoUrl?.isNotEmpty ?? false)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => YoutubeVideoDialog(
                      youtubeUrl: videoUrl ?? '',
                    ),
                  ),
                );
              },
              child: Text(ChapterTopicsTranslations.t('watchVideo', locale)),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(ChapterTopicsTranslations.t('close', locale)),
        ),
      ),
    );
  }
}