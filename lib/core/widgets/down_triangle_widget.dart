import 'package:flutter/material.dart';

class DownTriangleWidget extends StatelessWidget {
  final Color color;

  const DownTriangleWidget({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      width: 5,
      child: CustomPaint(
        painter: _TrianglePainter(
          strokeColor: color,
          paintingStyle: PaintingStyle.fill,
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  _TrianglePainter(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 1,
      this.paintingStyle = PaintingStyle.fill});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..lineTo(x / 2, y)
      ..lineTo(x, 0)
      ..close();
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
