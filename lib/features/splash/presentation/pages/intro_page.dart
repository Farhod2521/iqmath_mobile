import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:my_flutter_template/features/auth/presentation/page_args/auth_args.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../generated/l10n.dart';
import '../../../../router/name_routes.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Scaffold(
      body: SafeArea(
        minimum: AppUtils.kPaddingAll16,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 72,
                    width: 87,
                    child: Image.asset(
                      Assets.pngLogo4x,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  const Gap(24),
                  Text(
                    localization.welcome,
                    style: context.textStyle.fontSize24FontWeight700,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.auth,
                        arguments: const AuthPageArgs(),
                      );
                    },
                    child: Text(localization.register),
                  ),
                  const Gap(12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.color.bg1,
                      surfaceTintColor: context.color.bg1,
                      side: BorderSide(
                        color: context.color.primaryColor1,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      localization.authorization,
                      style: context.textStyle.fontSize16FontWeight700.copyWith(
                        color: context.color.primaryColor1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
