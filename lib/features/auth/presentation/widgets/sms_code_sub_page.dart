import 'package:my_flutter_template/core/extension/extensions.dart';
import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/features/auth/presentation/widgets/auth_layout.dart';
import 'package:my_flutter_template/features/auth/presentation/widgets/timer_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/widgets/appbar_leading_widget.dart';
import '../../../../generated/l10n.dart';
import '../bloc/auth_bloc.dart';

class SmsCodeSubPage extends StatefulWidget {
  final BuildContext loginPageContext;
  final TextEditingController smsController;

  const SmsCodeSubPage(
      {Key? key, required this.loginPageContext, required this.smsController})
      : super(key: key);

  @override
  State<SmsCodeSubPage> createState() => _SmsCodeSubPageState();
}

class _SmsCodeSubPageState extends State<SmsCodeSubPage> {
  final textInputFormatter = MaskTextInputFormatter(
    mask: "###-###",
    filter: {"#": RegExp(r'[0-9]')},
  );
  late FocusNode smsFocus;

  @override
  void initState() {
    smsFocus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(widget.loginPageContext).requestFocus(smsFocus);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppbarLeadingWidget(
                    withBackground: true,
                  ),
                ],
              )
            : null,
        leadingWidth: 56,
        title: Text(localization.confirmation_code),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 120.height,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: widget.smsController,
                  cursorHeight: 22,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  focusNode: smsFocus,
                  style: context.textStyle.fontSize16FontWeight700,
                  decoration: InputDecoration(
                    hintText: "000-000",
                    hintStyle:
                        context.textStyle.fontSize20FontWeight700.copyWith(
                      color: context.color.mainText5,
                    ),
                    fillColor: context.color.bg1,
                    focusedBorder: null,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    textInputFormatter,
                  ],
                  onChanged: (sms) {
                    if (sms.length == 7) {
                      FocusScope.of(context).unfocus();
                    }
                    // context.read<AuthBloc>().add(
                    //       AuthSetSmsCodeEvent(sms),
                    //     );
                  },
                ),
                const Gap(41),
                const TimerTextWidget(
                  seconds: 30,
                ),
              ],
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return Text(
                  "${localization.we_send_code}\n ${BaseFunctions.formatPhoneNumber("+998${state.phoneNumber}")}",
                  textAlign: TextAlign.center,
                  style: context.textStyle.fontSize12FontWeight400.copyWith(
                    color: context.color.secondaryColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
