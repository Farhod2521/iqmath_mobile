import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ota-ona va o'qituvchi (tutor) panellari uchun umumiy dizayn to'plami.
/// Ranglar va o'lchamlar saytdagi (iqmath.uz) mobil ko'rinish bilan bir xil.
class DashColors {
  static const ink = Color(0xFF0F172A);
  static const navy = Color(0xFF0B1B3F);
  static const text = Color(0xFF334155);
  static const muted = Color(0xFF64748B);
  static const subtle = Color(0xFF94A3B8);
  static const line = Color(0xFFEEF1F6);
  static const track = Color(0xFFEDF1F8);
  static const bg = Color(0xFFF5F8FE);
  static const primary = Color(0xFF2563EB);
  static const primarySoft = Color(0xFFEAF1FF);
  static const green = Color(0xFF16A34A);
  static const greenSoft = Color(0xFFDCFCE7);
  static const red = Color(0xFFDC2626);
  static const redSoft = Color(0xFFFEE2E2);
  static const purple = Color(0xFF7C3AED);
  static const purpleSoft = Color(0xFFF1EBFF);
  static const amber = Color(0xFFF59E0B);
  static const amberSoft = Color(0xFFFFF6E0);
}

/// `{{name}}` ko'rinishidagi o'rinlarni almashtiradi.
String fillArgs(String text, [Map<String, Object?> args = const {}]) {
  var out = text;
  args.forEach((key, value) => out = out.replaceAll('{{$key}}', '${value ?? ''}'));
  return out;
}

/// API'dan kelgan `name_uz` / `name_ru` maydonlaridan tilga mosini oladi.
String pickLang(Map? obj, String field, String locale) {
  if (obj == null) return '';
  final uz = obj['${field}_uz'];
  final ru = obj['${field}_ru'];
  final value = locale == 'ru' ? (ru ?? uz) : uz;
  return value == null ? '' : '$value';
}

int asInt(dynamic value) => value is num ? value.round() : int.tryParse('${value ?? ''}') ?? 0;

num asNum(dynamic value) => value is num ? value : num.tryParse('${value ?? ''}') ?? 0;

List<Map<String, dynamic>> asMapList(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

Map<String, dynamic> asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

String _two(int v) => v.toString().padLeft(2, '0');

DateTime? parseDate(dynamic iso) => iso == null ? null : DateTime.tryParse('$iso')?.toLocal();

/// 17/09/2026
String fmtDate(dynamic iso) {
  final d = parseDate(iso);
  return d == null ? '—' : '${_two(d.day)}/${_two(d.month)}/${d.year}';
}

/// 17/09/2026 13:28
String fmtDateTime(dynamic iso) {
  final d = parseDate(iso);
  return d == null ? '—' : '${fmtDate(iso)} ${_two(d.hour)}:${_two(d.minute)}';
}

/// "Bugun 14:20" / "Kecha 18:30" / "12.09 10:45"
String fmtWhen(dynamic iso, String locale) {
  final d = parseDate(iso);
  if (d == null) return '';
  final time = '${_two(d.hour)}:${_two(d.minute)}';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  if (day == today) return '${locale == 'ru' ? 'Сегодня' : 'Bugun'} $time';
  if (day == today.subtract(const Duration(days: 1))) {
    return '${locale == 'ru' ? 'Вчера' : 'Kecha'} $time';
  }
  return '${_two(d.day)}.${_two(d.month)} $time';
}

/// 7480 -> "2 soat 4 daqiqa"
String fmtDuration(dynamic seconds, String locale) {
  final total = math.max(0, asNum(seconds).round());
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  if (locale == 'ru') return h > 0 ? '$h ч $m мин' : '$m мин';
  return h > 0 ? '$h soat $m daqiqa' : '$m daqiqa';
}

/// 299000 -> "299 000"
String fmtMoney(dynamic value) {
  final digits = asNum(value).round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// "998944180008" -> "+998 94 418 00 08"
String fmtPhone(dynamic phone) {
  final digits = '${phone ?? ''}'.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.length != 12) return '+$digits';
  return '+${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 8)} '
      '${digits.substring(8, 10)} ${digits.substring(10)}';
}

/// Fan rangi: nomiga qarab (algebra — binafsha, geometriya — yashil, matematika — ko'k)
Color subjectColor(String? name, [int index = 0]) {
  final value = (name ?? '').toLowerCase();
  if (value.contains('algebr') || value.contains('алгебр')) return DashColors.purple;
  if (value.contains('geometr') || value.contains('геометр')) return DashColors.green;
  if (value.contains('matemat') || value.contains('математ')) return DashColors.primary;
  const fallback = [
    DashColors.primary,
    DashColors.purple,
    DashColors.green,
    DashColors.amber,
    Color(0xFF0EA5E9),
  ];
  return fallback[index % fallback.length];
}

IconData subjectIcon(String? name) {
  final value = (name ?? '').toLowerCase();
  if (value.contains('algebr') || value.contains('алгебр')) return Icons.functions_rounded;
  if (value.contains('geometr') || value.contains('геометр')) return Icons.change_history_rounded;
  return Icons.calculate_rounded;
}

/// Natija foiziga qarab rang: 80+ yashil, 50+ ko'k, qolgani qizil
(Color, Color) scoreColors(num value) {
  if (value >= 80) return (DashColors.green, DashColors.greenSoft);
  if (value >= 50) return (DashColors.primary, DashColors.primarySoft);
  return (DashColors.red, DashColors.redSoft);
}

/* ------------------------------------------------------------------ */
/* Asosiy bloklar                                                     */
/* ------------------------------------------------------------------ */

/// Oq karta: yumaloq burchak, ingichka chegara, yumshoq soya
class DashCard extends StatelessWidget {
  const DashCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color = Colors.white,
    this.onTap,
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: DashColors.line),
        boxShadow: [
          BoxShadow(
            color: DashColors.ink.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: onTap == null
          ? body
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
                child: body,
              ),
            ),
    );
  }
}

