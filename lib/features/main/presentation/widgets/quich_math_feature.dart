// quick_math_strings.dart

// quick_math_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
// quick_math_models.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/injector_container.dart';

class QuickMathStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'quickMathTitle': {
      'uz': 'Tez Matematika',
      'ru': 'Быстрая Математика',
    },
    'topicLabel': {
      'uz': 'Mavzu',
      'ru': 'Тема',
    },
    'levelLabel': {
      'uz': 'Daraja',
      'ru': 'Уровень',
    },
    'answerPlaceholder': {
      'uz': 'Javobingizni kiriting',
      'ru': 'Введите ваш ответ',
    },
    'checkButton': {
      'uz': 'Tekshirish',
      'ru': 'Проверить',
    },
    'nextQuestion': {
      'uz': 'Keyingi savol',
      'ru': 'Следующий вопрос',
    },
    'tryAgain': {
      'uz': 'Yana urinish',
      'ru': 'Попробовать снова',
    },
    'retryButton': {
      'uz': 'Qayta urinish',
      'ru': 'Повторить попытку',
    },
    'excellent': {
      'uz': 'Ajoyib!',
      'ru': 'Отлично!',
    },
    'tryAgainTitle': {
      'uz': 'Qaytadan urining',
      'ru': 'Попробуйте еще раз',
    },
    'errorTitle': {
      'uz': 'Xatolik',
      'ru': 'Ошибка',
    },
    'loadQuestionError': {
      'uz': 'Savolni yuklashda xatolik',
      'ru': 'Ошибка при загрузке вопроса',
    },
    'submitAnswerError': {
      'uz': 'Javobni yuborishda xatolik yuz berdi',
      'ru': 'Произошла ошибка при отправке ответа',
    },
    'imageLoadError': {
      'uz': 'Rasmni yuklab bo\'lmadi',
      'ru': 'Не удалось загрузить изображение',
    },
    'imageDisplayError': {
      'uz': 'Rasmni ko\'rsatib bo\'lmadi',
      'ru': 'Не удалось отобразить изображение',
    },
    'ok': {
      'uz': 'OK',
      'ru': 'OK',
    },
  };

  static String get(String key, String locale) {
    // Default to 'uz' if locale is not found
    final normalizedLocale = locale.toLowerCase().contains('ru') ? 'ru' : 'uz';
    return _localizedValues[key]?[normalizedLocale] ??
        _localizedValues[key]?['uz'] ??
        key;
  }
}

class QuickMathQuestion {
  final int questionId;
  final int topicId;
  final String topicNameUz;
  final String topicNameRu;
  final String questionTextUz;
  final String questionTextRu;
  final int level;

  QuickMathQuestion({
    required this.questionId,
    required this.topicId,
    required this.topicNameUz,
    required this.topicNameRu,
    required this.questionTextUz,
    required this.questionTextRu,
    required this.level,
  });

  factory QuickMathQuestion.fromJson(Map<String, dynamic> json) {
    return QuickMathQuestion(
      questionId: json['question_id'],
      topicId: json['topic_id'],
      topicNameUz: json['topic_name_uz'] ?? json['topic_name'] ?? '',
      topicNameRu: json['topic_name_ru'] ?? json['topic_name'] ?? '',
      questionTextUz: json['question_text_uz'] ?? json['question_text'] ?? '',
      questionTextRu: json['question_text_ru'] ?? json['question_text'] ?? '',
      level: json['level'],
    );
  }

  String getTopicName(String locale) {
    return locale.toLowerCase().contains('ru') ? topicNameRu : topicNameUz;
  }

  String getQuestionText(String locale) {
    return locale.toLowerCase().contains('ru') ? questionTextRu : questionTextUz;
  }
}

class QuickMathResponse {
  final bool isCorrect;
  final String message;
  final String emoji;

  QuickMathResponse({
    required this.isCorrect,
    required this.message,
    required this.emoji,
  });

  factory QuickMathResponse.fromJson(Map<String, dynamic> json) {
    return QuickMathResponse(
      isCorrect: json['is_correct'],
      message: json['message'],
      emoji: json['emoji'],
    );
  }
}

