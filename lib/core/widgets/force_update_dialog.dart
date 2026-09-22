import 'dart:io';

import 'package:my_flutter_template/constants/constants.dart';
import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateDialog extends StatelessWidget {
  const ForceUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Dialog(
      backgroundColor: context.color.bg1,
      surfaceTintColor: context.color.bg1,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 48,
          bottom: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.svgLogo,
              width: 30,
              height: 30,
            ),
            const Gap(10),
            SvgPicture.asset(
              Assets.svgSlash,
              width: 77,
              height: 24,
              color: context.color.primaryColor1,
            ),
            const Gap(4),
            Container(
              height: 3,
              width: 77,
              color: context.color.primaryColor1,
            ),
            const Gap(40),
            Text(
              localization.new_version,
              textAlign: TextAlign.center,
              style: context.textStyle.fontSize18FontWeight700.copyWith(
                height: 25 / 18,
              ),
            ),
            const Gap(16),
            Text(
              localization.new_version_description,
              textAlign: TextAlign.center,
              style: context.textStyle.fontSize16FontWeight400.copyWith(
                height: 26 / 16,
                color: context.color.secondaryColor,
              ),
            ),
            const Gap(40),
            ElevatedButton(
              onPressed: () {
                final url = Uri.parse(
                  Platform.isAndroid
                      ? Constants.androidUrl
                      : Constants.iosUrl,
                );
                launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Text(localization.update_app),
            ),
          ],
        ),
      ),
    );
  }
}
