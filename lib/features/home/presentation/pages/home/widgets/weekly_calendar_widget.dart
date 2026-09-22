import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/home/presentation/page_parts/home_localizations.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/app_routes.dart';

class PerfectMonthlyCalendarWidget extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const PerfectMonthlyCalendarWidget({
    super.key,
    this.refreshNotifier,
  });

  @override
  State<PerfectMonthlyCalendarWidget> createState() => _PerfectMonthlyCalendarWidgetState();
}

class _PerfectMonthlyCalendarWidgetState extends State<PerfectMonthlyCalendarWidget> {
  late PageController _pageController;
  DateTime selectedMonth = DateTime.now();
  Map<String, Map<String, dynamic>> allWeeksData = {};
  bool isLoading = true;
  String? errorType;
  int currentPageIndex = 120;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPageIndex);
    _fetchMonthlyStats();
    widget.refreshNotifier?.addListener(_onRefresh);
  }

  @override
  void dispose() {
    _pageController.dispose();
    widget.refreshNotifier?.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    _fetchMonthlyStats();
  }

  DateTime _getMonthFromPageIndex(int index) {
    final now = DateTime.now();
    final monthsDiff = index - currentPageIndex;
    return DateTime(now.year, now.month + monthsDiff);
  }

  List<int> _getWeeksInMonth() {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    Set<int> weeks = {};

    for (int day = 1; day <= lastDay.day; day++) {
      int weekNumber = ((day - 1) / 7).floor() + 1;
      weeks.add(weekNumber);
    }

    return weeks.toList();
  }

  Future<void> _fetchMonthlyStats() async {
    var token = sl<LocalSource>().getAccessToken();
    try {
      setState(() {
        isLoading = true;
        errorType = null;
        allWeeksData.clear();
      });

      final weeks = _getWeeksInMonth();

      for (int week in weeks) {
        try {
          final url = Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/student/weklystudystats/app'
                '?year=${selectedMonth.year}&month=${selectedMonth.month}&week=$week',
          );

          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': '$token',
            },
          );
          alice.onHttpResponse(response);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final weekInfo = data['week_info'] as Map<String, dynamic>?;

            if (weekInfo != null) {
              final weekStart = weekInfo['week_start'] as String;
              allWeeksData[weekStart] = data;
            }
          }
        } catch (e) {
          print('Error fetching week $week: $e');
        }
      }

      setState(() {
        isLoading = false;
        if (allWeeksData.isEmpty) {
          errorType = 'notLoaded';
        }
      });
    } catch (e) {
      setState(() {
        errorType = 'error';
        isLoading = false;
      });
    }
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    List<DateTime> days = [];

    int weekday = firstDay.weekday;
    for (int i = 1; i < weekday; i++) {
      days.add(DateTime(0));
    }

    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    return days;
  }

  bool _isDayStudied(DateTime date) {
    if (date.year == 0) return false;

    for (var weekData in allWeeksData.values) {
      final weekInfo = weekData['week_info'] as Map<String, dynamic>?;
      final weekStats = weekData['week_stats'] as Map<String, dynamic>?;

      if (weekInfo == null || weekStats == null) continue;

      final weekStart = DateTime.parse(weekInfo['week_start']);
      final weekEnd = DateTime.parse(weekInfo['week_end']);

      if (date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          date.isBefore(weekEnd.add(const Duration(days: 1)))) {
        final dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
        final dayIndex = date.weekday - 1;

        if (dayIndex >= 0 && dayIndex < dayKeys.length) {
          return weekStats[dayKeys[dayIndex]] ?? false;
        }
      }
    }

    return false;
  }

  Map<String, dynamic>? _getDayDetails(DateTime date) {
    if (date.year == 0) return null;

    for (var weekData in allWeeksData.values) {
      final weekInfo = weekData['week_info'] as Map<String, dynamic>?;
      final details = weekData['details'] as Map<String, dynamic>?;

      if (weekInfo == null || details == null) continue;

      final weekStart = DateTime.parse(weekInfo['week_start']);
      final weekEnd = DateTime.parse(weekInfo['week_end']);

      if (date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          date.isBefore(weekEnd.add(const Duration(days: 1)))) {
        final dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
        final dayIndex = date.weekday - 1;

        if (dayIndex >= 0 && dayIndex < dayKeys.length) {
          final dayData = details[dayKeys[dayIndex]];
          return {'data': dayData, 'date': date};
        }
      }
    }

    return null;
  }

  void _showDayDetails(BuildContext context, DateTime date, String locale) {
    final dayInfo = _getDayDetails(date);
    if (dayInfo == null) return;

    final dayDetails = dayInfo['data'];

    showModalBottomSheet(
      context: mainRootNavigatorKey.currentContext!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${date.day} ${_getMonthName(date.month, locale)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Expanded(
                  child: (dayDetails == null || dayDetails is String)
                      ? _buildNoStudyMessage(locale)
                      : _buildStudyDetails(context, dayDetails as List, locale, scrollController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoStudyMessage(String locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.moon_zzz,
                size: 34,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              locale == 'uz'
                  ? "Bu kuni siz misollar ishlamadingiz"
                  : "В этот день вы не решали задачи",
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              locale == 'uz'
                  ? "Bilimingizni oshirish uchun mashq qiling!"
                  : "Практикуйтесь, чтобы улучшить свои знания!",
              style: const TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemGrey2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyDetails(
      BuildContext context, List dayDetails, String locale, ScrollController scrollController) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      itemCount: dayDetails.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = dayDetails[index];
        final subject = item['subject'] as Map<String, dynamic>;
        final chapter = item['chapter'] as Map<String, dynamic>;
        final topic = item['topic'] as Map<String, dynamic>;
        final scoreValue = item['score'];
        final score = (scoreValue is double)
            ? scoreValue.round()
            : (scoreValue is int)
            ? scoreValue
            : 0;

        final className = locale == 'uz' ? subject['class_name_uz'] : subject['class_name_ru'];
        final subjectName = locale == 'uz' ? subject['name_uz'] : subject['name_ru'];
        final fullSubjectName = '$className - $subjectName';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _getScoreColor(score).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      CupertinoIcons.book_fill,
                      size: 18,
                      color: _getScoreColor(score),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fullSubjectName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getScoreColor(score).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getScoreIcon(score),
                          size: 14,
                          color: _getScoreColor(score),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$score%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _getScoreColor(score),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.square_list,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            locale == 'uz' ? chapter['name_uz'] : chapter['name_ru'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.lightbulb,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            locale == 'uz' ? topic['name_uz'] : topic['name_ru'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month, String locale) {
    final monthNames = {
      'uz': [
        'Yanvar',
        'Fevral',
        'Mart',
        'Aprel',
        'May',
        'Iyun',
        'Iyul',
        'Avgust',
        'Sentyabr',
        'Oktyabr',
        'Noyabr',
        'Dekabr'
      ],
      'ru': [
        'Январь',
        'Февраль',
        'Март',
        'Апрель',
        'Май',
        'Июнь',
        'Июль',
        'Август',
        'Сентябрь',
        'Октябрь',
        'Ноябрь',
        'Декабрь'
      ],
    };

    return monthNames[locale]?[month - 1] ?? '';
  }

  Color _getScoreColor(int score) {
    if (score >= 80) {
      return CupertinoColors.systemGreen;
    } else if (score >= 60) {
      return CupertinoColors.systemOrange;
    } else {
      return CupertinoColors.systemRed;
    }
  }

  IconData _getScoreIcon(int score) {
    if (score >= 80) {
      return CupertinoIcons.checkmark_seal_fill;
    } else if (score >= 60) {
      return CupertinoIcons.star_fill;
    } else {
      return CupertinoIcons.exclamationmark_triangle_fill;
    }
  }

  Widget _buildMonthCalendar(DateTime month, String locale) {
    final weekDaysShort = locale == 'uz'
        ? ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya']
        : ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    final now = DateTime.now();
    final days = _getDaysInMonth(month);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Month name
        Text(
          '${_getMonthName(month.month, locale)} ${month.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        // Week days
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDaysShort.map((day) {
              return SizedBox(
                width: 42,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Calendar grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 4,
            runSpacing: 8,
            children: days.map((date) {
              if (date.year == 0) {
                return const SizedBox(width: 42, height: 42);
              }

              final isStudied = _isDayStudied(date);
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final isFuture = date.isAfter(now);

              return GestureDetector(
                onTap: () {
                  if (!isFuture) {
                    _showDayDetails(context, date, locale);
                  }
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: isFuture
                        ? LinearGradient(
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade300,
                      ],
                    )
                        : isStudied
                        ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CupertinoColors.systemGreen,
                        CupertinoColors.systemGreen.darkColor,
                      ],
                    )
                        : null,
                    color: !isFuture && !isStudied ? Colors.white : null,
                    border: isToday
                        ? Border.all(
                      color: CupertinoColors.activeBlue,
                      width: 2.5,
                    )
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isStudied && !isFuture
                        ? [
                      BoxShadow(
                        color: CupertinoColors.systemGreen.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                        : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isStudied && !isFuture
                        ? const Icon(
                      CupertinoIcons.checkmark,
                      color: Colors.white,
                      size: 18,
                    )
                        : Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                        color: isFuture
                            ? Colors.grey.shade500
                            : isToday
                            ? CupertinoColors.activeBlue
                            : const Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale ?? 'uz';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  locale == 'uz' ? 'Oylik faollik' : 'Активность за месяц',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CupertinoActivityIndicator(),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Calendar container - Perfect size!
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.blue.shade50.withOpacity(0.4),
                    Colors.purple.shade50.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: errorType != null
                  ? _buildErrorState(locale)
                  : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 340,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: currentPageIndex + 1, // Prevent going to future months
                    onPageChanged: (index) {
                      final newMonth = _getMonthFromPageIndex(index);
                      if (newMonth.year != selectedMonth.year ||
                          newMonth.month != selectedMonth.month) {
                        setState(() {
                          selectedMonth = newMonth;
                        });
                        _fetchMonthlyStats();
                      }
                    },
                    itemBuilder: (context, index) {
                      final month = _getMonthFromPageIndex(index);
                      return _buildMonthCalendar(month, locale);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String locale) {
    return SizedBox(
      height: 340,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red.shade400,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              errorType == 'notLoaded'
                  ? (locale == 'uz' ? 'Ma\'lumot yuklanmadi' : 'Данные не загружены')
                  : (locale == 'uz' ? 'Xatolik yuz berdi' : 'Произошла ошибка'),
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              onPressed: _fetchMonthlyStats,
              child: Text(
                locale == 'uz' ? 'Qayta urinish' : 'Повторить',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}