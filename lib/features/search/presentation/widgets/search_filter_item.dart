import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../generated/assets.dart';

class SearchFilterItem extends StatelessWidget {
  final bool isFirst;
  final String title;
  final VoidCallback onTap;
  final VoidCallback firstOnTap;

  const SearchFilterItem({
    super.key,
    required this.isFirst,
    required this.title,
    required this.onTap,
    required this.firstOnTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isFirst) {
      return ClipOval(
        child: Material(
          child: InkWell(
            onTap: firstOnTap,
            child: Ink(
              width: 32,
              decoration: BoxDecoration(
                color: context.color.bg1,
              ),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: SvgPicture.asset(
                    Assets.svgSettingsSliders,
                    fit: BoxFit.scaleDown,
                    color: context.color.blackWhiteColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(37),
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                color: context.color.bg1,
                borderRadius: BorderRadius.circular(37),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Text(
                title,
                style: context.textStyle.fontSize12FontWeight400,
              ),
            ),
          ),
        ),
      );
    }
  }
}
