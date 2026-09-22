import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/app_utils.dart';

class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthLayout({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppUtils.kPaddingHorizontal16,
      children: [
        const Gap(133 - 56),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textStyle.fontSize20FontWeight700,
        ),
        const Gap(20),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: context.textStyle.fontSize16FontWeight500.copyWith(
            color: context.color.secondaryColor,
          ),
        ),
        child,
      ],
    );
  }
}
