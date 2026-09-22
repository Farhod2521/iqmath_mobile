import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/injector_container.dart';

class DiagnosticsLocalization {
  static final Map<String, Map<String, String>> _localizedValues = {
    'title': {
      'uz': 'Diagnostika tarixi',
      'ru': 'История диагностики',
    },
    'progress': {
      'uz': 'O\'zlashtirish',
      'ru': 'Прогресс',
    },
    'repeatedTopics': {
      'uz': 'Takrorlanadigan mavzular',
      'ru': 'Повторяющиеся темы',
    },
    'noRepeatedTopics': {
      'uz': 'Takrorlanadigan mavzular yo\'q',
      'ru': 'Нет повторяющихся тем',
    },
    'times': {
      'uz': 'marta',
      'ru': 'раз',
    },
    'noDiagnostic': {
      'uz': 'Diagnostika topilmadi',
      'ru': 'Диагностика не найдена',
    },
    'loading': {
      'uz': 'Yuklanmoqda...',
      'ru': 'Загрузка...',
    },
    'error': {
      'uz': 'Xatolik yuz berdi',
      'ru': 'Произошла ошибка',
    },
    'retry': {
      'uz': 'Qayta urinish',
      'ru': 'Попробовать снова',
    },
    'lastTest': {
      'uz': 'So\'nggi test',
      'ru': 'Последний тест',
    },
    'class': {
      'uz': 'Sinf',
      'ru': 'Класс',
    },
  };

  static String get(String key, String locale) {
    return _localizedValues[key]?[locale] ??
        _localizedValues[key]?['uz'] ??
        key;
  }
}

class DiagnosticSubject {
  final int id;
  final String nameUz;
  final String nameRu;
  final String className;
  final String classUz;
  final String classRu;
  final String imageUz;
  final String imageRu;
  final double progressPercent;
  final List<ProgressHistory> progressHistory;
  final String? lastDate;
  final bool hasTakenDiagnostic;
  final List<RepeatedTopic> repeatedTopics;

  DiagnosticSubject({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.className,
    required this.classUz,
    required this.classRu,
    required this.imageUz,
    required this.imageRu,
    required this.progressPercent,
    required this.progressHistory,
    this.lastDate,
    required this.hasTakenDiagnostic,
    required this.repeatedTopics,
  });

  factory DiagnosticSubject.fromJson(Map<String, dynamic> json) {
    return DiagnosticSubject(
      id: json['id'] ?? 0,
      nameUz: json['name_uz'] ?? '',
      nameRu: json['name_ru'] ?? '',
      className: json['class_name'] ?? '',
      classUz: json['class_uz'] ?? '',
      classRu: json['class_ru'] ?? '',
      imageUz: json['image_uz'] ?? '',
      imageRu: json['image_ru'] ?? '',
      progressPercent: (json['progress_percent'] ?? 0).toDouble(),
      progressHistory: (json['progress_history'] as List?)
          ?.map((e) => ProgressHistory.fromJson(e))
          .toList() ??
          [],
      lastDate: json['last_date'],
      hasTakenDiagnostic: json['has_taken_diagnostic'] ?? false,
      repeatedTopics: (json['repeated_topics'] as List?)
          ?.map((e) => RepeatedTopic.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ProgressHistory {
  final String? date;
  final double score;

  ProgressHistory({
    this.date,
    required this.score,
  });

  factory ProgressHistory.fromJson(Map<String, dynamic> json) {
    return ProgressHistory(
      date: json['date'],
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}

class RepeatedTopic {
  final int id;
  final String nameUz;
  final String nameRu;
  final int repeatCount;

  RepeatedTopic({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.repeatCount,
  });

  factory RepeatedTopic.fromJson(Map<String, dynamic> json) {
    return RepeatedTopic(
      id: json['id'] ?? 0,
      nameUz: json['name_uz'] ?? '',
      nameRu: json['name_ru'] ?? '',
      repeatCount: json['repeat_count'] ?? 0,
    );
  }
}

class ParentStudentDiagnosticsPage extends StatefulWidget {
  final String studentId;

  const ParentStudentDiagnosticsPage({
    super.key,
    required this.studentId,
  });

  @override
  State<ParentStudentDiagnosticsPage> createState() =>
      _ParentStudentDiagnosticsPageState();
}

class _ParentStudentDiagnosticsPageState
    extends State<ParentStudentDiagnosticsPage> {
  List<DiagnosticSubject> subjects = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDiagnostics();
  }

  Future<void> fetchDiagnostics() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final url =
          'https://api.iqmath.uz/api/v1/func_student/parent/student-diagnostic-history/?student_id=${widget.studentId}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          subjects = data.map((e) => DiagnosticSubject.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
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
          backgroundColor: const Color(0xFFF8F9FF),
          appBar: AppBar(
            title: Text(DiagnosticsLocalization.get('title', locale)),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: _buildBody(locale),
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

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: fetchDiagnostics,
              icon: const Icon(Icons.refresh),
              label: Text(DiagnosticsLocalization.get('retry', locale)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (subjects.isEmpty) {
      return Center(
        child: Text(
          DiagnosticsLocalization.get('noDiagnostic', locale),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await fetchDiagnostics();
          },
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index == subjects.length - 1) {
                  return Column(
                    children: [
                      _buildSubjectCard(subjects[index], locale),
                      const SizedBox(height: 60),
                    ],
                  );
                }
                return _buildSubjectCard(subjects[index], locale);
              },
              childCount: subjects.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(DiagnosticSubject subject, String locale) {
    final subjectName = locale == 'uz' ? subject.nameUz : subject.nameRu;
    final className = locale == 'uz' ? subject.classUz : subject.classRu;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4285F4).withOpacity(0.8),
                  const Color(0xFF34A853).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      'https://api.iqmath.uz${locale == 'uz' ? subject.imageUz : subject.imageRu}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF4285F4),
                          child: const Center(
                            child: Icon(
                              Icons.book,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subjectName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DiagnosticsLocalization.get('progress', locale),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${subject.progressPercent.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: subject.progressPercent / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4285F4),
                    ),
                    minHeight: 8,
                  ),
                ),

                // Last test date
                if (subject.lastDate != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DiagnosticsLocalization.get('lastTest', locale)}: ${subject.lastDate}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],

                // Repeated topics
                if (subject.repeatedTopics.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    DiagnosticsLocalization.get('repeatedTopics', locale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...subject.repeatedTopics.take(5).map((topic) {
                    final topicName =
                    locale == 'uz' ? topic.nameUz : topic.nameRu;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getRepeatColor(topic.repeatCount)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.repeat,
                              size: 20,
                              color: _getRepeatColor(topic.repeatCount),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topicName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${topic.repeatCount} ${DiagnosticsLocalization.get('times', locale)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getRepeatColor(topic.repeatCount),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (subject.repeatedTopics.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+${subject.repeatedTopics.length - 5} ko\'proq',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ] else ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      DiagnosticsLocalization.get('noRepeatedTopics', locale),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRepeatColor(int count) {
    if (count >= 7) return const Color(0xFFDB4437); // Red
    if (count >= 5) return Colors.orange; // Orange
    if (count >= 3) return Colors.amber; // Amber
    return const Color(0xFF0F9D58); // Green
  }
}