import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SliverItem extends StatelessWidget {
  final String title;
  final String? mediumCheck;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget child;

  const SliverItem({
    super.key,
    required this.title,
    this.mediumCheck,
    this.subtitle,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textStyle.fontSize18FontWeight700,
                  ),
                  if (mediumCheck != null)
                    Text(
                      mediumCheck!,
                      style: context.textStyle.fontSize12FontWeight400.copyWith(
                        color: context.color.blackWhiteColor.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
              if (subtitle != null)
                InkWell(
                  onTap: onTap ?? () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Text(
                    subtitle!,
                    style: context.textStyle.fontSize14FontWeight700.copyWith(
                      color: context.color.primaryColor1,
                      height: 40 /14,
                    ),
                  ),
                )
            ],
          ),
        ),
        const Gap(16),
        child,
      ],
    );
  }
}
