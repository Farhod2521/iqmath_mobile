// // import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
// // import 'package:my_flutter_template/core/utils/app_utils.dart';
// // import 'package:my_flutter_template/core/widgets/custom_animation_effects.dart';
// // import 'package:my_flutter_template/features/profile/presentation/widgets/faq_item.dart';
// // import 'package:my_flutter_template/generated/l10n.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_animate/flutter_animate.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:flutter_spinkit/flutter_spinkit.dart';
// // import 'package:gap/gap.dart';
// //
// // import '../../../../core/widgets/appbar_leading_widget.dart';
// // import '../../../../core/widgets/custom_loading_indicator.dart';
// // import '../blocs/faq/faq_bloc.dart';
// //
// // class FAQPage extends StatefulWidget {
// //   const FAQPage({super.key});
// //
// //   @override
// //   State<FAQPage> createState() => _FAQPageState();
// // }
// //
// // class _FAQPageState extends State<FAQPage> {
// //   @override
// //   void initState() {
// //     context.read<FaqBloc>().add(const FaqInitialEvent());
// //     super.initState();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final localization = AppLocalization.of(context);
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: const Row(
// //           mainAxisAlignment: MainAxisAlignment.end,
// //           children: [
// //             AppbarLeadingWidget(
// //               withBackground: true,
// //             ),
// //           ],
// //         ),
// //         leadingWidth: 56,
// //         title: Text('${localization.questions_and_answers} (F.A.Q.)'),
// //       ),
// //       body: BlocConsumer<FaqBloc, FaqState>(
// //         listener: (context, state) {
// //           if (state.status.isError) {
// //             AppUtils.showSnackBar(
// //               context: context,
// //               message: state.errorMessage?.message ?? 'empty',
// //               title: state.errorMessage?.title ?? 'empty',
// //             );
// //           }
// //         },
// //         builder: (context, state) => switch (state.status) {
// //           FaqStatus.idle => const SizedBox.shrink(),
// //           FaqStatus.loading => const Center(
// //               child: CustomLoadingIndicator(),
// //             ),
// //           FaqStatus.success ||
// //           FaqStatus.error =>
// //             (state.faqs == null || (state.faqs?.isEmpty ?? true))
// //                 ? const SizedBox.shrink()
// //                 : ListView.separated(
// //                     shrinkWrap: true,
// //                     padding: const EdgeInsets.all(20),
// //                     itemCount: state.faqs?.length ?? 0,
// //                     separatorBuilder: (context, index) => const Column(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         Gap(16),
// //                         Divider(),
// //                         Gap(16),
// //                       ],
// //                     ),
// //                     itemBuilder: (context, index) => FaqItem(
// //                       question: state.faqs?[index].question ?? 'empty',
// //                       answer: state.faqs?[index].answer ?? 'empty',
// //                     ),
// //                   ).animate(effects: slideAndFadeEffect),
// //         },
// //       ),
// //     );
// //   }
// // }
// //
// //
// import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
// import 'package:my_flutter_template/core/utils/app_utils.dart';
// import 'package:my_flutter_template/core/widgets/custom_animation_effects.dart';
// import 'package:my_flutter_template/features/profile/presentation/widgets/faq_item.dart';
// import 'package:my_flutter_template/generated/l10n.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:gap/gap.dart';
//
// import '../../../../core/widgets/appbar_leading_widget.dart';
// import '../../../../core/widgets/custom_loading_indicator.dart';
// import '../blocs/faq/faq_bloc.dart';
//
// class FAQPage extends StatefulWidget {
//   const FAQPage({super.key});
//
//   @override
//   State<FAQPage> createState() => _FAQPageState();
// }
//
// class _FAQPageState extends State<FAQPage> {
//   @override
//   void initState() {
//     context.read<FaqBloc>().add(const FaqInitialEvent());
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final localization = AppLocalization.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         leading:SizedBox.shrink(),
//         // title: Text('${localization.questions_and_answers} (F.A.Q.)'),
//         title: Text('Savol va javoblar'),
//       ),
//       body: BlocConsumer<FaqBloc, FaqState>(
//         listener: (context, state) {
//           if (state.status.isError) {
//             // AppUtils.showSnackBar(
//             //   context: context,
//             //   message: state.errorMessage?.message ?? 'empty',
//             //   title: state.errorMessage?.title ?? 'empty',
//             // );
//           }
//         },
//         builder: (context, state) => switch (state.status) {
//           FaqStatus.idle => const SizedBox.shrink(),
//           FaqStatus.loading => const Center(
//               child: CustomLoadingIndicator(),
//             ),
//           FaqStatus.error => ListView.separated(
//               shrinkWrap: true,
//               padding: const EdgeInsets.all(20),
//               // itemCount: state.faqs?.length ?? 0,
//               itemCount: 5,
//               separatorBuilder: (context, index) => const Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Gap(16),
//                   Divider(),
//                   Gap(16),
//                 ],
//               ),
//               itemBuilder: (context, index) => FaqItem(
//                 question: 'What is Flutter?',
//                 answer:
//                     'Flutter is a modern UI toolkit developed by Google. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
//                 // question: state.faqs?[index].question ?? 'empty',
//                 // answer: state.faqs?[index].answer ?? 'empty',
//               ),
//             ).animate(effects: slideAndFadeEffect),
//           // FaqStatus.success ||
//           // FaqStatus.error =>
//           //   (state.faqs == null || (state.faqs?.isEmpty ?? true))
//           //       ? const SizedBox.shrink()
//           //       : ListView.separated(
//           //           shrinkWrap: true,
//           //           padding: const EdgeInsets.all(20),
//           //           itemCount: state.faqs?.length ?? 0,
//           //           separatorBuilder: (context, index) => const Column(
//           //             mainAxisSize: MainAxisSize.min,
//           //             children: [
//           //               Gap(16),
//           //               Divider(),
//           //               Gap(16),
//           //             ],
//           //           ),
//           //           itemBuilder: (context, index) => FaqItem(
//           //             question: state.faqs?[index].question ?? 'empty',
//           //             answer: state.faqs?[index].answer ?? 'empty',
//           //           ),
//           //         ).animate(effects: slideAndFadeEffect),
//           // TODO: Handle this case.
//           FaqStatus.success => throw UnimplementedError(),
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ==================== LOCALIZATION CLASS ====================
class FAQLocalization {
  final String locale;

  FAQLocalization(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'title': 'Ko\'p so\'raladigan savollar',
      'loadingError': 'Ma\'lumotlarni yuklashda xatolik yuz berdi',
      'networkError': 'Internet bilan bog\'lanishda xatolik:',
      'retryButton': 'Qayta urinish',
      'noQuestions': 'Hozircha savollar mavjud emas',
      'watchVideo': 'Videoni tomosha qilish',
    },
    'ru': {
      'title': 'Часто задаваемые вопросы',
      'loadingError': 'Произошла ошибка при загрузке данных',
      'networkError': 'Ошибка подключения к интернету:',
      'retryButton': 'Повторить попытку',
      'noQuestions': 'Пока нет вопросов',
      'watchVideo': 'Смотреть видео',
    },
  };

  String translate(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues['uz']![key]!;
  }

  String get title => translate('title');
  String get loadingError => translate('loadingError');
  String get networkError => translate('networkError');
  String get retryButton => translate('retryButton');
  String get noQuestions => translate('noQuestions');
  String get watchVideo => translate('watchVideo');
}