/// Karta sarlavhasi: ikonka + nom + o'ng tomonda tugma
class CardTitle extends StatelessWidget {
  const CardTitle({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = DashColors.primary,
    this.sub,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Color iconColor;
  final String? sub;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: title,
                children: [
                  if (sub != null)
                    TextSpan(
                      text: ' $sub',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF8A93A6)),
                    ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, height: 1.2, fontWeight: FontWeight.w800, color: DashColors.ink),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// "Barchasini ko'rish →"
class LinkButton extends StatelessWidget {
  const LinkButton({super.key, required this.label, required this.onTap, this.color = DashColors.primary});

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 3),
            Icon(Icons.arrow_forward_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

/// Kichik rangli belgi ("Faol", "11-sinf", "+5%")
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.text,
    required this.color,
    required this.background,
    this.icon,
    this.dot = false,
    this.fontSize = 11,
  });

  final String text;
  final Color color;
  final Color background;
  final IconData? icon;
  final bool dot;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[Icon(icon, size: fontSize + 2, color: color), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// O'sish/tushish belgisi: ▲ +5% (yashil) yoki ▼ -3% (qizil)
class DeltaBadge extends StatelessWidget {
  const DeltaBadge({super.key, required this.value, this.suffix = ''});

  final num? value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    final up = value! >= 0;
    return Pill(
      text: '${up ? '+' : ''}${value!.round()}$suffix',
      icon: up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
      color: up ? DashColors.green : DashColors.red,
      background: up ? DashColors.greenSoft : DashColors.redSoft,
    );
  }
}

const _avatarTones = [
  [Color(0xFF60A5FA), Color(0xFF2563EB)],
  [Color(0xFF38BDF8), Color(0xFF0369A1)],
  [Color(0xFF818CF8), Color(0xFF3B5BDB)],
  [Color(0xFF3B82F6), Color(0xFF1E40AF)],
  [Color(0xFF22D3EE), Color(0xFF2563EB)],
];

String initialsOf(String? name) {
  final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2);
  final letters = parts.map((p) => p.characters.first.toUpperCase()).join();
  return letters.isEmpty ? '?' : letters;
}

