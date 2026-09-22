// Topics Bottom Sheet
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/parent_assimilation_page.dart';

class TopicsBottomSheetLocalization {
  static final Map<String, Map<String, String>> _localizedValues = {
    'topics': {
      'uz': 'ta mavzu',
      'ru': 'тем',
    },
    'number': {
      'uz': '#',
      'ru': '#',
    },
    'name': {
      'uz': 'NOMI',
      'ru': 'НАЗВАНИЕ',
    },
    'assimilation': {
      'uz': 'O\'ZLASHTIRISH',
      'ru': 'УСВОЕНИЕ',
    },
  };

  static String get(String key, String locale) {
    return _localizedValues[key]?[locale] ?? _localizedValues[key]?['uz'] ?? key;
  }
}

class TopicsBottomSheet extends StatelessWidget {
  final ChapterModel chapter;
  final ScrollController? scrollController;

  const TopicsBottomSheet({
    super.key,
    required this.chapter,
    this.scrollController,
  });

  static void show(BuildContext context, ChapterModel chapter) {
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
        builder: (context, scrollController) => TopicsBottomSheet(
          chapter: chapter,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),

              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale == 'ru' ? chapter.chapterNameRu : chapter.chapterNameUz,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locale == 'ru'
                          ? '${chapter.topics.length} ${TopicsBottomSheetLocalization.get('topics', locale)}'
                          : '${chapter.topics.length} ${TopicsBottomSheetLocalization.get('topics', locale)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Table header
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            TopicsBottomSheetLocalization.get('number', locale),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            TopicsBottomSheetLocalization.get('name', locale),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            TopicsBottomSheetLocalization.get('assimilation', locale),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 1),

              // Topics list
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: chapter.topics.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      return TopicItem(
                        topic: chapter.topics[index],
                        index: index + 1,
                        locale: locale,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Topic Item Widget
class TopicItem extends StatelessWidget {
  final TopicParentModel topic;
  final int index;
  final String locale;

  const TopicItem({
    super.key,
    required this.topic,
    required this.index,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = topic.scorePercent == 100;
    final progressColor = isCompleted ? const Color(0xFF34C759) : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Number
          SizedBox(
            width: 40,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          // Name
          Expanded(
            flex: 3,
            child: Text(
              locale == 'ru' ? topic.topicNameRu : topic.topicNameUz,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Progress
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: topic.scorePercent / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: progressColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 45,
                  child: Text(
                    '${topic.scorePercent.toInt()}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}