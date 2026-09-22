import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? buttonIcon;
  final Function(String) onChanged;
  final VoidCallback? buttonOnTap;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    this.buttonIcon,
    required this.onChanged,
    this.buttonOnTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: context.color.blackWhiteColor.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                cursorColor: context.color.accentColor,
                onChanged: onChanged,
                style: context.textStyle.fontSize14FontWeight400,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: context.textStyle.fontSize14FontWeight400.copyWith(
                    color: context.color.secondaryColor,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: context.color.bg1,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    maxHeight: 20,
                  ),
                  constraints: const BoxConstraints(
                    maxHeight: 48,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Image.asset(
                      Assets.pngSearch,
                      color: context.color.secondaryColor,
                    ),
                  ),
                  fillColor: context.color.bg1,
                ),
              ),
            ),
          ),
          if (buttonIcon != null && buttonOnTap != null) const Gap(10),
          if (buttonIcon != null && buttonOnTap != null)
            InkWell(
              onTap: buttonOnTap,
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.color.bg1,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: context.color.blackWhiteColor.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      buttonIcon!,
                      color: context.color.blackWhiteColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
