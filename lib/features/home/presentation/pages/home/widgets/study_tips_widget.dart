import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/home/presentation/page_parts/home_localizations.dart';
import '../../../../../../injector_container.dart';

class StudyTipsWidget extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const StudyTipsWidget({
    super.key,
    this.refreshNotifier,
  });

  @override
  State<StudyTipsWidget> createState() => _StudyTipsWidgetState();
}

class _StudyTipsWidgetState extends State<StudyTipsWidget> {
  final PageController _pageController = PageController();
  int _currentTipIndex = 0;
  Timer? _tipTimer;

  List<Motivation> _motivations = [];
  bool _isLoading = true;
  String? _errorType;

  @override
  void initState() {
    super.initState();
    _fetchMotivations();
    widget.refreshNotifier?.addListener(_onRefresh);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_onRefresh);
    _tipTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    _fetchMotivations();
  }

  Future<void> _fetchMotivations() async {
    var token = sl<LocalSource>().getAccessToken();
    try {
      setState(() {
        _isLoading = true;
        _errorType = null;
      });

      final response = await http.get(
        Uri.parse(
          'https://api.iqmath.uz/api/v1/management/app/motivation-list/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> motivationsList = data['motivations'];

        setState(() {
          _motivations = motivationsList
              .map((item) => Motivation.fromJson(item))
              .where((motivation) => motivation.hasContent())
              .toList();
          _isLoading = false;
          _errorType = null;
        });

        if (_motivations.isNotEmpty) {
          _tipTimer?.cancel();
          _startTipTimer();
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorType = 'error';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorType = 'internet';
      });
    }
  }

  void _startTipTimer() {
    _tipTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (mounted && _pageController.hasClients && _motivations.isNotEmpty) {
        _currentTipIndex = (_currentTipIndex + 1) % _motivations.length;
        _pageController.animateToPage(
          _currentTipIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
              StudyTipsTranslations.t('studyTips', locale),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBA68C8), Color(0xFF9C27B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )

            else if (_errorType != null)
              Container(
                height: 80,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _errorType == 'error'
                        ? StudyTipsTranslations.t('errorLoadingData', locale)
                        : StudyTipsTranslations.t('internetError', locale),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )

            else if (_motivations.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _motivations.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentTipIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final motivation = _motivations[index];
                      final content = motivation.getContent(locale);

                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFBA68C8), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Html(
                            data: content,
                            style: {
                              "body": Style(
                                fontSize: FontSize(14),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                textAlign: TextAlign.center,
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "p": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )

              else
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFBA68C8), Color(0xFF9C27B0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      StudyTipsTranslations.t('noTipsYet', locale),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

            const SizedBox(height: 12),

            if (_motivations.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _motivations.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentTipIndex == index
                          ? const Color(0xFF9C27B0)
                          : const Color(0xFF9C27B0).withOpacity(0.3),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class Motivation {
  final String? titleUz;
  final String? titleRu;
  final String? contentUz;
  final String? contentRu;
  final String createdAt;

  Motivation({
    this.titleUz,
    this.titleRu,
    this.contentUz,
    this.contentRu,
    required this.createdAt,
  });

  factory Motivation.fromJson(Map<String, dynamic> json) {
    return Motivation(
      titleUz: json['title_uz'],
      titleRu: json['title_ru'],
      contentUz: json['content_uz'],
      contentRu: json['content_ru'],
      createdAt: json['created_at'] ?? '',
    );
  }

  String getTitle(String? locale) {
    if (locale == 'ru' && titleRu != null && titleRu!.isNotEmpty) {
      return titleRu!;
    } else if (titleUz != null && titleUz!.isNotEmpty) {
      return titleUz!;
    }
    return '';
  }

  String getContent(String? locale) {
    if (locale == 'ru' && contentRu != null && contentRu!.isNotEmpty) {
      return contentRu!;
    } else if (contentUz != null && contentUz!.isNotEmpty) {
      return contentUz!;
    }
    return '';
  }

  bool hasContent() {
    return (contentUz != null && contentUz!.isNotEmpty) ||
        (contentRu != null && contentRu!.isNotEmpty);
  }
}