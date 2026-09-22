import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'dart:convert';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';
import '../../data/models/diagnostics_history_response.dart';

class DiagnosticHistoryLocalization {
  static Map<String, Map<String, String>> translations = {
    'uz': {
      'error': 'Xatolik',
      'internetError': 'Internet bilan bog\'liq xatolik',
      'retry': 'Qayta urinish',
      'noHistory': 'Diagnostika tarixi topilmadi',
      'highest': 'Eng yuqori',
      'lowest': 'Eng past',
      'repeated': 'Takrorlanadigan',
      'hide': 'Yashirish',
      'more': 'ko\'p',
    },
    'ru': {
      'error': 'Ошибка',
      'internetError': 'Ошибка подключения к интернету',
      'retry': 'Повторить',
      'noHistory': 'История диагностики не найдена',
      'highest': 'Наивысший',
      'lowest': 'Наименьший',
      'repeated': 'Повторяющиеся',
      'hide': 'Скрыть',
      'more': 'больше',
    },
  };

  static String get(String key, String locale) {
    return translations[locale]?[key] ?? translations['uz']![key]!;
  }
}

class DiagnosticHistoryPage extends StatefulWidget {
  const DiagnosticHistoryPage({super.key});

  @override
  State<DiagnosticHistoryPage> createState() => _DiagnosticHistoryPageState();
}

class _DiagnosticHistoryPageState extends State<DiagnosticHistoryPage> {
  List<SubjectData> _subjects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDiagnosticHistory();
  }

  Future<void> _fetchDiagnosticHistory() async {
    var token = sl<LocalSource>().getAccessToken();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/my-diagnost/history/progress/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final historyResponse = DiagnosticHistoryResponse.fromJson(jsonData);

        setState(() {
          _subjects = historyResponse.subjects;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'error';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'internetError';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: _buildBody(locale),
        );
      },
    );
  }

  Widget _buildBody(String locale) {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(
          radius: 16,
        ),
      );
    }

    if (_errorMessage != null) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _fetchDiagnosticHistory,
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    DiagnosticHistoryLocalization.get(_errorMessage!, locale),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchDiagnosticHistory,
                    child: Text(
                      DiagnosticHistoryLocalization.get('retry', locale),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_subjects.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _fetchDiagnosticHistory,
          ),
          SliverFillRemaining(
            child: Center(
              child: Text(
                DiagnosticHistoryLocalization.get('noHistory', locale),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _fetchDiagnosticHistory,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return SubjectProgressCard(
                  subject: _subjects[index],
                  locale: locale,
                );
              },
              childCount: _subjects.length,
            ),
          ),
        ),
      ],
    );
  }
}

class SubjectProgressCard extends StatefulWidget {
  final SubjectData subject;
  final String locale;

  const SubjectProgressCard({
    super.key,
    required this.subject,
    required this.locale,
  });

  @override
  State<SubjectProgressCard> createState() => _SubjectProgressCardState();
}

class _SubjectProgressCardState extends State<SubjectProgressCard> {
  bool _showAllTopics = false;

  @override
  Widget build(BuildContext context) {
    double highestScore = widget.subject.progressHistory.isEmpty
        ? 0.0
        : widget.subject.progressHistory
            .map((e) => e.score)
            .reduce((a, b) => a > b ? a : b);

    String formattedDate = '';
    if (widget.subject.lastDate != null) {
      try {
        DateTime dateTime =
            DateFormat('yyyy-MM-dd HH:mm').parse(widget.subject.lastDate!);
        formattedDate = DateFormat('dd/M/yyyy').format(dateTime);
      } catch (e) {
        formattedDate = widget.subject.lastDate!;
      }
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    BaseFunctions.getLanguageText(
                      languageCode: widget.locale,
                      uz: widget.subject.classUz,
                      ru: widget.subject.classRu,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.blue.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.subject.progressPercent.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date
            if (formattedDate.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Chart
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  widget.subject.progressHistory.length,
                  (index) {
                    var history = widget.subject.progressHistory[index];
                    bool isLast =
                        index == widget.subject.progressHistory.length - 1;

                    return Expanded(
                      child: _buildBar(
                        history.score,
                        highestScore,
                        history.date,
                        isLast,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Legend
            Row(
              children: [
                _buildLegendItem(
                  '${DiagnosticHistoryLocalization.get('highest', widget.locale)}: ${highestScore.toStringAsFixed(0)}%',
                  Colors.blue.shade700,
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  '${DiagnosticHistoryLocalization.get('lowest', widget.locale)}: 0%',
                  Colors.grey.shade400,
                ),
              ],
            ),

            // Repeated Topics Section
            if (widget.subject.repeatedTopics.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    DiagnosticHistoryLocalization.get(
                        'repeated', widget.locale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(
                _showAllTopics
                    ? widget.subject.repeatedTopics.length
                    : (widget.subject.repeatedTopics.length > 3
                        ? 3
                        : widget.subject.repeatedTopics.length),
                (index) {
                  var topic = widget.subject.repeatedTopics[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            BaseFunctions.getLanguageText(
                              languageCode: widget.locale,
                              uz: topic.nameUz,
                              ru: topic.nameRu,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${topic.repeatCount}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (widget.subject.repeatedTopics.length > 3)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllTopics = !_showAllTopics;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      _showAllTopics
                          ? DiagnosticHistoryLocalization.get(
                              'hide', widget.locale)
                          : '+${widget.subject.repeatedTopics.length - 3} ${DiagnosticHistoryLocalization.get('more', widget.locale)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double score, double maxScore, String? date, bool isLast) {
    double normalizedHeight = maxScore > 0 ? (score / maxScore) : 0;
    double displayHeight = normalizedHeight > 0.05 ? normalizedHeight : 0.05;

    Color barColor = isLast ? Colors.blue.shade700 : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: date != null ? '$score% - $date' : '$score%',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: displayHeight,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
