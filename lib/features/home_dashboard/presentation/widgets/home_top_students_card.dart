import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/features/home_dashboard/data/models/rating_model.dart';
import 'package:my_flutter_template/features/home_dashboard/presentation/blocs/home_dashboard/home_dashboard_bloc.dart';

const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF64748B);
const Color _kPrimary = Color(0xFF2563EB);

const List<Color> _rankColors = [
  Color(0xFFF59E0B), // 1-oltin
  Color(0xFF94A3B8), // 2-kumush
  Color(0xFFC2793B), // 3-bronza
];

class HomeTopStudentsCard extends StatelessWidget {
  final String locale;

  const HomeTopStudentsCard({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardBloc, HomeDashboardState>(
      buildWhen: (previous, current) => previous.rating != current.rating,
      builder: (context, state) {
        final category = state.rating?.score;
        final top3 = category?.top3 ?? const <RatingEntryModel>[];

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
                  const Icon(Icons.emoji_events_rounded,
                      size: 18, color: _kPrimary),
                  const SizedBox(width: 8),
                  Text(
                    locale == 'ru' ? 'Лучшие ученики' : "Top o'quvchilar",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _kInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (top3.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    locale == 'ru' ? 'Пока нет данных' : "Hozircha ma'lumot yo'q",
                    style: const TextStyle(fontSize: 12.5, color: _kMuted),
                  ),
                )
              else
                ...List.generate(top3.length, (index) {
                  final entry = top3[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _rankColors[index.clamp(0, 2)],
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: _kPrimary.withOpacity(0.1),
                          child: Text(
                            entry.fullName.isNotEmpty
                                ? entry.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kInk,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _kPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              if (category?.myRank != null) ...[
                const Divider(height: 20),
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: _kPrimary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${category!.myRank}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _kPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      locale == 'ru' ? 'Вы' : 'Siz',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${category.myValue}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _kPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
