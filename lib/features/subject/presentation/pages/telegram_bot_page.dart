import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'dart:convert';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';

class TelegramBotLocalization {
  final String locale;

  TelegramBotLocalization(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'title': 'Chat',
      'noData': 'Ma\'lumotlar yo\'q',
      'noDataDescription': 'Hozircha hech qanday test natijalari yo\'q',
      'refresh': 'Yangilash',
      'retryButton': 'Qayta urinish',
      'authError': 'Avtorizatsiya xatosi. Qayta kiring.',
      'serverError': 'Server xatosi:',
      'networkError': 'Internet bilan bog\'liq xatolik',
      'dataFormatError': 'Ma\'lumot formatida xatolik',
      'score': 'Ball:',
      'correct': 'To\'g\'ri:',
      'total': 'Jami:',
      'chapter': 'Bob:',
      'topic': 'Mavzu:',
      'telegram': 'Telegram',
    },
    'ru': {
      'title': 'Чат',
      'noData': 'Нет данных',
      'noDataDescription': 'Пока нет результатов тестов',
      'refresh': 'Обновить',
      'retryButton': 'Повторить попытку',
      'authError': 'Ошибка авторизации. Войдите снова.',
      'serverError': 'Ошибка сервера:',
      'networkError': 'Ошибка интернет-соединения',
      'dataFormatError': 'Ошибка формата данных',
      'score': 'Балл:',
      'correct': 'Правильно:',
      'total': 'Всего:',
      'chapter': 'Глава:',
      'topic': 'Тема:',
      'telegram': 'Telegram',
    },
  };

  String translate(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues['uz']![key]!;
  }

  // Getters
  String get title => translate('title');
  String get noData => translate('noData');
  String get noDataDescription => translate('noDataDescription');
  String get refresh => translate('refresh');
  String get retryButton => translate('retryButton');
  String get authError => translate('authError');
  String get serverError => translate('serverError');
  String get networkError => translate('networkError');
  String get dataFormatError => translate('dataFormatError');
  String get score => translate('score');
  String get correct => translate('correct');
  String get total => translate('total');
  String get chapter => translate('chapter');
  String get topic => translate('topic');
  String get telegram => translate('telegram');
}

// ==================== MAIN PAGE ====================
class TelegramBotPage extends StatefulWidget {
  const TelegramBotPage({super.key});

  @override
  State<TelegramBotPage> createState() => _TelegramBotPageState();
}

class _TelegramBotPageState extends State<TelegramBotPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _results = [];

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadResults();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMore();
      }
    }
  }

  TelegramBotLocalization _getLocalization() {
    final appState = context.read<AppBloc>().state;
    return TelegramBotLocalization(appState.appLocale??'uz');
  }

  Future<void> _loadResults() async {
    var token = sl<LocalSource>().getAccessToken();
    final l10n = _getLocalization();

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/func_student/my-independent/?page=$_currentPage&size=10'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final results = List<Map<String, dynamic>>.from(data['results'] ?? []);

        setState(() {
          _results.addAll(results);
          _totalPages = data['total_pages'] ?? 1;
          _isLoading = false;
          _hasError = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _hasError = true;
          _errorMessage = l10n.authError;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = '${l10n.serverError} ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = l10n.networkError;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    var token = sl<LocalSource>().getAccessToken();
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;

    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/func_student/my-independent/?page=$_currentPage&size=10'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final results = List<Map<String, dynamic>>.from(data['results'] ?? []);

        setState(() {
          _results.addAll(results);
          _totalPages = data['total_pages'] ?? 1;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
          _currentPage--;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
    }
  }

  Future<void> _refresh() async {
    var token = sl<LocalSource>().getAccessToken();
    final l10n = _getLocalization();

    setState(() {
      _results.clear();
      _currentPage = 1;
      _totalPages = 1;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/func_student/my-independent/?page=1&size=10'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final results = List<Map<String, dynamic>>.from(data['results'] ?? []);

        setState(() {
          _results.addAll(results);
          _totalPages = data['total_pages'] ?? 1;
          _hasError = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _hasError = true;
          _errorMessage = l10n.authError;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = '${l10n.serverError} ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = l10n.networkError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final l10n = TelegramBotLocalization(state.appLocale??'uz');

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const SizedBox.shrink(),
            title: Text(l10n.title),
          ),
          body: _buildBody(l10n),
        );
      },
    );
  }

  Widget _buildBody(TelegramBotLocalization l10n) {
    if (_hasError && _results.isEmpty) {
      return _buildErrorWidget(l10n);
    }

    if (_isLoading && _results.isEmpty) {
      return _buildLoadingWidget();
    }

    if (_results.isEmpty) {
      return _buildEmptyWidget(l10n);
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _refresh,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index == _results.length) {
                  return _isLoadingMore
                      ? _buildBottomLoader()
                      : const SizedBox.shrink();
                }
                return TestResultCard(
                  result: _results[index],
                  localization: l10n,
                );
              },
              childCount: _results.length + 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CupertinoActivityIndicator(radius: 16),
    );
  }

  Widget _buildBottomLoader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: const Center(
        child: CupertinoActivityIndicator(radius: 14),
      ),
    );
  }

  Widget _buildEmptyWidget(TelegramBotLocalization l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noData,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noDataDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refresh),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(TelegramBotLocalization l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retryButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CARD WIDGET ====================
class TestResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final TelegramBotLocalization localization;

  const TestResultCard({
    super.key,
    required this.result,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final resultData = result['result'][0];
      final score = resultData['score'];
      final correctAnswers = resultData['correct_answers'];
      final totalAnswers = resultData['total_answers'];
      final subjectName = result['subject_name_uz'];
      final chapterName = result['chapter_name_uz'][0];
      final topicName = result['topic_name_uz'][0];
      final status = result['status'];
      final telegramUrl = result['url'] ?? '';

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subjectName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${localization.chapter} $chapterName',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${localization.topic} $topicName',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      localization.score,
                      score.toString(),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      localization.correct,
                      correctAnswers.toString(),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      localization.total,
                      totalAnswers.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (telegramUrl.isNotEmpty) {
                      debugPrint('Telegram URL: $telegramUrl');
                      BaseFunctions.launchUrlStart(url: telegramUrl);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0088CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.send, size: 20),
                  label: Text(
                    localization.telegram,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          localization.dataFormatError,
          style: TextStyle(color: Colors.red[700]),
        ),
      );
    }
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}