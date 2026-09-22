import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapButtonWidget extends StatelessWidget {
  final String iconUrl;
  final VoidCallback onTap;

  const MapButtonWidget({
    super.key,
    required this.iconUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: context.color.bg1,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: SvgPicture.asset(
                  iconUrl,
                  color: context.color.blackWhiteColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
