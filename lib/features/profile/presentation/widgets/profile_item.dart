import 'dart:math';

import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/app_utils.dart';
import '../../../../generated/assets.dart';

class ProfileItem extends StatelessWidget {
  final String iconUrl;
  final String title;
  final VoidCallback? onTap;

  const ProfileItem(
      {Key? key, required this.iconUrl, required this.title, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppUtils.kBorderRadius6,
        onTap: onTap,
        child: Ink(
          height: 28,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Ink(
                      width: 28,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.transparent
                            : context.color.homeButtonsColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: SvgPicture.asset(
                            iconUrl,
                            fit: BoxFit.scaleDown,
                            color: isDark
                                ? context.color.white
                                : context.color.primaryColor1,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Text(
                      title,
                      style: context.textStyle.fontSize16FontWeight500.copyWith(
                        color: context.color.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                SizedBox(
                  height: 16,
                  width: 16,
                  child: SvgPicture.asset(
                    Assets.svgAngelRight,
                    color: context.color.blackWhiteColor.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
