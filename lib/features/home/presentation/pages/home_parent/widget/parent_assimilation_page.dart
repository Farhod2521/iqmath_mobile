import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/parent_information_screen.dart';
import 'dart:convert';

import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/parent_topic_sheet.dart';
import 'package:my_flutter_template/injector_container.dart';

class AssimilationLocalization {
  static final Map<String, Map<String, String>> _localizedValues = {
    'assimilation': {
      'uz': 'O\'zlashtirish',
      'ru': 'Усвоение',
    },
    'errorOccurred': {
      'uz': 'Xatolik yuz berdi',
      'ru': 'Произошла ошибка',
    },
    'retry': {
      'uz': 'Qayta urinish',
      'ru': 'Попробовать снова',
    },
    'noData': {
      'uz': 'Ma\'lumot topilmadi',
      'ru': 'Данные не найдены',
    },
    'noTopics': {
      'uz': 'Bu bo\'limda mavzular mavjud emas',
      'ru': 'В этом разделе нет тем',
    },
    'topics': {
      'uz': 'ta mavzu',
      'ru': 'тем',
    },
  };

  static String get(String key, String locale) {
    return _localizedValues[key]?[locale] ?? _localizedValues[key]?['uz'] ?? key;
  }
}

// Main Page
class ParentAssimilationPage extends StatefulWidget {
  final ParentAssimilationScreenArgs args;

  const ParentAssimilationPage({
    super.key,
    required this.args,
  });

  @override
  State<ParentAssimilationPage> createState() => _ParentAssimilationPageState();
}

class _ParentAssimilationPageState extends State<ParentAssimilationPage> {
  final AssimilationApiService _apiService = AssimilationApiService();
  List<ChapterModel> chapters = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedChapters = await _apiService.fetchChapters(widget.args.studentId, widget.args.subjectId);

      setState(() {
        chapters = loadedChapters;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(AssimilationLocalization.get('assimilation', locale)),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SafeArea(
            child: _buildBody(locale),
          ),
        );
      },
    );
  }

  Widget _buildBody(String locale) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              AssimilationLocalization.get('errorOccurred', locale),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadChapters,
              child: Text(AssimilationLocalization.get('retry', locale)),
            ),
          ],
        ),
      );
    }

    if (chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              AssimilationLocalization.get('noData', locale),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ChapterCard(
            chapter: chapters[index],
            chapterNumber: index + 1,
            locale: locale,
          ),
        );
      },
    );
  }
}

// Chapter Card Widget
class ChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final int chapterNumber;
  final String locale;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.chapterNumber,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (chapter.topics.isNotEmpty) {
          TopicsBottomSheet.show(context, chapter);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AssimilationLocalization.get('noTopics', locale)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            // Number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$chapterNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale == 'ru' ? chapter.chapterNameRu : chapter.chapterNameUz,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (chapter.topics.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      locale == 'ru'
                          ? '${chapter.topics.length} ${AssimilationLocalization.get('topics', locale)}'
                          : '${chapter.topics.length} ${AssimilationLocalization.get('topics', locale)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// Models
class ChapterModel {
  final int chapterId;
  final String chapterNameUz;
  final String chapterNameRu;
  final List<TopicParentModel> topics;

  ChapterModel({
    required this.chapterId,
    required this.chapterNameUz,
    required this.chapterNameRu,
    required this.topics,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      chapterId: json['chapter_id'],
      chapterNameUz: json['chapter_name_uz'],
      chapterNameRu: json['chapter_name_ru'],
      topics: (json['topics'] as List)
          .map((topic) => TopicParentModel.fromJson(topic))
          .toList(),
    );
  }
}

class TopicParentModel {
  final int topicId;
  final String topicNameUz;
  final String topicNameRu;
  final double scorePercent;

  TopicParentModel({
    required this.topicId,
    required this.topicNameUz,
    required this.topicNameRu,
    required this.scorePercent,
  });

  factory TopicParentModel.fromJson(Map<String, dynamic> json) {
    return TopicParentModel(
      topicId: json['topic_id'],
      topicNameUz: json['topic_name_uz'],
      topicNameRu: json['topic_name_ru'],
      scorePercent: (json['score_percent'] ?? 0.0).toDouble(),
    );
  }
}

// API Service
class AssimilationApiService {
  static const String baseUrl = 'https://api.iqmath.uz/api/v1';

  Future<List<ChapterModel>> fetchChapters(String studentId, String subjectId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/func_student/students/$studentId/subjects/$subjectId/chapters/'),
        headers: {
          'Accept': 'application/json',
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChapterModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}