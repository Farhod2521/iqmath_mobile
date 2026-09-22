import 'dart:math';

import 'package:flutter/material.dart';

class SplashLogoPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  SplashLogoPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepAngle,
    required this.startAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;
    final double innerRadius = radius - strokeWidth;
    final double innerStartAngle = startAngle + 10;
    final double innerEndAngle = startAngle + sweepAngle - 10;
    final double innerSweepAngle = sweepAngle - 20;
    final double startAngleRadians = startAngle * (pi / 180);
    final double sweepAngleRadians = sweepAngle * (pi / 180);
    final double innerStartAngleRadians = innerStartAngle * (pi / 180);
    final double innerEndAngleRadians = innerEndAngle * (pi / 180);
    final double innerSweepAngleRadians = innerSweepAngle * (pi / 180);

    Offset innerStartPoint = Offset(
      center.dx + innerRadius * cos(innerEndAngleRadians),
      center.dy + innerRadius * sin(innerEndAngleRadians),
    );

    Offset innerEndPoint = Offset(
      center.dx + innerRadius * cos(innerStartAngleRadians),
      center.dy + innerRadius * sin(innerStartAngleRadians),
    );

    Offset outerStartPoint = Offset(
      center.dx + radius * cos(startAngleRadians),
      center.dy + radius * sin(startAngleRadians),
    );

    path.moveTo(outerStartPoint.dx, outerStartPoint.dy);

    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngleRadians,
      sweepAngleRadians,
      true,
    );

    path.lineTo(innerStartPoint.dx, innerStartPoint.dy);

    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      innerStartAngleRadians,
      innerSweepAngleRadians,
      true,
    );

    path.moveTo(innerEndPoint.dx, innerEndPoint.dy);

    path.lineTo(outerStartPoint.dx, outerStartPoint.dy);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
