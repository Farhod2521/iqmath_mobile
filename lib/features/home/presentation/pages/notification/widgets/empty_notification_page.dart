import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/assets.dart';
import '../../../../../../generated/l10n.dart';

class EmptyNotificationPage extends StatelessWidget {
  const EmptyNotificationPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: kToolbarHeight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 151,
              width: 175,
              child: Image.asset(
                Assets.pngEmptyNotification,
              ),
            ),
            Text(
              localization.here_yet_empty,
              style: context.textStyle.fontSize16FontWeight500.copyWith(
                color: context.color.mainText5,
              ),
            ),
            Text(
              localization.comback_later,
              style: context.textStyle.fontSize16FontWeight500.copyWith(
                color: context.color.mainText5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}