/// Ism bosh harflari bilan dumaloq avatar (rang ismga qarab — har safar bir xil)
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 48, this.ring = true});

  final String? name;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final hash = (name ?? '').codeUnits.fold<int>(0, (sum, c) => sum + c);
    final tone = _avatarTones[hash % _avatarTones.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: tone),
        border: ring ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: [
          BoxShadow(color: tone[1].withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Rangli ikonka qutisi
class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    this.size = 48,
    this.radius = 16,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}

/// Statistika kartasi: ikonka, nom, katta raqam, o'zgarish va izoh
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.soft,
    required this.label,
    required this.value,
    this.delta,
    this.deltaSuffix = '',
    this.footer,
    this.footerWidget,
    this.glass = false,
  });

  final IconData icon;
  final Color color;
  final Color soft;
  final String label;
  final String value;
  final num? delta;
  final String deltaSuffix;
  final String? footer;
  final Widget? footerWidget;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: glass ? Colors.white.withValues(alpha: 0.88) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: glass ? Colors.white.withValues(alpha: 0.7) : DashColors.line),
        boxShadow: [
          BoxShadow(color: DashColors.ink.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBox(icon: icon, color: color, background: soft, size: 38, radius: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, height: 1.2, fontWeight: FontWeight.w600, color: DashColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: DashColors.navy),
                  ),
                ),
              ),
              if (delta != null) ...[const SizedBox(width: 6), DeltaBadge(value: delta, suffix: deltaSuffix)],
            ],
          ),
          if (footerWidget != null)
            Padding(padding: const EdgeInsets.only(top: 2), child: footerWidget!)
          else if (footer != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                footer!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8A93A6)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ikki ustunli to'r (kartalar balandligi qatorda tenglashadi)
class TwoColumnGrid extends StatelessWidget {
  const TwoColumnGrid({super.key, required this.children, this.gap = 10});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              SizedBox(width: gap),
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
            ],
          ),
        ),
      );
      if (i + 2 < children.length) rows.add(SizedBox(height: gap));
    }
    return Column(children: rows);
  }
}

class EmptyNote extends StatelessWidget {
  const EmptyNote({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconBox(icon: icon!, color: DashColors.primary, background: DashColors.primarySoft, size: 52, radius: 26),
              const SizedBox(height: 10),
            ],
            Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF8A93A6))),
          ],
        ),
      ),
    );
  }
}

/// Ingichka progress chizig'i
class ProgressLine extends StatelessWidget {
  const ProgressLine({super.key, required this.percent, required this.color, this.height = 8, this.track = DashColors.track});

  final num percent;
  final Color color;
  final double height;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final value = (percent.clamp(0, 100)) / 100;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(color: track),
            FractionallySizedBox(
              widthFactor: value.toDouble(),
              child: Container(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Halqa ko'rinishidagi foiz (o'rtasida qiymat)
class PercentRing extends StatelessWidget {
  const PercentRing({
    super.key,
    required this.percent,
    required this.color,
    this.size = 46,
    this.stroke = 5,
    this.fontSize = 11,
  });

  final num percent;
  final Color color;
  final double size;
  final double stroke;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(percent.toDouble(), color, stroke),
        child: Center(
          child: Text(
            '${percent.round()}%',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: DashColors.ink),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.percent, this.color, this.stroke);

  final double percent;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(stroke / 2, stroke / 2) & Size(size.width - stroke, size.height - stroke);
    final base = Paint()
      ..color = const Color(0xFFE6EDFB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    final sweep = math.pi * 2 * (percent.clamp(0, 100) / 100);
    if (sweep <= 0) return;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.percent != percent || old.color != color || old.stroke != stroke;
}

/* ------------------------------------------------------------------ */
/* Grafiklar                                                          */
/* ------------------------------------------------------------------ */

class RadarItem {
  const RadarItem(this.label, this.percent);

  final String label;
  final num percent;
}

/// Radar (o'rgimchak to'ri) diagramma — 3 va undan ko'p fan/bob uchun
class RadarChart extends StatelessWidget {
  const RadarChart({super.key, required this.items, this.height = 250});

  final List<RadarItem> items;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _RadarPainter(items, DefaultTextStyle.of(context).style)),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.items, this.base);

  final List<RadarItem> items;
  final TextStyle base;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.length < 3) return;
    final radius = math.min(size.width * 0.27, size.height * 0.33);
    // Uchburchakda pastki qism bo'sh qolmasligi uchun markaz biroz pastga suriladi
    final center = Offset(size.width / 2, size.height / 2 + (items.length == 3 ? radius * 0.22 : 0));
    double angle(int i) => -math.pi / 2 + i * 2 * math.pi / items.length;
    Offset point(int i, double r) => center + Offset(r * math.cos(angle(i)), r * math.sin(angle(i)));

