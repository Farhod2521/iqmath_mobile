import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../../router/app_routes.dart';
import '../../../../router/name_routes.dart';

class ExitDialog extends StatelessWidget {
  const ExitDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Dialog(
      backgroundColor: context.color.bg1,
      surfaceTintColor: context.color.bg1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 157,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  localization.want_exit,
                  style: context.textStyle.fontSize16FontWeight700,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Divider(),
            SizedBox(
              height: 54,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        sl<LocalSource>().clear();
                        Navigator.pop(context);
                      },
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
      ),
    );
  }
}
