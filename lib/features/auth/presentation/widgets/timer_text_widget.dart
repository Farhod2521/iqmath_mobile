import 'dart:async';

import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';

class TimerTextWidget extends StatefulWidget {
  final int seconds;

  const TimerTextWidget({Key? key, required this.seconds}) : super(key: key);

  @override
  State<TimerTextWidget> createState() => _TimerTextWidgetState();
}

class _TimerTextWidgetState extends State<TimerTextWidget> {
  late int _pastSeconds;
  late Timer timer;

  @override
  void initState() {
    _pastSeconds = widget.seconds;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_pastSeconds < 1) {
        timer.cancel();
      } else {
        setState(() {
          _pastSeconds--;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    if (_pastSeconds == 0) {
      return Text(
        localization.resend_code,
        style: context.textStyle.fontSize12FontWeight400.copyWith(
          color: context.color.primaryColor1,
        ),
      );
    } else {
      return Text(
        "${localization.resend_sms} $_pastSeconds",
        style: context.textStyle.fontSize12FontWeight400.copyWith(
          color: context.color.primaryColor1,
        ),
      );
    }
  }
}
