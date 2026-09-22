import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SoonPage extends StatelessWidget {
  const SoonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Image.asset(
                      Assets.pngSoon,
                    ),
                  ),
                  const Gap(30),
                  Text(
                    "${localization.soon}...",
                    style: context.textStyle.fontSize20FontWeight700,
                  ),
                  const Gap(20),
                  Text(
                    localization.given_section_developing,
                    textAlign: TextAlign.center,
                    style: context.textStyle.fontSize16FontWeight500.copyWith(
                      color: context.color.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (Navigator.canPop(context))
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  localization.get_back,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
