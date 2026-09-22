import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/features/home/presentation/page_parts/home_localizations.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/book_card_widget.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/topic_card.dart';
import 'package:my_flutter_template/injector_container.dart' show sl, alice;
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:my_flutter_template/router/name_routes.dart';

import '../../../../../subject/data/models/chapter_model.dart';

class RecentActivityWidget extends StatefulWidget {
  final String? authToken;
  final VoidCallback? onSeeAll;
  final ValueNotifier<int>? refreshNotifier;

  const RecentActivityWidget({
    super.key,
    this.authToken,
    this.onSeeAll,
    this.refreshNotifier,
  });

  @override
  State<RecentActivityWidget> createState() => _RecentActivityWidgetState();
}

class _RecentActivityWidgetState extends State<RecentActivityWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentActivities();
    widget.refreshNotifier?.addListener(_onRefresh);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    _fetchRecentActivities();
  }

  Future<void> _fetchRecentActivities() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final response = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/student/last-topic-result/app'),
        headers: {
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
          'Content-Type': 'application/json',
        },
      );

      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final dynamic decodedData =
        json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          // Array yoki Map ekanligini tekshirish
          if (decodedData is List) {
            _activities = decodedData
                .map((item) => {
              'class_name_uz': item['class_name_uz'] ?? '',
              'class_name_ru': item['class_name_ru'] ?? '',
              'subject_name_uz': item['subject_name_uz'] ?? '',
              'subject_name_ru': item['subject_name_ru'] ?? '',
              'chapter_name_uz': item['chapter_name_uz'] ?? '',
              'chapter_name_ru': item['chapter_name_ru'] ?? '',
              'topic_name_uz': item['topic_name_uz'] ?? '',
              'topic_name_ru': item['topic_name_ru'] ?? '',
              'topic_id': item['topic_id'] ?? 0,
              'score': item['score'] ?? 0,
              'completed_at': item['completed_at'] ?? '',
              'chapter_id': item['chapter_id'] ?? 0,
            })
                .toList()
                .cast<Map<String, dynamic>>();
          } else if (decodedData is Map) {
            _activities = [
              {
                'class_name_uz': decodedData['class_name_uz'] ?? '',
                'class_name_ru': decodedData['class_name_ru'] ?? '',
                'subject_name_uz': decodedData['subject_name_uz'] ?? '',
                'subject_name_ru': decodedData['subject_name_ru'] ?? '',
                'chapter_name_uz': decodedData['chapter_name_uz'] ?? '',
                'chapter_name_ru': decodedData['chapter_name_ru'] ?? '',
                'topic_name_uz': decodedData['topic_name_uz'] ?? '',
                'topic_name_ru': decodedData['topic_name_ru'] ?? '',
                'topic_id': decodedData['topic_id'] ?? 0,
                'score': decodedData['score'] ?? 0,
                'completed_at': decodedData['completed_at'] ?? '',
                'chapter_id': decodedData['chapter_id'] ?? 0,
              }
            ];
          }
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

  String _getActivityTitle(Map<String, dynamic> activity, String? locale) {
    final topicUz = activity['topic_name_uz'] as String? ?? '';
    final topicRu = activity['topic_name_ru'] as String? ?? '';

    if (locale == 'ru') {
      return topicRu.isNotEmpty
          ? topicRu
          : RecentActivityTranslations.t('newTopic', locale);
    } else {
      return topicUz.isNotEmpty
          ? topicUz
          : RecentActivityTranslations.t('newTopic', locale);
    }
  }

  String _getActivityTime(Map<String, dynamic> activity, String? locale) {
    if (locale == 'ru') {
      final classNameRu = activity['class_name_ru'] as String? ?? '';
      final subjectRu = activity['subject_name_ru'] as String? ?? '';
      final chapterRu = activity['chapter_name_ru'] as String? ?? '';

      // Bo'sh bo'lmagan qismlarni birlashtirish
      final parts = [classNameRu, subjectRu, chapterRu]
          .where((part) => part.isNotEmpty)
          .toList();

      return parts.isNotEmpty
          ? parts.join(' / ')
          : RecentActivityTranslations.t('noSubject', locale);
    } else {
      final classNameUz = activity['class_name_uz'] as String? ?? '';
      final subjectUz = activity['subject_name_uz'] as String? ?? '';
      final chapterUz = activity['chapter_name_uz'] as String? ?? '';

      // Bo'sh bo'lmagan qismlarni birlashtirish
      final parts = [classNameUz, subjectUz, chapterUz]
          .where((part) => part.isNotEmpty)
          .toList();

      return parts.isNotEmpty
          ? parts.join(' / ')
          : RecentActivityTranslations.t('noSubject', locale);
    }
  }

  String _getActivityScore(Map<String, dynamic> activity, String? locale) {
    final score = activity['score'];
    if (score != null && score != 0) {
      // score double bo'lsa, int ga aylantiramiz
      final scoreValue = score is double ? score.round() : score;
      return '+$scoreValue ${RecentActivityTranslations.t('points', locale)}';
    }
    return '0 ${RecentActivityTranslations.t('points', locale)}';
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

        // Agar ma'lumot bo'sh bo'lsa, hech narsa ko'rsatmaymiz
        if (_activities.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  RecentActivityTranslations.t('recentActivity', locale),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
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
              child: Column(
                children: _activities
                    .map((activity) => InkWell(
                  onTap: () {
                    ChapterTopicsSheet.show(
                      mainRootNavigatorKey.currentContext!,
                      ChapterModel(
                        id: activity['chapter_id'] as int,
                        nameRu: activity['subject_name_ru'] ?? '',
                        nameUz: activity['subject_name_uz'] ?? '',
                        progress: 101,
                        subject: 0,
                      ),
                      BaseFunctions.getLanguageText(
                        languageCode: locale,
                        uz: activity['subject_name_uz'] ?? '',
                        ru: activity['subject_name_ru'] ?? '',
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4FC3F7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getActivityTitle(activity, locale),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2D3748),
                                  height: 1.41,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getActivityTime(activity, locale),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_getActivityScore(activity, locale)
                            .isNotEmpty)
                          Text(
                            _getActivityScore(activity, locale),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                      ],
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}