    final grid = Paint()
      ..color = const Color(0xFFE5EAF2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final k in [0.33, 0.66, 1.0]) {
      final path = Path()..moveTo(point(0, radius * k).dx, point(0, radius * k).dy);
      for (var i = 1; i < items.length; i++) {
        path.lineTo(point(i, radius * k).dx, point(i, radius * k).dy);
      }
      canvas.drawPath(path..close(), grid);
    }
    for (var i = 0; i < items.length; i++) {
      canvas.drawLine(center, point(i, radius), grid);
    }

    final shape = Path();
    for (var i = 0; i < items.length; i++) {
      final p = point(i, radius * (items[i].percent.clamp(0, 100) / 100));
      i == 0 ? shape.moveTo(p.dx, p.dy) : shape.lineTo(p.dx, p.dy);
    }
    shape.close();
    canvas.drawPath(shape, Paint()..color = DashColors.primary.withValues(alpha: 0.16));
    canvas.drawPath(
      shape,
      Paint()
        ..color = DashColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < items.length; i++) {
      final p = point(i, radius * (items[i].percent.clamp(0, 100) / 100));
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.6, Paint()..color = DashColors.primary);

      final labelPoint = point(i, radius + 16);
      final label = items[i].label.length > 18 ? '${items[i].label.substring(0, 17)}…' : items[i].label;
      final painter = TextPainter(
        text: TextSpan(children: [
          TextSpan(text: '$label\n', style: base.copyWith(fontSize: 10.5, height: 1.25, fontWeight: FontWeight.w500, color: const Color(0xFF475569))),
          TextSpan(
            text: '${items[i].percent.round()}%',
            style: base.copyWith(fontSize: 11.5, height: 1.25, fontWeight: FontWeight.w800, color: DashColors.primary),
          ),
        ]),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.3);
      var dx = labelPoint.dx - painter.width / 2;
      if (labelPoint.dx < center.dx - 8) dx = labelPoint.dx - painter.width;
      if (labelPoint.dx > center.dx + 8) dx = labelPoint.dx;
      var dy = labelPoint.dy - painter.height / 2;
      if (labelPoint.dy < center.dy - 8) dy = labelPoint.dy - painter.height + 4;
      if (labelPoint.dy > center.dy + 8) dy = labelPoint.dy - 4;
      dx = dx.clamp(0, size.width - painter.width);
      dy = dy.clamp(0, size.height - painter.height);
      painter.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.items != items;
}

class BarPoint {
  const BarPoint(this.label, this.value, {this.tip});

  final String label;
  final num value;
  final String? tip;
}

/// Ustunli grafik (o'quv faolligi) — ustunni bosganda qiymat ko'rinadi
class BarChart extends StatefulWidget {
  const BarChart({super.key, required this.points, this.height = 170, this.labelEvery = 5, this.unit = ''});

