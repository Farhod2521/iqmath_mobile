import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Fanlar va Diagnostika sahifalari uchun umumiy komponentlar —
// saytdagi `SubjectsStats.jsx` (StatsCard), `StatsCarousel.jsx`,
// `SectionHeader.jsx` va `subjectTheme.js` ning mobil ekvivalenti.

const Color kSubjectTitleColor = Color(0xFF0F1B3D);
const Color kSubjectMutedColor = Color(0xFF6B7385);
const Color kSubjectSubtleColor = Color(0xFF8A93A6);
const Color kSubjectTrackColor = Color(0xFFEDF0F5);
const Color kStatsCompletedColor = Color(0xFF2BC4A0);
const Color kStatsInProgressColor = Color(0xFFF5C26B);
const Color kStatsNotStartedColor = Color(0xFFCBD5E1);

/// Fan bo'limi ranglari: Matematika — ko'k, Algebra — binafsha,
/// Geometriya — moviy-yashil; boshqalari palitradan aylanib olinadi.
class SubjectTheme {
  final Color accent;
  final Color soft;

  const SubjectTheme(this.accent, this.soft);

  static const _math = SubjectTheme(Color(0xFF3B6FF6), Color(0xFFEAF0FF));
  static const _algebra = SubjectTheme(Color(0xFF8B5CF6), Color(0xFFF1EBFF));
  static const _geometry = SubjectTheme(Color(0xFF14A3B8), Color(0xFFE3F6F9));
  static const _fallback = [
    SubjectTheme(Color(0xFFF59E0B), Color(0xFFFFF4DE)),
    SubjectTheme(Color(0xFFEC4899), Color(0xFFFDE8F3)),
    SubjectTheme(Color(0xFF10B981), Color(0xFFE3F8EF)),
  ];

  static SubjectTheme of(String name, int index) {
    final key = name.toLowerCase();
    if (key.contains('algebra') || key.contains('алгебр')) return _algebra;
    if (key.contains('geometr') || key.contains('геометр')) return _geometry;
    if (key.contains('matem') || key.contains('матем')) return _math;
    return _fallback[index % _fallback.length];
  }
}

int subjectPercent(num part, num total) =>
    total > 0 ? math.min(100, (part * 100 / total).round()) : 0;

bool isGradeName(String? className) =>
    className != null && RegExp(r'^\d+$').hasMatch(className);

// ═══════════════════════════ Statistika karuseli ═══════════════════════════

/// Har bir karta to'liq kenglikda, 4 soniyada o'zi keyingisiga o'tadi
/// (oxiridan boshiga qaytadi); qo'l bilan surilsa 6 soniya to'xtab turadi.
class StatsCarousel extends StatefulWidget {
  final List<Widget> children;

  const StatsCarousel({super.key, required this.children});

  @override
  State<StatsCarousel> createState() => _StatsCarouselState();
}

class _StatsCarouselState extends State<StatsCarousel> {
  static const _interval = Duration(seconds: 4);
  static const _resumeDelay = Duration(seconds: 6);

