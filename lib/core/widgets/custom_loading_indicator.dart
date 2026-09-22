import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;

  const CustomLoadingIndicator({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return SpinKitSpinningLines(
      itemCount: 1,
      lineWidth: 4,
      duration: const Duration(milliseconds: 750),
      color: color ?? context.color.accentColor,
      size: size ?? 50,
    );
  }
}