  final List<BarPoint> points;
  final double height;
  final int labelEvery;
  final String unit;

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final maxValue = points.fold<num>(4, (m, p) => math.max(m, p.value));
    final niceMax = (maxValue / 4).ceil() * 4;
    final ticks = [for (var i = 4; i >= 0; i--) niceMax * i ~/ 4];
    final selected = _selected != null && _selected! < points.length ? points[_selected!] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 22,
          child: selected == null
              ? null
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: DashColors.ink, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${selected.tip ?? selected.label}: ${selected.value}${widget.unit}',
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: widget.height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final t in ticks) Text('$t', style: const TextStyle(fontSize: 9.5, color: DashColors.subtle)),
                ],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [for (var i = 0; i < 5; i++) Container(height: 1, color: DashColors.line)],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < points.length; i++)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _selected = _selected == i ? null : i),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: points[i].value <= 0
                                      ? 0.0
                                      : math.max(0.03, points[i].value / niceMax).toDouble(),
                                  widthFactor: 0.72,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selected == i ? const Color(0xFF1D4ED8) : const Color(0xFF93B4FA),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ),
                                ),
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
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Row(
            children: [
              for (var i = 0; i < points.length; i++)
                Expanded(
                  child: Text(
                    widget.labelEvery <= 1 || i % widget.labelEvery == 0 ? points[i].label : '',
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 9.5, color: DashColors.subtle),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Chiziqli grafik (0–100%) — eng yuqori nuqta belgilanadi
class LineChart extends StatelessWidget {
  const LineChart({super.key, required this.values, required this.labels, this.height = 160, this.color = const Color(0xFF5D87FF)});

  final List<num> values;
  final List<String> labels;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final shown = labels.length > 3
        ? [labels.first, labels[(labels.length - 1) ~/ 2], labels.last]
        : labels;
    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _LinePainter(values, color, DefaultTextStyle.of(context).style)),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Row(
            mainAxisAlignment: shown.length == 1 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
            children: [for (final l in shown) Text(l, style: const TextStyle(fontSize: 10.5, color: Color(0xFF8A8A8E)))],
          ),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values, this.color, this.base);

  final List<num> values;
  final Color color;
  final TextStyle base;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 30.0;
    const top = 26.0;
    const bottom = 6.0;
    final width = size.width - left - 4;
    final height = size.height - top - bottom;
    double y(num v) => top + height - (v.clamp(0, 100) / 100) * height;

    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 1;
    for (final tick in [0, 25, 50, 75, 100]) {
      canvas.drawLine(Offset(left, y(tick)), Offset(size.width - 4, y(tick)), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$tick%', style: base.copyWith(fontSize: 9, color: const Color(0xFF8A8A8E))),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(left - 6 - tp.width, y(tick) - tp.height / 2));
    }
    if (values.isEmpty) return;

    final step = values.length > 1 ? width / (values.length - 1) : 0.0;
    final points = [for (var i = 0; i < values.length; i++) Offset(left + step * i, y(values[i]))];
    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    final area = Path.from(line)
      ..lineTo(points.last.dx, top + height)
      ..lineTo(points.first.dx, top + height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, top, size.width, height)),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    var peak = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[peak]) peak = i;
    }
    final p = points[peak];
    canvas.drawCircle(p, 5.5, Paint()..color = Colors.white);
    canvas.drawCircle(p, 4, Paint()..color = color);
    final label = TextPainter(
      text: TextSpan(
        text: '${values[peak].round()}%',
        style: base.copyWith(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final box = Rect.fromCenter(
      center: Offset(
        (p.dx).clamp(left + label.width / 2 + 6, size.width - label.width / 2 - 6),
        p.dy - 16,
      ),
      width: label.width + 12,
      height: label.height + 6,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(7)), Paint()..color = const Color(0xFF191C1D));
    label.paint(canvas, Offset(box.left + 6, box.top + 3));
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.values != values || old.color != color;
}

/* ------------------------------------------------------------------ */
/* Tanlov, tugmalar, oynalar                                          */
/* ------------------------------------------------------------------ */

class SelectOption<T> {
  const SelectOption(this.value, this.label);

  final T value;
  final String label;
}

/// Kichik "select" — bosilganda variantlar ro'yxati ochiladi
class MiniSelect<T> extends StatelessWidget {
  const MiniSelect({super.key, required this.value, required this.options, required this.onChanged, this.icon});

  final T value;
  final List<SelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final current = options.firstWhere((o) => o.value == value, orElse: () => options.first);
    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => [
        for (final o in options)
          PopupMenuItem<T>(
            value: o.value,
            height: 40,
            child: Text(
              o.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: o.value == value ? FontWeight.w800 : FontWeight.w500,
                color: o.value == value ? DashColors.primary : DashColors.ink,
              ),
            ),
          ),
      ],
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EAF2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 15, color: DashColors.muted), const SizedBox(width: 5)],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                current.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF191C1D)),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: Color(0xFF6B7385)),
          ],
        ),
      ),
    );
  }
}

