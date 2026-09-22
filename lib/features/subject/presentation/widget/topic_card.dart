import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/features/subject/presentation/localization/subject_localization.dart';
import 'package:my_flutter_template/features/subject/presentation/widget/youtube_link_widget.dart';
import 'package:my_flutter_template/router/name_routes.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';
import '../../../../router/app_routes.dart';
import '../../data/models/chapter_model.dart';
import 'package:http/http.dart' as http;

import '../../data/models/topic_model.dart';

class ChapterTopicsSheet extends StatefulWidget {
  final ChapterModel chapter;
  final String subjectName;

  const ChapterTopicsSheet({
    super.key,
    required this.chapter,
    required this.subjectName,
    this.scrollController,
  });

  static void show(
      BuildContext context, ChapterModel chapter, String subjectName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.5, 0.9],
        builder: (context, scrollController) => ChapterTopicsSheet(
          chapter: chapter,
          subjectName: subjectName,
          scrollController: scrollController,
        ),
      ),
    );
  }

  final ScrollController? scrollController;

  @override
  State<ChapterTopicsSheet> createState() => _ChapterTopicsSheetState();
}

class _ChapterTopicsSheetState extends State<ChapterTopicsSheet> {
  List<TopicModel> topics = [];
  bool isLoading = true;
  String? errorType; // 'error' or 'internet'

  @override
  void initState() {
    super.initState();
    fetchTopics();
  }

  Future<void> fetchTopics() async {
    var token = sl<LocalSource>().getAccessToken();
    try {
      setState(() {
        isLoading = true;
        errorType = null;
      });

      final response = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/my-topic/${widget.chapter.id}/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          topics = data.map((item) => TopicModel.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorType = 'error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorType = 'internet';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),

              // Header
              Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  locale == 'ru' ? widget.chapter.nameRu : widget.chapter.nameUz,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: CupertinoColors.black,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.subjectName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    color: CupertinoColors.systemGrey,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minSize: 32,
                            onPressed: () => Navigator.pop(context),
                            child: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: CupertinoColors.systemGrey3,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress indicator
                      if(widget.chapter.progress!=101)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ChapterTopicsTranslations.t('progress', locale),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: widget.chapter.progressColor,
                                      ),
                                    ),
                                    Text(
                                      '${widget.chapter.progressPercent}%',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: widget.chapter.progressColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (widget.chapter.progress / 100)
                                        .clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFE5E5EA),
                                    valueColor: AlwaysStoppedAnimation(
                                      widget.chapter.progressColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 1),

              // Topics list or loading/error
              Expanded(
                child: isLoading
                    ? _buildLoadingView(locale)
                    : errorType != null
                    ? _buildErrorView(locale)
                    : _buildTopicsList(locale),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingView(String? locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(radius: 20),
          const SizedBox(height: 16),
          Text(
            ChapterTopicsTranslations.t('topicsLoading', locale),
            style: const TextStyle(
              fontSize: 15,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String? locale) {
    final errorMessage = errorType == 'internet'
        ? ChapterTopicsTranslations.t('checkInternet', locale)
        : ChapterTopicsTranslations.t('checkInternet', locale);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                CupertinoIcons.wifi_slash,
                size: 40,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ChapterTopicsTranslations.t('pleaseRetry', locale),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 32),
            CupertinoButton(
              onPressed: fetchTopics,
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              child: Text(
                ChapterTopicsTranslations.t('reload', locale),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsList(String? locale) {
    if (topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                CupertinoIcons.book,
                size: 40,
                color: CupertinoColors.systemGrey2,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              ChapterTopicsTranslations.t('topicsNotFound', locale),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ChapterTopicsTranslations.t('noTopicsYet', locale),
              style: const TextStyle(
                fontSize: 15,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: topics.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _TopicCard(topic: topics[index], locale: locale);
      },
    );
  }
}

class _TopicCard extends StatefulWidget {
  final TopicModel topic;
  final String? locale;

  const _TopicCard({
    required this.topic,
    this.locale,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final topicName = widget.locale == 'ru' ? widget.topic.nameRu : widget.topic.nameUz;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _showTopicDetails();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Lock/Status icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.topic.isLocked
                            ? CupertinoColors.systemGrey5
                            : widget.topic.progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.topic.isLocked
                            ? CupertinoIcons.lock_fill
                            : widget.topic.progress > 0
                            ? CupertinoIcons.checkmark_seal_fill
                            : CupertinoIcons.book_fill,
                        size: 22,
                        color: widget.topic.isLocked
                            ? CupertinoColors.systemGrey2
                            : widget.topic.progressColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topicName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: widget.topic.isLocked
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.black,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                widget.topic.score > 0
                                    ? CupertinoIcons.checkmark_circle_fill
                                    : CupertinoIcons.circle,
                                size: 14,
                                color: widget.topic.progressColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.topic.score > 0
                                    ? '${widget.topic.score} %'
                                    : widget.topic.score.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: widget.topic.progressColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                      color: widget.topic.isLocked
                          ? CupertinoColors.systemGrey3
                          : CupertinoColors.systemGrey2,
                    ),
                  ],
                ),
              ),
              if (widget.topic.progress > 0)
                Container(
                  height: 3,
                  color: const Color(0xFFF2F2F7),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (widget.topic.progress / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.topic.progressColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTopicDetails() {
    final topicName = widget.locale == 'ru' ? widget.topic.nameRu : widget.topic.nameUz;
    final videoUrl = widget.locale == 'ru' ? widget.topic.videoUrlRu : widget.topic.videoUrlUz;

    if (widget.topic.isLocked) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(ChapterTopicsTranslations.t('topicLocked', widget.locale)),
          content: Text(ChapterTopicsTranslations.t('topicLockedMessage', widget.locale)),
          actions: [
            CupertinoDialogAction(
              child: Text(ChapterTopicsTranslations.t('ok', widget.locale)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          topicName,
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
                '${ChapterTopicsTranslations.t('score', widget.locale)}: ${widget.topic.score}%',
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
                  topic: widget.topic,
                  isDiagnostic: false,
                  taskName: topicName,
                ),
              );
            },
            isDefaultAction: true,
            child: Text(
              widget.topic.progress > 0
                  ? ChapterTopicsTranslations.t('continue', widget.locale)
                  : ChapterTopicsTranslations.t('examples', widget.locale),
            ),
          ),
          if (videoUrl.isNotEmpty)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => YoutubeVideoDialog(
                      youtubeUrl: videoUrl,
                    ),
                  ),
                );
              },
              child: Text(ChapterTopicsTranslations.t('watchVideo', widget.locale)),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(ChapterTopicsTranslations.t('close', widget.locale)),
        ),
      ),
    );
  }
}

class QuestionPageArguments {
  final TopicModel? topic;
  final bool isDiagnostic;
  final String? taskName;
  final String? subjectId;

  QuestionPageArguments({
    required this.topic,
    required this.isDiagnostic,
    required this.taskName,
    this.subjectId,
  });
}