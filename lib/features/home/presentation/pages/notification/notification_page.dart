import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:my_flutter_template/features/home/presentation/pages/notification/model/notification_response.dart';
import 'package:my_flutter_template/features/home/presentation/pages/notification/widgets/empty_notification_page.dart';
import 'package:my_flutter_template/features/home/presentation/pages/notification/widgets/notification_item.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/injector_container.dart';
import 'dart:convert';

import '../../../../../core/widgets/appbar_leading_widget.dart';
import '../../../../../core/widgets/custom_animation_effects.dart';
import '../../../../../core/widgets/custom_loading_indicator.dart';
import '../../../../../core/widgets/custom_sliver_pull_refresh.dart';

class NotificationPageStrings {
  final String notifications;
  final String news;
  final String retryButton;

  NotificationPageStrings({
    required this.notifications,
    required this.news,
    required this.retryButton,
  });

  static NotificationPageStrings getStrings(String locale) {
    switch (locale) {
      case 'uz':
        return NotificationPageStrings(
          notifications: 'Bildirishnomalar',
          news: 'Yangiliklar',
          retryButton: 'Qayta urinish',
        );
      case 'ru':
        return NotificationPageStrings(
          notifications: 'Уведомления',
          news: 'Новости',
          retryButton: 'Повторить',
        );
      default:
        return NotificationPageStrings(
          notifications: 'Bildirishnomalar',
          news: 'Yangiliklar',
          retryButton: 'Qayta urinish',
        );
    }
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  List<NotificationItemModel> _allNotifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url =
      Uri.parse('https://api.iqmath.uz/api/v1/management/app/elon-list/');
      final response = await http.get(url);
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        print('Response: ${response.body}');

        final List<dynamic> data = json.decode(response.body) as List;

        // Parse notifications with video support
        final notifications = data.map((json) {
          return NotificationItemModel(
            id: json['id'] as int,
            titleUz: json['title_uz'] as String?,
            titleRu: json['title_ru'] as String?,
            textUz: json['text_uz'] as String?,
            textRu: json['text_ru'] as String?,
            image: json['image'] as String?,
            video: json['video'] as String?,
            categories: (json['categories'] as List<dynamic>).cast<int>(),
            tagIds: (json['tags'] as List<dynamic>).cast<int>(),
            notificationStatus: json['notification_status'] as bool,
            newsStatus: json['news_status'] as bool,
            createdAt: DateTime.parse(json['created_at'] as String),
            updatedAt: DateTime.parse(json['updated_at'] as String),
          );
        }).toList();

        setState(() {
          _allNotifications = notifications;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print('Error loading notifications: $e');
    }
  }

  List<NotificationItemModel> _getNotifications() {
    return _allNotifications
        .where((notification) => notification.notificationStatus)
        .toList();
  }

  List<NotificationItemModel> _getNews() {
    return _allNotifications
        .where((notification) => notification.newsStatus)
        .toList();
  }

  String _stripHtmlTags(String htmlString) {
    // HTML teglarini olib tashlash
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String result = htmlString.replaceAll(exp, '');

    // HTML entity'larni almashtirish
    final entities = {
      '&nbsp;': ' ',
      '&rsquo;': "'",
      '&lsquo;': "'",
      '&#39;': "'",
      '&quot;': '"',
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&ndash;': '–',
      '&mdash;': '—',
      '&hellip;': '…',
      '&deg;': '°',
      '&copy;': '©',
      '&reg;': '®',
      '&trade;': '™',
      '&euro;': '€',
      '&pound;': '£',
      '&yen;': '¥',
    };

    // Barcha entity'larni almashtirish
    entities.forEach((entity, replacement) {
      result = result.replaceAll(entity, replacement);
    });

    // Raqamli HTML entity'larni almashtirish (&#39; kabi)
    result = result.replaceAllMapped(
      RegExp(r'&#(\d+);'),
          (match) {
        try {
          final code = int.parse(match.group(1)!);
          return String.fromCharCode(code);
        } catch (e) {
          return match.group(0)!;
        }
      },
    );

    // Hex formatdagi entity'larni almashtirish (&#x27; kabi)
    result = result.replaceAllMapped(
      RegExp(r'&#x([0-9A-Fa-f]+);'),
          (match) {
        try {
          final code = int.parse(match.group(1)!, radix: 16);
          return String.fromCharCode(code);
        } catch (e) {
          return match.group(0)!;
        }
      },
    );

    // Ko'p bo'sh joylarni bitta bo'sh joyga aylantirish
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    return result.trim();
  }

  String _getLocalizedTitle(NotificationItemModel notification, String locale) {
    if (locale == 'ru' && notification.titleRu != null) {
      return notification.titleRu!;
    } else if (notification.titleUz != null) {
      return notification.titleUz!;
    }
    return '';
  }

  String _getLocalizedText(NotificationItemModel notification, String locale) {
    if (locale == 'ru' && notification.textRu != null) {
      return notification.textRu!;
    } else if (notification.textUz != null) {
      return notification.textUz!;
    }
    return '';
  }

  Widget _buildNotificationList(List<NotificationItemModel> notifications, String locale) {
    if (notifications.isEmpty) {
      return const EmptyNotificationPage();
    }

    return CustomScrollView(
      slivers: [
        CustomSliverPullRefresh(
          onRefresh: () async {
            await _loadNotifications();
          },
        ),
        SliverPadding(
          padding: AppUtils.kPaddingAll16,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index.isOdd) {
                  return const Gap(16);
                }
                final notificationIndex = index ~/ 2;
                final notification = notifications[notificationIndex];
                final title = _getLocalizedTitle(notification, locale);
                final text = _getLocalizedText(notification, locale);

                return NotificationItem(
                  title: title,
                  subtitle: _stripHtmlTags(text),
                  dateTime: notification.createdAt,
                  imageUrl: notification.image,
                  videoUrl: notification.video,
                ).animate(
                  effects: slideAndFadeEffect,
                  delay: Duration(milliseconds: notificationIndex * 50),
                );
              },
              childCount: notifications.length * 2 - 1,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale ?? 'uz';
        final strings = NotificationPageStrings.getStrings(locale);
        return Scaffold(
          appBar: AppBar(
            leading: SizedBox.shrink(),
            title: Text(localization.notification),
          ),
          body: _isLoading
              ? const Center(child: CustomLoadingIndicator())
              : _errorMessage != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_errorMessage!),
                const Gap(16),
                ElevatedButton(
                  onPressed: _loadNotifications,
                  child: Text(strings.retryButton),
                ),
              ],
            ),
          )
              : _allNotifications.isEmpty
              ? const EmptyNotificationPage()
              : Column(
            children: [
              if (_tabController != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: context.color.bg1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.color.mainText5.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: context.color.primaryColor1,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: context.color.primaryColor1
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: context.color.mainText5,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            strings.notifications,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            strings.news,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _tabController == null
                    ? const SizedBox.shrink()
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationList(_getNotifications(), locale),
                    _buildNotificationList(_getNews(), locale),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}