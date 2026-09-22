import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../generated/l10n.dart';
import '../../injector_container.dart';
import '../local_source/local_source.dart';

class CustomExitDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const CustomExitDialog(
      {super.key, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Dialog(
      backgroundColor: context.color.bg1,
      surfaceTintColor: context.color.bg1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 30,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: context.textStyle.fontSize16FontWeight700,
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  const Gap(10),
                  Text(
                    subtitle!,
                    style:
                        context.textStyle.fontSize16FontWeight400.copyWith(
                      color: context.color.secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            height: 54,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      backgroundColor: context.color.bg1,
                      surfaceTintColor: context.color.bg1,
                    ),
                    child: Text(
                      localization.yes,
                      style: context.textStyle.fontSize16FontWeight700,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    child: Text(localization.cancel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
