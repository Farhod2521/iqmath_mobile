import 'package:my_flutter_template/core/extension/extensions.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';

class CustomBtmSheet extends StatelessWidget {
  final Widget child;
  final Constraints? constraints;

  const CustomBtmSheet(
      {Key? key, required this.child, required this.constraints})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              height: 4,
              width: 50,
              decoration: BoxDecoration(
                color: context.color.bg1,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Gap(6),
          if (constraints != null)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: ColoredBox(
                  color: context.color.bg1,
                  child: child,
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: ColoredBox(
                color: context.color.bg1,
                child: child,
              ),
            )
        ],
      ),
    );
  }
}

Future<dynamic> openBottomSheet(BuildContext context,
    {required Widget child,
    bool isDismissible = true,
    Color? backGroundColor,
    Radius? borderRadius,
    required BoxConstraints? constraints}) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    elevation: 0,
    isDismissible: isDismissible,
    constraints: constraints,
    builder: (context) {
      return CustomBtmSheet(
        constraints: constraints,
        child: child,
      );
    },
  );
}
