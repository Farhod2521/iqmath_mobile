import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/utils/base_utils.dart';
import 'package:my_flutter_template/features/auth/presentation/widgets/auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../generated/l10n.dart';
import '../bloc/auth_bloc.dart';

class NameSubPage extends StatefulWidget {
  final BuildContext loginPageContext;
  final TextEditingController firstNameController;
  final TextEditingController surnameController;

  const NameSubPage(
      {Key? key,
      required this.loginPageContext,
      required this.firstNameController,
      required this.surnameController})
      : super(key: key);

  @override
  State<NameSubPage> createState() => _NameSubPageState();
}

class _NameSubPageState extends State<NameSubPage> {
  late FocusNode nameFocus, lastNameFocus;

  @override
  void initState() {
    nameFocus = FocusNode();
    lastNameFocus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(widget.loginPageContext).requestFocus(nameFocus);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return AuthLayout(
      title: localization.introduce_yourself,
      subtitle: localization.how_to_call_you,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(40),
          Text(
            localization.your_name,
            style: context.textStyle.fontSize16FontWeight700,
          ),
          const Gap(10),
          TextField(
            controller: widget.firstNameController,
            autofocus: true,
            focusNode: nameFocus,
            textCapitalization: TextCapitalization.words,
            style: context.textStyle.fontSize16FontWeight500,
            inputFormatters: [
              BaseFunctions.onlyLettersFormatter,
              LengthLimitingTextInputFormatter(15),
            ],
            decoration: InputDecoration(
              hintText: localization.example_name,
            ),
            onChanged: (firstName) {
              // context.read<AuthBloc>().add(
              //       AuthSetFirstNameEvent(firstName),
              //     );
            },
          ),
          const Gap(20),
          Text(
            localization.surname,
            style: context.textStyle.fontSize16FontWeight700,
          ),
          const Gap(10),
          TextField(
            controller: widget.surnameController,
            textCapitalization: TextCapitalization.words,
            style: context.textStyle.fontSize16FontWeight500,
            focusNode: lastNameFocus,
            inputFormatters: [
              BaseFunctions.onlyLettersFormatter,
              LengthLimitingTextInputFormatter(20),
            ],
            decoration: InputDecoration(
              hintText: localization.example_name,
            ),
            onChanged: (lastName) {
              // context.read<AuthBloc>().add(
              //       AuthSetSurnameEvent(lastName),
              //     );
            },
          ),
          Gap(MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
