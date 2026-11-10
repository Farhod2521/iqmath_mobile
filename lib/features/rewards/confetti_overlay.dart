import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tug'ilgan kundagidek konfetti: yuqoridan ikki chetdan otilib, aylanib tushadi.
/// Paketsiz — CustomPainter. Bosishlarni to'smaydi (IgnorePointer).
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, this.count = 140, this.duration = const Duration(milliseconds: 3200)});

  final int count;
  final Duration duration;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _Piece {
  _Piece(math.Random r, bool fromLeft)
      : x = fromLeft ? -0.02 : 1.02,
        y = 0.35 + r.nextDouble() * 0.15,
        vx = (fromLeft ? 1 : -1) * (0.25 + r.nextDouble() * 0.55),
        vy = -(0.9 + r.nextDouble() * 0.7),
        rot = r.nextDouble() * math.pi * 2,
        vr = (r.nextDouble() - 0.5) * 14,
        w = 6 + r.nextDouble() * 6,
        h = 3 + r.nextDouble() * 4,
        delay = r.nextDouble() * 0.18,
        round = r.nextDouble() < 0.25,
        color = _colors[r.nextInt(_colors.length)];

  static const _colors = [
    Color(0xFF1D6BFF),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFA855F7),
    Color(0xFF06B6D4),
    Color(0xFFFACC15),
  ];

  final double x, y, vx, vy, rot, vr, w, h, delay;
  final bool round;
  final Color color;
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration)..forward();
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    _pieces = List.generate(widget.count, (i) => _Piece(r, i.isEven));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Animatsiyani kamaytirish yoqilgan bo'lsa — konfetti chizilmaydi
    if (MediaQuery.of(context).disableAnimations) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, _c.value, widget.duration.inMilliseconds / 1000),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.progress, this.seconds);

  final List<_Piece> pieces;
  final double progress;
  final double seconds;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in pieces) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0) * seconds;
      if (t <= 0) continue;
      // Oddiy fizika: boshlang'ich tezlik + tortishish + havo qarshiligi
      final drag = math.exp(-0.9 * t);
      final x = p.x + p.vx * (1 - drag) / 0.9;
      final y = p.y + p.vy * (1 - drag) / 0.9 + 0.55 * t * t * 0.5;
      if (y > 1.1) continue;
      final opacity = progress > 0.8 ? (1 - progress) / 0.2 : 1.0;
      paint.color = p.color.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(p.rot + p.vr * t);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.h / 1.4, paint);
      } else {
        // "Qog'oz" aylanayotgandek: eni sinus bilan o'zgaradi
        final squash = math.cos(t * 9 + p.rot).abs();
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.w, height: p.h * (0.3 + squash)), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
