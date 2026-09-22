import 'dart:ui' as ui;

import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:image/image.dart' as IMG;

import '../../../../generated/assets.dart';

class LocationMarkerPainter {
  static Future<Uint8List> defaultMarker(BuildContext context,
      {String imagePath = Assets.pngIcFood}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(64, 64);
    final fillPaint = Paint()
      ..color = context.color.scaffoldBackGroundColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = context.color.bg1
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final circleOffset = Offset(size.height / 2, size.width / 2);
    final imageOffset = Offset(size.height / 2 - 12, size.width / 2 - 12);

    canvas.drawCircle(circleOffset, size.height / 2, fillPaint);
    canvas.drawCircle(circleOffset, size.height / 2, strokePaint);
    final path = Path()
      ..addOval(
        Rect.fromCenter(
          center: circleOffset,
          width: size.width + 4,
          height: size.height + 4,
        ),
      );
    canvas.drawShadow(
        path, context.color.blackWhiteColor.withOpacity(0.1), 1, true);

    // final centerImage = await _loadImage(imagePath);

    // canvas.drawImage(
    //   centerImage,
    //   imageOffset,
    //   Paint(),
    // );

    final image = await recorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  static Future<Uint8List> selectedMarker(BuildContext context,
      {String imagePath = Assets.pngIcFood}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final circlePaint = Paint()
      ..color = context.color.homeButtonsColor
      ..style = PaintingStyle.fill;
    final rectanglePaint = Paint()
      ..color = context.color.homeButtonsColor
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = context.color.bg1
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final trianglePaint = Paint()
      ..color = context.color.bg1
      ..style = PaintingStyle.fill;
    final path = Path();
    const scale = 2.5;
    const double imageSize = 24;
    const scaleForMovingPivotPoint = 1.77;
    const triangleSide = 10;
    const Offset rectangleStartOffset = Offset(0, 3);
    const size = Size(
      scale * scaleForMovingPivotPoint * 130,
      scale * scaleForMovingPivotPoint * 30,
    );
    final Offset textOffset = Offset(
        (size.width / scaleForMovingPivotPoint) * 0.06,
        (size.height / scaleForMovingPivotPoint) * 0.11);
    final Offset starOffset = Offset(
        (size.width / scaleForMovingPivotPoint) * 0.06,
        (size.height / scaleForMovingPivotPoint) * 0.5);
    final Offset secondTextOffset = Offset(
      size.width / scaleForMovingPivotPoint * 0.14,
      size.height / scaleForMovingPivotPoint * 0.52,
    );
    const double circleRadius = scale * 15;
    const double rectangleAndCircleOffset = scale * 3;
    const double rectangleRadius = scale * 10;
    final circleCenterOffset = Offset(
        (size.width / scaleForMovingPivotPoint) - circleRadius,
        (size.height / scaleForMovingPivotPoint) / 2);
    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rectangleStartOffset.dx,
        rectangleStartOffset.dy,
        (size.width / scaleForMovingPivotPoint) - circleRadius,
        (size.height / scaleForMovingPivotPoint) - rectangleAndCircleOffset,
      ),
      const Radius.circular(rectangleRadius),
    );
    path.moveTo(
      (size.width / scaleForMovingPivotPoint) - circleRadius - (triangleSide),
      (size.height / scaleForMovingPivotPoint) - 2,
    );
    path.lineTo(
      (size.width / scaleForMovingPivotPoint) - circleRadius + (triangleSide),
      (size.height / scaleForMovingPivotPoint) - 2,
    );
    path.lineTo(
      (size.width / scaleForMovingPivotPoint) - circleRadius,
      (size.height / scaleForMovingPivotPoint) + triangleSide,
    );
    // final centerImage = await _loadImage(imagePath);
    // final starImage = await _loadImage(
    //   Assets.pngIcStar,
    //   width: 18,
    //   height: 18,
    // );
    path.close();
    canvas.drawRRect(rRect, rectanglePaint);
    canvas.drawRRect(rRect, strokePaint);
    canvas.drawPath(path, trianglePaint);
    canvas.drawCircle(circleCenterOffset, circleRadius, circlePaint);
    // canvas.drawImage(
    //   centerImage,
    //   circleCenterOffset.translate(-(imageSize / 2), -(imageSize / 2)),
    //   Paint(),
    // );
    // canvas.drawImage(starImage, starOffset, Paint());
    canvas.drawCircle(circleCenterOffset, circleRadius, strokePaint);
    drawText(
      textStyle: context.textStyle.fontSize20FontWeight700,
      color: context.color.primaryColor1,
      text: "Грузинский дворик",
      textOffset: textOffset,
      canvas: canvas,
      maxWidth:
          size.width / scaleForMovingPivotPoint - circleRadius - textOffset.dx,
    );
    drawText(
      textStyle: context.textStyle.fontSize14FontWeight400,
      color: context.color.textColor,
      text: "4,1  Ср.чек выше среднего",
      textOffset: secondTextOffset,
      canvas: canvas,
      maxWidth: size.width / scaleForMovingPivotPoint -
          circleRadius -
          secondTextOffset.dx,
    );

    final image = await recorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  static void drawText({
    required TextStyle textStyle,
    required Color color,
    required String text,
    required Offset textOffset,
    required Canvas canvas,
    required double maxWidth,
  }) {
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(color: color),
      ),
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: maxWidth,
    );
    textPainter.paint(
      canvas,
      textOffset,
    );
  }

  // static Future<ui.Image> _loadImage(String imagePath,
  //     {int width = 24, int height = 24}) async {
  //   ByteData data = await rootBundle.load(imagePath);
  //   IMG.Image newImage = IMG.decodeImage(data.buffer.asUint8List())!;
  //   IMG.Image adjustColor =
  //       IMG.colorOffset(newImage, red: 186, green: 71, blue: 35);
  //   IMG.Image resizedImage = IMG.copyResize(
  //     adjustColor,
  //     width: width,
  //     height: height,
  //   );
  //   Uint8List resizedImageBytes = IMG.encodePng(resizedImage);
  //   ui.Image centerImage =
  //       await decodeImageFromList(resizedImageBytes.buffer.asUint8List());
  //   return centerImage;
  // }
}