// ==================== FAQ MODEL ====================
class FAQModel {
  final int id;
  final String questionUz;
  final String questionRu;
  final String answerUz;
  final String answerRu;
  final String? url;

  FAQModel({
    required this.id,
    required this.questionUz,
    required this.questionRu,
    required this.answerUz,
    required this.answerRu,
    this.url,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['id'],
      questionUz: json['question_uz'] ?? '',
      questionRu: json['question_ru'] ?? '',
      answerUz: json['answer_uz'] ?? '',
      answerRu: json['answer_ru'] ?? '',
      url: json['url'],
    );
  }

  String getQuestion(String locale) {
    return locale == 'ru' ? questionRu : questionUz;
  }

  String getAnswer(String locale) {
    return locale == 'ru' ? answerRu : answerUz;
  }

  String? getYouTubeEmbedUrl() {
    if (url == null || url!.isEmpty) return null;

    // YouTube URL formatlarini aniqlash
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );

    final match = regExp.firstMatch(url!);
    if (match != null && match.groupCount >= 1) {
      final videoId = match.group(1);
      return 'https://www.youtube.com/embed/$videoId';
    }

    return null;
  }
}

// ==================== MAIN PAGE ====================
class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<FAQModel> faqs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchFAQs();
  }

  FAQLocalization _getLocalization() {
    final appState = context.read<AppBloc>().state;
    return FAQLocalization(appState.appLocale ?? 'uz');
  }

  Future<void> fetchFAQs() async {
    final l10n = _getLocalization();

    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/management/faqs/'),
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          faqs = data.map((item) => FAQModel.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = l10n.loadingError;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '${l10n.networkError} $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final l10n = FAQLocalization(state.appLocale ?? 'uz');

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(l10n.title),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: const SizedBox.shrink(),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    fetchFAQs();
                  },
                  child: Text(l10n.retryButton),
                ),
              ],
            ),
          )
              : faqs.isEmpty
              ? Center(
            child: Text(
              l10n.noQuestions,
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
              : RefreshIndicator(
            onRefresh: fetchFAQs,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FAQItem(
                    faq: faqs[index],
                    locale: state.appLocale ?? 'uz',
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ==================== FAQ ITEM WIDGET ====================
class FAQItem extends StatefulWidget {
  final FAQModel faq;
  final String locale;

  const FAQItem({
    Key? key,
    required this.faq,
    required this.locale,
  }) : super(key: key);

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool isExpanded = false;

  String _parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? htmlString;
  }

  void _openVideoFullScreen(BuildContext context, String embedUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => YouTubeVideoPlayer(embedUrl: embedUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = widget.faq.getYouTubeEmbedUrl();

    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(
            widget.faq.getQuestion(widget.locale),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
            ),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              isExpanded = expanded;
            });
          },
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _parseHtmlString(widget.faq.getAnswer(widget.locale)),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  if (embedUrl != null) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _openVideoFullScreen(context, embedUrl),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // YouTube thumbnail
                              Image.network(
                                _getThumbnailUrl(embedUrl),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.black87,
                                    child: const Center(
                                      child: Icon(
                                        Icons.videocam,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Play button overlay
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThumbnailUrl(String embedUrl) {
    final videoId = embedUrl.split('/').last.split('?').first;
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }
}

// ==================== YOUTUBE VIDEO PLAYER ====================
class YouTubeVideoPlayer extends StatefulWidget {
  final String embedUrl;

  const YouTubeVideoPlayer({Key? key, required this.embedUrl}) : super(key: key);

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}

// class FAQModel {
//   final int id;
//   final String question;
//   final String questionUz;
//   final String questionRu;
//   final String answer;
//   final String answerUz;
//   final String answerRu;
//
//   FAQModel({
//     required this.id,
//     required this.question,
//     required this.questionUz,
//     required this.questionRu,
//     required this.answer,
//     required this.answerUz,
//     required this.answerRu,
//   });
//
//   factory FAQModel.fromJson(Map<String, dynamic> json) {
//     return FAQModel(
//       id: json['id'],
//       question: json['question'] ?? '',
//       questionUz: json['question_uz'] ?? '',
//       questionRu: json['question_ru'] ?? '',
//       answer: json['answer'] ?? '',
//       answerUz: json['answer_uz'] ?? '',
//       answerRu: json['answer_ru'] ?? '',
//     );
//   }
// }

// class FAQItem extends StatefulWidget {
//   final FAQModel faq;
//
//   const FAQItem({
//     Key? key,
//     required this.faq,
//   }) : super(key: key);
//
//   @override
//   State<FAQItem> createState() => _FAQItemState();
// }
//
// class _FAQItemState extends State<FAQItem> {
//   bool _isExpanded = false;
//
//   String _parseHtml(String htmlString) {
//     final document = html_parser.parse(htmlString);
//     return document.body?.text ?? '';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AppBloc, AppState>(
//       builder: (context, state) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Theme(
//             data: Theme.of(context).copyWith(
//               dividerColor: Colors.transparent,
//             ),
//             child: ExpansionTile(
//               title: Text(
//                 // widget.faq.questionUz,
//                 BaseFunctions.getLanguageText(
//                   languageCode: state.appLocale,
//                   uz: widget.faq.questionUz,
//                   ru: widget.faq.questionRu,
//                 ),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               trailing: Icon(
//                 _isExpanded ? Icons.remove : Icons.add,
//                 color: Colors.black54,
//               ),
//               onExpansionChanged: (expanded) {
//                 setState(() {
//                   _isExpanded = expanded;
//                 });
//               },
//               initiallyExpanded: false,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   child: Text(
//                     _parseHtml( BaseFunctions.getLanguageText(
//                       languageCode: state.appLocale,
//                       uz: widget.faq.answerUz,
//                       ru: widget.faq.answerRu,
//                     ),),
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                       height: 1.5,
//                     ),
//                     textAlign: TextAlign.justify,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
