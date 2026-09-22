import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/features/home_dashboard/presentation/blocs/home_dashboard/home_dashboard_bloc.dart';

const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF64748B);
const Color _kPrimary = Color(0xFF2563EB);
const Color _kStreak = Color(0xFFF97316);

class HomeCalendarCard extends StatelessWidget {
  final String locale;

  const HomeCalendarCard({super.key, required this.locale});

  static const _monthsUz = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
  ];
  static const _monthsRu = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];
  static const _weekLettersUz = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
  static const _weekLettersRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardBloc, HomeDashboardState>(
      buildWhen: (previous, current) =>
          previous.calendarMonth != current.calendarMonth ||
          previous.calendarStatus != current.calendarStatus ||
          previous.studyStats != current.studyStats,
      builder: (context, state) {
        final month = state.calendarMonth;
        final now = DateTime.now();
        final completedDays = <int>{
          for (final day in state.studyStats?.results ?? [])
            if (day.completed &&
                day.date.year == month.year &&
                day.date.month == month.month)
              day.date.day,
        };

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E1A4C).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      size: 18, color: _kPrimary),
                  const SizedBox(width: 8),
                  Text(
                    locale == 'ru' ? 'Календарь' : "O'quv taqvimi",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _kInk,
                    ),
                  ),
                  const Spacer(),
                  _navButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => context.read<HomeDashboardBloc>().add(
                          ChangeCalendarMonthEvent(
                            DateTime(month.year, month.month - 1, 1),
                          ),
                        ),
                  ),
                  const SizedBox(width: 4),
                  _navButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => context.read<HomeDashboardBloc>().add(
                          ChangeCalendarMonthEvent(
                            DateTime(month.year, month.month + 1, 1),
                          ),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${locale == 'ru' ? _monthsRu[month.month - 1] : _monthsUz[month.month - 1]} ${month.year}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kMuted,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: (locale == 'ru' ? _weekLettersRu : _weekLettersUz)
                    .map(
                      (letter) => Expanded(
                        child: Center(
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _kMuted,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 6),
              ..._buildWeeks(month, now, completedDays),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildWeeks(DateTime month, DateTime now, Set<int> completedDays) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // DateTime.weekday: 1=Dushanba ... 7=Yakshanba -> hafta Dushanbadan boshlanadi
    final leadingEmpty = firstDay.weekday - 1;

    final cells = <int?>[
      ...List.filled(leadingEmpty, null),
      for (var day = 1; day <= daysInMonth; day++) day,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      final week = cells.sublist(i, i + 7);
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: week.map((day) {
              if (day == null) {
                return const Expanded(child: SizedBox(height: 32));
              }
              final isToday = now.year == month.year &&
                  now.month == month.month &&
                  now.day == day;
              final isCompleted = completedDays.contains(day);

              return Expanded(
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isToday
                          ? _kPrimary
                          : isCompleted
                              ? _kStreak.withOpacity(0.12)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? Colors.white
                            : isCompleted
                                ? _kStreak
                                : _kInk,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
    return rows;
  }

  Widget _navButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5FB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: _kMuted),
      ),
    );
  }
}