class QuickMathService {
  static const String baseUrl =
      'https://api.iqmath.uz/api/v1/func_student/quick-math';

  Future<QuickMathQuestion> getQuestion() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/question/'),
        headers: {
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
          'Content-Type': 'application/json',
        },
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return QuickMathQuestion.fromJson(data);
      } else {
        throw Exception('Failed to load question');
      }
    } catch (e) {
      throw Exception('Error fetching question: $e');
    }
  }

  Future<QuickMathResponse> submitAnswer(int questionId, String answer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit/'),
        headers: {
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'question_id': questionId,
          'answer': answer,
        }),
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return QuickMathResponse.fromJson(data);
      } else {
        throw Exception('Failed to submit answer');
      }
    } catch (e) {
      throw Exception('Error submitting answer: $e');
    }
  }
}

class QuickMathFloatingButton extends StatefulWidget {
  const QuickMathFloatingButton({super.key});

  @override
  State<QuickMathFloatingButton> createState() =>
      _QuickMathFloatingButtonState();
}

class _QuickMathFloatingButtonState extends State<QuickMathFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showMathDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const QuickMathDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Positioned(
              bottom: 90 + _bounceAnimation.value,
              right: 20,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: GestureDetector(
                  onTap: _showMathDialog,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.function,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class QuickMathDialog extends StatefulWidget {
  const QuickMathDialog({super.key});

  @override
  State<QuickMathDialog> createState() => _QuickMathDialogState();
}

class _QuickMathDialogState extends State<QuickMathDialog>
    with TickerProviderStateMixin {
  QuickMathQuestion? _question;
  bool _isLoading = true;
  String? _error;
  final MathFieldEditingController _mathController =
  MathFieldEditingController();
  bool _isSubmitting = false;
  final QuickMathService _mathService = QuickMathService();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _currentLocale = 'uz';

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _slideController.forward();
    _fadeController.forward();
    _loadQuestion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = context.read<AppBloc>().state;
    _currentLocale = appState.appLocale??'uz';
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final question = await _mathService.getQuestion();
      setState(() {
        _question = question;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = QuickMathStrings.get('loadQuestionError', _currentLocale);
        _isLoading = false;
      });
    }
  }

  String _cleanQuestionText(String htmlText) {
    String cleaned = htmlText
        .replaceAll('<p>', '')
        .replaceAll('</p>', '')
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n');

    return cleaned.trim();
  }

  List<String> _extractBase64Images(String htmlText) {
    final imgPattern = RegExp(
      r'<img[^>]+src="data:image/[^;]+;base64,([^"]+)"[^>]*>',
      caseSensitive: false,
    );

    final matches = imgPattern.allMatches(htmlText);
    return matches.map((match) => match.group(1) ?? '').toList();
  }

  String _removeImages(String htmlText) {
    return htmlText.replaceAll(
      RegExp(r'<img[^>]*>', caseSensitive: false),
      '',
    );
  }

  Widget _buildQuestionContent(String questionText) {
    final base64Images = _extractBase64Images(questionText);
    final cleanedText = _cleanQuestionText(_removeImages(questionText));

    final latexPattern = RegExp(r'\\\((.+?)\\\)|\\\[(.+?)\\\]');
    final matches = latexPattern.allMatches(cleanedText);

    List<Widget> contentWidgets = [];

    if (base64Images.isNotEmpty) {
      for (final base64Image in base64Images) {
        try {
          final imageBytes = base64Decode(base64Image);
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            color: Color(0xFFEF4444),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            QuickMathStrings.get('imageLoadError', _currentLocale),
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        } catch (e) {
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      QuickMathStrings.get('imageDisplayError', _currentLocale),
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    if (cleanedText.isNotEmpty) {
      if (matches.isEmpty) {
        contentWidgets.add(
          Text(
            cleanedText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: Color(0xFF000000),
              letterSpacing: -0.3,
            ),
          ),
        );
      } else {
        List<InlineSpan> spans = [];
        int currentIndex = 0;

        for (final match in matches) {
          if (match.start > currentIndex) {
            spans.add(TextSpan(
              text: cleanedText.substring(currentIndex, match.start),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: Color(0xFF000000),
                letterSpacing: -0.3,
              ),
            ));
          }

          final latex = match.group(1) ?? match.group(2) ?? '';

          try {
            spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Math.tex(
                  latex,
                  textStyle: const TextStyle(
                    fontSize: 19,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ));
          } catch (e) {
            spans.add(TextSpan(
              text: latex,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6366F1),
              ),
            ));
          }

          currentIndex = match.end;
        }

        if (currentIndex < cleanedText.length) {
          spans.add(TextSpan(
            text: cleanedText.substring(currentIndex),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: Color(0xFF000000),
              letterSpacing: -0.3,
            ),
          ));
        }

        contentWidgets.add(
          RichText(
            text: TextSpan(children: spans),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  Future<void> _submitAnswer() async {
    final answer = _mathController.currentEditingValue();
    if (answer.isEmpty || _question == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _mathService.submitAnswer(
        _question!.questionId,
        answer,
      );

      if (mounted) {
        await _showResultDialog(response);
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(QuickMathStrings.get('errorTitle', _currentLocale)),
            content: Text(QuickMathStrings.get('submitAnswerError', _currentLocale)),
            actions: [
              CupertinoDialogAction(
                child: Text(QuickMathStrings.get('ok', _currentLocale)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showResultDialog(QuickMathResponse response) async {
    await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: response.isCorrect
                    ? const Color(0xFF10B981).withOpacity(0.15)
                    : const Color(0xFFF59E0B).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  response.emoji,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              response.isCorrect
                  ? QuickMathStrings.get('excellent', _currentLocale)
                  : QuickMathStrings.get('tryAgainTitle', _currentLocale),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: response.isCorrect
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                response.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              _mathController.clear();
              _loadQuestion();
            },
            child: Text(
              response.isCorrect
                  ? QuickMathStrings.get('nextQuestion', _currentLocale)
                  : QuickMathStrings.get('tryAgain', _currentLocale),
              style: TextStyle(
                color: response.isCorrect
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mathController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        _currentLocale = appState.appLocale??'uz';

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 60,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 180,
                    ),
                    child: Center(
                      child: Container(
                        width: constraints.maxWidth > 500
                            ? 420.0
                            : constraints.maxWidth * 0.9,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 0,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.function,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    QuickMathStrings.get('quickMathTitle', _currentLocale),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF000000),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => Navigator.pop(context),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.xmark,
                                        color: Color(0xFF6B7280),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: _isLoading
                                  ? const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                      radius: 16),
                                ),
                              )
                                  : _error != null
                                  ? _buildErrorState()
                                  : _question != null
                                  ? _buildQuestionState()
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            size: 40,
            color: Color(0xFFEF4444),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: _loadQuestion,
            borderRadius: BorderRadius.circular(12),
            child: Text(
              QuickMathStrings.get('retryButton', _currentLocale),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _question!.getTopicName(_currentLocale),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.star_fill,
                            size: 13,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${QuickMathStrings.get('levelLabel', _currentLocale)} ${_question!.level}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildQuestionContent(_question!.getQuestionText(_currentLocale)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Math Answer Input
        MathField(
          controller: _mathController,
          keyboardType: MathKeyboardType.expression,
          variables: const ['x', 'y', 'z', 'a', 'b', 'c'],
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF9CA3AF),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: QuickMathStrings.get('answerPlaceholder', _currentLocale),
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
          onChanged: (value) {},
          onSubmitted: (value) => _submitAnswer(),
        ),
        const SizedBox(height: 20),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            onPressed: _isSubmitting ? null : _submitAnswer,
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _isSubmitting
                ? const CupertinoActivityIndicator(
              color: Colors.white,
              radius: 11,
            )
                : Text(
              QuickMathStrings.get('checkButton', _currentLocale),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}