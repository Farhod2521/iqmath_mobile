import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';

class VersionWidget extends StatelessWidget {
  const VersionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final localSource = sl<LocalSource>();
    final version = localSource.getAppVersion()?.split(',').firstOrNull ?? "";
    final buildNumber =
        localSource.getAppVersion()?.split(',').lastOrNull ?? "";
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: localization.app_version,
            style: context.textStyle.fontSize14FontWeight500.copyWith(
              color: context.color.secondaryColor,
            ),
          ),
          TextSpan(
            text: " - $version ($buildNumber)",
            style: context.textStyle.fontSize14FontWeight500.copyWith(
              color: context.color.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
