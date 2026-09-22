import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppbarLeadingWidget extends StatelessWidget {
  final bool withBackground;
  final Color? backGroundColor;
  final String? iconName;
  final VoidCallback? onTap;
  final Color? iconColor;

  const AppbarLeadingWidget({
    super.key,
    this.withBackground = true,
    this.backGroundColor,
    this.iconName,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        height: 36,
        width: 36,
        child: FilledButton(
          onPressed: onTap ??
              () {
                Navigator.pop(context);
              },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              withBackground
                  ? backGroundColor ?? context.color.scaffoldBackGroundColor
                  : Colors.transparent,
            ),
            padding: MaterialStateProperty.all(
              EdgeInsets.zero,
            ),
          ),
          child: SvgPicture.asset(
            iconName ?? Assets.svgArrowLeft,
            color: iconColor ?? context.color.blackWhiteColor,
            height: 20,
            width: 20,
          ),
        ),
      ),
    );
  }
}
