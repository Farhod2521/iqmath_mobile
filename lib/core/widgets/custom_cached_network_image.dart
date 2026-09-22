import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';

import '../utils/app_utils.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BorderRadius borderRadius;
  final double height;
  final double width;
  final String? errorImageUrl;
  final AlignmentGeometry? alignment;
  final bool withDecoration;
  final EdgeInsets margin;
  final BoxFit? fit;
  final Widget? errorWidget;

  const CustomCachedNetworkImage({
    Key? key,
    this.borderRadius = const BorderRadius.all(AppUtils.kRadius8),
    required this.imageUrl,
    this.height = double.maxFinite,
    this.width = double.maxFinite,
    this.errorImageUrl,
    this.alignment,
    this.withDecoration = true,
    this.margin = EdgeInsets.zero,
    this.fit,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: withDecoration
          ? BoxDecoration(
              borderRadius: borderRadius,
              color: context.color.bg1,
              boxShadow: [
                BoxShadow(
                  color: context.color.bg1,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(1, 3), // changes position of shadow
                ),
              ],
            )
          : null,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          imageBuilder: (context, imageProvider) {
            Image image = Image(
              image: imageProvider,
            );
            if ((image.height ?? 0) > (image.width ?? 0)) {
              return Image(
                image: imageProvider,
                fit: fit ?? BoxFit.fitHeight,
              );
            } else {
              return Image(
                image: imageProvider,
                fit: fit ?? BoxFit.fitWidth,
              );
            }
          },
          // imageBuilder: (context, imageProvider) {
          //   Image image = Image(
          //     image: imageProvider,
          //   );
          //   Completer<ui.Image> completer = Completer<ui.Image>();
          //   image.image.resolve(const ImageConfiguration()).addListener(
          //         ImageStreamListener(
          //           (ImageInfo info, bool _) => completer.complete(info.image),
          //         ),
          //       );
          //   return FutureBuilder(
          //     future: completer.future,
          //     builder:
          //         (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
          //       if (snapshot.hasData) {
          //         return Image(
          //           image: imageProvider,
          //           fit: fit,
          //         );
          //       } else if (snapshot.hasError) {
          //         return Icon(
          //           Icons.error_outline_rounded,
          //           size: height,
          //           // color: context.color.danger,
          //         );
          //       } else {
          //         return const Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       }
          //     },
          //   );
          // },
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.color.accentColor,
                ),
              ),
            );
          },
          height: height,
          errorWidget: (_, __, ___) {
            return errorWidget ??
                Icon(
                  Icons.error_outline_rounded,
                  size: height,
                  color: context.color.blackWhiteColor,
                );
          },
        ),
      ),
    );
  }
}
