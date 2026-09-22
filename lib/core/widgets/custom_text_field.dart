import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

typedef Validator = String? Function(String?);
typedef OnChanged = void Function(String);
typedef OnFieldSubmitted = void Function(String);

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Validator? validator;
  final OnChanged onChanged;
  final TextInputType textInputType;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextCapitalization textCapitalization;
  final Color? cursorColor;
  final bool enabled;
  final bool obscure;
  final TextInputFormatter? textInputFormatter;
  final TextInputAction textInputAction;
  final String hintText;
  final String? errorText;
  final Widget? suffix;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? prefixIcon;
  final TextStyle? prefixTextStyle;
  final TextStyle? suffixTextStyle;
  final TextStyle? labelTextStyle;
  final TextStyle? hintStyle;
  final String? labelText;
  final String? prefixText;
  final String? suffixText;
  final bool labelInTextField;
  final EdgeInsetsGeometry? contentPadding;
  final double? cursorHeight;
  final OnFieldSubmitted? onFieldSubmitted;
  final Color? enabledBorderColor;
  final Color? fillColor;

  const CustomTextField({
    Key? key,
    this.controller,
    this.validator,
    this.hintStyle,
    required this.onChanged,
    this.textInputType = TextInputType.name,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.cursorColor,
    this.enabled = true,
    this.obscure = false,
    this.textInputFormatter,
    this.textInputAction = TextInputAction.done,
    this.nextFocusNode,
    required this.hintText,
    this.errorText,
    this.suffix,
    this.suffixIcon,
    this.prefix,
    this.prefixIcon,
    this.prefixTextStyle,
    this.suffixTextStyle,
    this.prefixText,
    this.suffixText,
    this.labelTextStyle,
    this.labelText,
    this.labelInTextField = false,
    this.contentPadding,
    this.cursorHeight,
    this.onFieldSubmitted,
    this.enabledBorderColor,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && !labelInTextField)
          Text(
            labelText!,
            style: labelTextStyle,
          ),
        if (labelText != null && !labelInTextField) const Gap(6),
        TextFormField(
          key: key,
          // style: context.textStyle.textFieldStyle,
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: textInputType,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          cursorColor: cursorColor ?? ThemeColors.light.accentColor,
          enableInteractiveSelection: true,
          obscureText: obscure,
          enabled: enabled,
          textInputAction: textInputAction,
          onEditingComplete: () {
            if (nextFocusNode != null) {
              nextFocusNode?.requestFocus();
            } else {
              focusNode?.unfocus();
            }
          },
          onFieldSubmitted: (value) {
            if (onFieldSubmitted != null) {
              onFieldSubmitted!(value);
            }
            if (nextFocusNode != null) {
              nextFocusNode?.requestFocus();
            } else {
              focusNode?.unfocus();
            }
          },
          inputFormatters: textInputFormatter != null
              ? [
                  textInputFormatter!,
                ]
              : null,
          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints(
              minWidth: 30,
              minHeight: 30,
            ),
            constraints: const BoxConstraints(
              minHeight: 40,
            ),
            labelText: labelInTextField ? labelText : null,
            labelStyle: labelTextStyle,
            hintText: hintText,
            hintStyle: hintStyle,
            enabledBorder: enabledBorderColor != null
                ? OutlineInputBorder(
                    borderRadius: AppUtils.kBorderRadius8,
                    borderSide: BorderSide(
                      color: enabledBorderColor!,
                    ),
                  )
                : null,
            fillColor: fillColor ?? ThemeColors.light.white,
            errorText: errorText,
            contentPadding: contentPadding ?? EdgeInsets.zero,
            suffix: suffix,
            suffixIcon: suffixIcon,
            prefix: prefix,
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            prefixStyle: prefixTextStyle,
            suffixText: suffixText,
            suffixStyle: suffixTextStyle,
          ),
          cursorHeight: cursorHeight,
        ),
      ],
    );
  }
}
