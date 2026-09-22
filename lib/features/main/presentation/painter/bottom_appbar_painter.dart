import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/cupertino.dart';

class BottomAppBarPainter extends CustomPainter {
  final BuildContext context;

  BottomAppBarPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.5000000, size.height * 0.5512821);
    path.cubicTo(
        size.width * 0.5508107,
        size.height * 0.5512821,
        size.width * 0.5920000,
        size.height * 0.3532538,
        size.width * 0.5920000,
        size.height * 0.1089744);
    path.cubicTo(size.width * 0.5920000, size.height * 0.05312295,
        size.width * 0.6004693, 0, size.width * 0.6120853, 0);
    path.lineTo(size.width * 0.9306667, 0);
    path.cubicTo(size.width * 0.9689573, 0, size.width, size.height * 0.1492385,
        size.width, size.height * 0.3333333);
    path.lineTo(size.width, size.height * 0.8717949);
    path.cubicTo(size.width, size.height * 0.9426013, size.width * 0.9880613,
        size.height, size.width * 0.9733333, size.height);
    path.lineTo(size.width * 0.02666664, size.height);
    path.cubicTo(size.width * 0.01193904, size.height, 0,
        size.height * 0.9426013, 0, size.height * 0.8717949);
    path.lineTo(0, size.height * 0.3333333);
    path.cubicTo(0, size.height * 0.1492385, size.width * 0.03104160, 0,
        size.width * 0.06933333, 0);
    path.lineTo(size.width * 0.3879147, 0);
    path.cubicTo(
        size.width * 0.3995307,
        0,
        size.width * 0.4080000,
        size.height * 0.05312295,
        size.width * 0.4080000,
        size.height * 0.1089744);
    path.cubicTo(
        size.width * 0.4080000,
        size.height * 0.3532538,
        size.width * 0.4491893,
        size.height * 0.5512821,
        size.width * 0.5000000,
        size.height * 0.5512821);
    path.close();

    Paint paint = Paint()..style = PaintingStyle.fill;
    paint.color = context.color.bg1;
    canvas.translate(0, -2);
    canvas.drawShadow(path, context.color.blackWhiteColor.withOpacity(0.2), 1, true);
    canvas.translate(0, 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