/// To'liq kenglikdagi asosiy tugma
class DashButton extends StatelessWidget {
  const DashButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = DashColors.primary,
    this.textColor = Colors.white,
    this.loading = false,
    this.height = 46,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final bool loading;
  final double height;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null || loading;
    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: Material(
        color: outlined ? Colors.white : color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap!();
                },
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: outlined
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD7E2FF)),
                  )
                : null,
            alignment: Alignment.center,
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: textColor),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[Icon(icon, size: 18, color: textColor), const SizedBox(width: 7)],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Qidiruv maydoni
class DashSearchField extends StatelessWidget {
  const DashSearchField({super.key, required this.hint, required this.onChanged, this.controller});

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE3F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: DashColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: DashColors.ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 14, color: DashColors.subtle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Matn kiritish maydoni (oynalar ichida)
class DashTextField extends StatelessWidget {
  const DashTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixText,
    this.autofocus = false,
    this.inputFormatters,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? prefixText;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF191C1D))),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          autofocus: autofocus,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmitted,
          style: const TextStyle(fontSize: 14, color: DashColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            hintStyle: const TextStyle(color: DashColors.subtle),
            filled: true,
            fillColor: const Color(0xFFF8FAFD),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE3E8F1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: DashColors.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pastdan chiqadigan oyna (sarlavha, ikonka, kontent)
Future<T?> showDashSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  IconData icon = Icons.info_outline_rounded,
  Color iconColor = DashColors.primary,
  required Widget Function(BuildContext sheetContext) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.88),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    IconBox(icon: icon, color: iconColor, background: iconColor.withValues(alpha: 0.1), size: 42, radius: 14),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: DashColors.ink)),
                          if (subtitle != null && subtitle.isNotEmpty)
                            Text(subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, color: DashColors.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded, color: DashColors.muted),
                    ),
                  ],
                ),
              ),
              Flexible(child: builder(sheetContext)),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Tasdiqlash oynasi ("O'chirasizmi?")
Future<bool> confirmDash(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool danger = true,
  IconData icon = Icons.delete_outline_rounded,
}) async {
  final result = await showDashSheet<bool>(
    context,
    title: title,
    icon: icon,
    iconColor: danger ? DashColors.red : DashColors.primary,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: const TextStyle(fontSize: 14, height: 1.45, color: DashColors.text)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DashButton(
                  label: cancelLabel,
                  color: const Color(0xFFF1F4FF),
                  textColor: const Color(0xFF5A6A85),
                  onTap: () => Navigator.of(sheetContext).pop(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DashButton(
                  label: confirmLabel,
                  color: danger ? DashColors.red : DashColors.primary,
                  onTap: () => Navigator.of(sheetContext).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return result == true;
}

/// Rasm fonidagi banner (saytdagi "hero" bloki): chapdan oq gradient
class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.image,
    required this.child,
    this.alignment = const Alignment(0.6, 0),
    this.padding = const EdgeInsets.all(18),
    this.fade = const Color(0xFFEAF2FF),
  });

  final String image;
  final Widget child;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;
  final Color fade;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xFFDCE9FF))),
          Positioned.fill(child: Image.asset(image, fit: BoxFit.cover, alignment: alignment)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [fade, fade.withValues(alpha: 0.85), fade.withValues(alpha: 0.15)],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Sahifa sarlavhasi (orqaga tugmasi bilan yoki usiz)
class DashPageTitle extends StatelessWidget {
  const DashPageTitle({super.key, required this.title, this.subtitle, this.leading, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: DashColors.navy)),
              if (subtitle != null)
                Text(subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: DashColors.muted)),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

/// Yuklanish skeleti
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, required this.height, this.radius = 18, this.color = const Color(0xFFEDF1F8)});

  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

/// Xatolik holati + qayta urinish
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.retryLabel, required this.onRetry});

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          const IconBox(
              icon: Icons.wifi_off_rounded, color: DashColors.red, background: DashColors.redSoft, size: 60, radius: 30),
          const SizedBox(height: 14),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DashColors.muted)),
          const SizedBox(height: 14),
          DashButton(label: retryLabel, icon: Icons.refresh_rounded, onTap: onRetry, height: 42),
        ],
      ),
    );
  }
}