  final PageController _controller = PageController();
  Timer? _timer;
  DateTime _pausedUntil = DateTime.fromMillisecondsSinceEpoch(0);
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_interval, (_) => _next());
  }

  void _next() {
    final count = widget.children.length;
    if (count < 2 || !_controller.hasClients) return;
    if (DateTime.now().isBefore(_pausedUntil)) return;
    _controller.animateToPage(
      (_active + 1) % count,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _pause() => _pausedUntil = DateTime.now().add(_resumeDelay);

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;
    // Karta balandligi sobit (PageView talabi); shrift kattalashtirilsa
    // ham sig'ishi uchun foydalanuvchi shrift masshtabiga ko'paytiriladi.
    final height = MediaQuery.textScalerOf(context).scale(330);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: Listener(
            onPointerDown: (_) => _pause(),
            child: PageView.builder(
              controller: _controller,
              itemCount: count,
              onPageChanged: (index) => setState(() => _active = index),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: widget.children[index],
              ),
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                GestureDetector(
                  onTap: () {
                    _pause();
                    _controller.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _active
                          ? const Color(0xFF3B6FF6)
                          : const Color(0xFFD5DBE5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class StatsLegendItem {
  final Color color;
  final String label;
  final num value;

  const StatsLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });
}

/// Umumiy statistika kartasi: progress doirasi, legenda va sinflar
/// kesimidagi ustunli diagramma (saytdagi StatsCard).
class SubjectStatsCard extends StatelessWidget {
  final String title;
  final SubjectTheme theme;
  final String gradesLabel;
  final int overall;
  final String overallLabel;
  final List<StatsLegendItem> legend;
  final List<({String label, int value})> grades;
  final String seeAllLabel;
  final VoidCallback onSeeAll;

  const SubjectStatsCard({
    super.key,
    required this.title,
    required this.theme,
    required this.gradesLabel,
    required this.overall,
    required this.overallLabel,
    required this.legend,
    required this.grades,
    required this.seeAllLabel,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF0F5)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.55],
          colors: [theme.soft.withValues(alpha: 0.6), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sarlavha: ikonka, nom, sinflar, "Barchasini ko'rish"
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SubjectIcon(name: title),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kSubjectTitleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      gradesLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: kSubjectMutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onSeeAll,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: theme.accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        seeAllLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: theme.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(CupertinoIcons.arrow_right,
                          size: 12, color: theme.accent),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress doirasi + legenda
          Row(
            children: [
              Column(
                children: [
                  _Donut(value: overall, color: theme.accent),
                  const SizedBox(height: 6),
                  Text(
                    overallLabel,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: kSubjectSubtleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < legend.length; i++) ...[
                      if (i > 0) const SizedBox(height: 9),
                      _LegendRow(item: legend[i]),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sinflar bo'yicha diagramma — qolgan joyni egallaydi
          Expanded(child: GradeBars(color: theme.accent, grades: grades)),
        ],
      ),
    );
  }
}

class SubjectIcon extends StatelessWidget {
  final String name;

  const SubjectIcon({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final key = name.toLowerCase();
    if (key.contains('geometr') || key.contains('геометр')) {
      return const Icon(Icons.change_history_rounded,
          size: 24, color: Colors.white);
    }
    final isAlgebra = key.contains('algebra') || key.contains('алгебр');
    return Text(
      isAlgebra ? 'f(x)' : '√x',
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: isAlgebra ? 17 : 19,
        fontStyle: isAlgebra ? FontStyle.italic : FontStyle.normal,
        color: Colors.white,
        height: 1,
      ),
    );
  }
}

class _Donut extends StatelessWidget {
  final int value;
  final Color color;

  const _Donut({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: CustomPaint(
        painter: RingPainter(value: value / 100, color: color, stroke: 8),
        child: Center(
          child: Text(
            '$value%',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: kSubjectTitleColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Foiz halqasi (doira); [gradient] berilsa — gradientli yoy.
class RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final double stroke;
  final Color track;
  final List<Color>? gradient;

  RingPainter({
    required this.value,
    required this.color,
    this.stroke = 8,
    this.track = const Color(0xFFEEF1F6),
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    final v = value.clamp(0.0, 1.0);
    if (v <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    if (gradient != null) {
      arc.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradient!,
      ).createShader(rect);
    } else {
      arc.color = color;
    }
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * v, false, arc);
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.value != value || old.color != color || old.gradient != gradient;
}

class _LegendRow extends StatelessWidget {
  final StatsLegendItem item;

  const _LegendRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF5B6478)),
          ),
        ),
        Text(
          '${item.value}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: kSubjectTitleColor,
          ),
        ),
      ],
    );
  }
}

/// Sinflar bo'yicha progress ustunlari; eng yuqorisi to'liq rangda
/// va foizi ustida ko'rsatiladi. Bo'sh sinf ham kamida 12% balandlikda.
class GradeBars extends StatelessWidget {
  final List<({String label, int value})> grades;
  final Color color;

  const GradeBars({super.key, required this.grades, required this.color});

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) return const SizedBox.shrink();
    final maxValue = grades.map((g) => g.value).reduce(math.max);
    final maxIndex = grades.indexWhere((g) => g.value == maxValue);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < grades.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const badgeSpace = 22.0;
                        final isTop = i == maxIndex && maxValue > 0;
                        final usable =
                            math.max(0.0, constraints.maxHeight - badgeSpace);
                        final barHeight =
                            usable * math.max(12, grades[i].value) / 100;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isTop)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '${grades[i].value}%',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Container(
                              width: 26,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: color.withValues(
                                    alpha: isTop
                                        ? 1
                                        : 0.3 + 0.55 * i / grades.length),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    grades[i].label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: kSubjectSubtleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Bo'lim sarlavhasi: rangli chiziq, nom va izoh.
class SubjectSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;

  const SubjectSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 5,
          height: 28,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kSubjectTitleColor,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12.5, color: kSubjectMutedColor),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
