import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/cupertino.dart';

class BiometricsWidget extends StatelessWidget {
  final Function(bool) onChanged;
  final bool value;

  const BiometricsWidget({super.key, required this.onChanged, required this.value});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Container(
      height: 50,
      width: 256,
      decoration: BoxDecoration(
        color: context.color.bg1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.color.mainText5,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localization.turn_on_biometric,
              style: context.textStyle.fontSize16FontWeight500.copyWith(
                color: context.color.secondaryColor,
              ),
            ),
            CupertinoSwitch(
              value: value,
              activeColor: context.color.primaryColor1,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
