import 'package:flutter/material.dart';

import 'colors/app_colors.dart';

class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle fontSize48FontWeight700;
  final TextStyle fontSize28FontWeight500;
  final TextStyle fontSize24FontWeight400;
  final TextStyle fontSize24FontWeight500;
  final TextStyle fontSize24FontWeight700;
  final TextStyle fontSize20FontWeight800;
  final TextStyle fontSize20FontWeight700;
  final TextStyle fontSize18FontWeight800;
  final TextStyle fontSize18FontWeight700;
  final TextStyle fontSize16FontWeight700;
  final TextStyle fontSize16FontWeight500;
  final TextStyle fontSize16FontWeight400;
  final TextStyle fontSize14FontWeight700;
  final TextStyle fontSize14FontWeight500;
  final TextStyle fontSize14FontWeight400;
  final TextStyle fontSize12FontWeight700;
  final TextStyle fontSize12FontWeight400;
  final TextStyle fontSize10FontWeight700;
  final TextStyle fontSize10FontWeight400;
  final TextStyle fontSize10FontWeight300;
  final TextStyle fontSize8FontWeight700;
  final TextStyle fontSize6FontWeight400;

  const AppTextStyles({
    required this.fontSize48FontWeight700,
    required this.fontSize28FontWeight500,
    required this.fontSize24FontWeight400,
    required this.fontSize24FontWeight500,
    required this.fontSize24FontWeight700,
    required this.fontSize20FontWeight800,
    required this.fontSize20FontWeight700,
    required this.fontSize18FontWeight800,
    required this.fontSize16FontWeight700,
    required this.fontSize16FontWeight500,
    required this.fontSize16FontWeight400,
    required this.fontSize14FontWeight700,
    required this.fontSize14FontWeight500,
    required this.fontSize14FontWeight400,
    required this.fontSize18FontWeight700,
    required this.fontSize12FontWeight700,
    required this.fontSize12FontWeight400,
    required this.fontSize10FontWeight700,
    required this.fontSize10FontWeight400,
    required this.fontSize10FontWeight300,
    required this.fontSize8FontWeight700,
    required this.fontSize6FontWeight400,
  });

  static final light = AppTextStyles(
    fontSize48FontWeight700: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: ThemeColors.light.black,
    ),
    fontSize28FontWeight500: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: ThemeColors.light.black,
    ),
    fontSize24FontWeight400: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: ThemeColors.light.black,
    ),
    fontSize24FontWeight500: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: ThemeColors.light.black,
    ),
    fontSize24FontWeight700: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: ThemeColors.light.black,
    ),
    fontSize20FontWeight800: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: ThemeColors.light.black,
    ),
    fontSize20FontWeight700: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: ThemeColors.light.black,
    ),
    fontSize18FontWeight800: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: ThemeColors.light.black,
    ),
    fontSize16FontWeight700: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: ThemeColors.light.black,
    ),
    fontSize16FontWeight500: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: ThemeColors.light.black,
    ),
    fontSize16FontWeight400: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ThemeColors.light.black,
    ),
    fontSize14FontWeight700: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: ThemeColors.light.black,
    ),
    fontSize14FontWeight500: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ThemeColors.light.black,
    ),
    fontSize14FontWeight400: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ThemeColors.light.black,
    ),
    fontSize18FontWeight700: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ThemeColors.light.black,
    ),
    fontSize12FontWeight700: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: ThemeColors.light.black,
    ),
    fontSize12FontWeight400: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: ThemeColors.light.black,
    ),
    fontSize10FontWeight700: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: ThemeColors.light.black,
    ),
    fontSize10FontWeight400: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: ThemeColors.light.black,
    ),
    fontSize10FontWeight300: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w300,
      color: ThemeColors.light.black,
    ),
    fontSize8FontWeight700: TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w700,
      color: ThemeColors.light.black,
    ),
    fontSize6FontWeight400: TextStyle(
      fontSize: 6,
      fontWeight: FontWeight.w400,
      color: ThemeColors.light.black,
    ),
  );

  static final dark = AppTextStyles(
    fontSize48FontWeight700: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: ThemeColors.dark.white,
    ),
    fontSize28FontWeight500: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: ThemeColors.dark.white,
    ),
    fontSize24FontWeight400: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: ThemeColors.dark.white,
    ),
    fontSize24FontWeight500: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: ThemeColors.dark.white,
    ),
    fontSize24FontWeight700: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: ThemeColors.dark.white,
    ),
    fontSize20FontWeight700: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: ThemeColors.dark.white,
    ),
    fontSize20FontWeight800: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: ThemeColors.dark.white,
    ),
    fontSize18FontWeight800: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: ThemeColors.dark.white,
    ),
    fontSize16FontWeight700: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: ThemeColors.dark.white,
    ),
    fontSize16FontWeight500: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: ThemeColors.dark.white,
    ),
    fontSize16FontWeight400: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ThemeColors.dark.white,
    ),
    fontSize14FontWeight700: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: ThemeColors.dark.white,
    ),
    fontSize14FontWeight500: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ThemeColors.dark.white,
    ),
    fontSize14FontWeight400: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: ThemeColors.dark.white,
    ),
    fontSize18FontWeight700: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ThemeColors.dark.white,
    ),
    fontSize12FontWeight700: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: ThemeColors.dark.white,
    ),
    fontSize12FontWeight400: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: ThemeColors.dark.white,
    ),
    fontSize10FontWeight700: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: ThemeColors.dark.white,
    ),
    fontSize10FontWeight400: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: ThemeColors.dark.white,
    ),
    fontSize10FontWeight300: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w300,
      color: ThemeColors.dark.white,
    ),
    fontSize8FontWeight700: TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w700,
      color: ThemeColors.dark.white,
    ),
    fontSize6FontWeight400: TextStyle(
      fontSize: 6,
      fontWeight: FontWeight.w400,
      color: ThemeColors.dark.white,
    ),
  );

  @override
  ThemeExtension<AppTextStyles> copyWith({
    TextStyle? fontSize48FontWeight700,
    TextStyle? fontSize28FontWeight500,
    TextStyle? fontSize24FontWeight400,
    TextStyle? fontSize24FontWeight500,
    TextStyle? fontSize24FontWeight700,
    TextStyle? fontSize20FontWeight800,
    TextStyle? fontSize20FontWeight700,
    TextStyle? fontSize18FontWeight800,
    TextStyle? fontSize16FontWeight700,
    TextStyle? fontSize16FontWeight500,
    TextStyle? fontSize16FontWeight400,
    TextStyle? fontSize14FontWeight700,
    TextStyle? fontSize14FontWeight500,
    TextStyle? fontSize14FontWeight400,
    TextStyle? fontSize18FontWeight700,
    TextStyle? fontSize12FontWeight700,
    TextStyle? fontSize12FontWeight400,
    TextStyle? fontSize10FontWeight700,
    TextStyle? fontSize10FontWeight400,
    TextStyle? fontSize10FontWeight300,
    TextStyle? fontSize8FontWeight700,
    TextStyle? fontSize6FontWeight400,
  }) {
    return AppTextStyles(
      fontSize48FontWeight700:
          fontSize48FontWeight700 ?? this.fontSize48FontWeight700,
      fontSize28FontWeight500:
          fontSize28FontWeight500 ?? this.fontSize28FontWeight500,
      fontSize24FontWeight400:
          fontSize24FontWeight400 ?? this.fontSize24FontWeight400,
      fontSize24FontWeight500:
          fontSize24FontWeight500 ?? this.fontSize24FontWeight500,
      fontSize24FontWeight700:
          fontSize24FontWeight700 ?? this.fontSize24FontWeight700,
      fontSize20FontWeight800:
          fontSize20FontWeight800 ?? this.fontSize20FontWeight800,
      fontSize20FontWeight700:
          fontSize20FontWeight700 ?? this.fontSize20FontWeight700,
      fontSize18FontWeight800:
          fontSize18FontWeight800 ?? this.fontSize18FontWeight800,
      fontSize16FontWeight700:
          fontSize16FontWeight700 ?? this.fontSize16FontWeight700,
      fontSize16FontWeight500:
          fontSize16FontWeight500 ?? this.fontSize16FontWeight500,
      fontSize16FontWeight400:
          fontSize16FontWeight400 ?? this.fontSize16FontWeight400,
      fontSize14FontWeight700:
          fontSize14FontWeight700 ?? this.fontSize14FontWeight700,
      fontSize14FontWeight500:
          fontSize14FontWeight500 ?? this.fontSize14FontWeight500,
      fontSize14FontWeight400:
          fontSize14FontWeight400 ?? this.fontSize14FontWeight400,
      fontSize18FontWeight700:
          fontSize18FontWeight700 ?? this.fontSize18FontWeight700,
      fontSize12FontWeight700:
          fontSize12FontWeight700 ?? this.fontSize12FontWeight700,
      fontSize12FontWeight400:
          fontSize12FontWeight400 ?? this.fontSize12FontWeight400,
      fontSize10FontWeight700:
          fontSize10FontWeight700 ?? this.fontSize10FontWeight700,
      fontSize10FontWeight400:
          fontSize10FontWeight400 ?? this.fontSize10FontWeight400,
      fontSize10FontWeight300:
          fontSize10FontWeight300 ?? this.fontSize10FontWeight300,
      fontSize8FontWeight700:
          fontSize8FontWeight700 ?? this.fontSize8FontWeight700,
      fontSize6FontWeight400:
          fontSize6FontWeight400 ?? this.fontSize6FontWeight400,
    );
  }

  @override
  ThemeExtension<AppTextStyles> lerp(
      ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) {
      return this;
    }
    return AppTextStyles(
      fontSize48FontWeight700: TextStyle.lerp(
          fontSize48FontWeight700, other.fontSize48FontWeight700, t)!,
      fontSize28FontWeight500: TextStyle.lerp(
          fontSize28FontWeight500, other.fontSize28FontWeight500, t)!,
      fontSize24FontWeight400: TextStyle.lerp(
          fontSize24FontWeight400, other.fontSize24FontWeight400, t)!,
      fontSize24FontWeight500: TextStyle.lerp(
          fontSize24FontWeight500, other.fontSize24FontWeight500, t)!,
      fontSize24FontWeight700: TextStyle.lerp(
          fontSize24FontWeight700, other.fontSize24FontWeight700, t)!,
      fontSize20FontWeight800: TextStyle.lerp(
          fontSize20FontWeight800, other.fontSize20FontWeight800, t)!,
      fontSize20FontWeight700: TextStyle.lerp(
          fontSize20FontWeight700, other.fontSize20FontWeight700, t)!,
      fontSize18FontWeight800: TextStyle.lerp(
          fontSize18FontWeight800, other.fontSize18FontWeight800, t)!,
      fontSize16FontWeight700: TextStyle.lerp(
          fontSize16FontWeight700, other.fontSize16FontWeight700, t)!,
      fontSize16FontWeight500: TextStyle.lerp(
          fontSize16FontWeight500, other.fontSize16FontWeight500, t)!,
      fontSize16FontWeight400: TextStyle.lerp(
          fontSize16FontWeight400, other.fontSize16FontWeight400, t)!,
      fontSize14FontWeight700: TextStyle.lerp(
          fontSize14FontWeight700, other.fontSize14FontWeight700, t)!,
      fontSize14FontWeight500: TextStyle.lerp(
          fontSize14FontWeight500, other.fontSize14FontWeight500, t)!,
      fontSize14FontWeight400: TextStyle.lerp(
          fontSize14FontWeight400, other.fontSize14FontWeight400, t)!,
      fontSize18FontWeight700: TextStyle.lerp(
          fontSize18FontWeight700, other.fontSize18FontWeight700, t)!,
      fontSize12FontWeight700: TextStyle.lerp(
          fontSize12FontWeight700, other.fontSize12FontWeight700, t)!,
      fontSize12FontWeight400: TextStyle.lerp(
          fontSize12FontWeight400, other.fontSize12FontWeight400, t)!,
      fontSize10FontWeight700: TextStyle.lerp(
          fontSize10FontWeight700, other.fontSize10FontWeight700, t)!,
      fontSize10FontWeight400: TextStyle.lerp(
          fontSize10FontWeight400, other.fontSize10FontWeight400, t)!,
      fontSize10FontWeight300: TextStyle.lerp(
          fontSize10FontWeight300, other.fontSize10FontWeight300, t)!,
      fontSize8FontWeight700: TextStyle.lerp(
          fontSize8FontWeight700, other.fontSize8FontWeight700, t)!,
      fontSize6FontWeight400: TextStyle.lerp(
          fontSize6FontWeight400, other.fontSize6FontWeight400, t)!,
    );
  }
}

extension BuildContextX on BuildContext {
  AppTextStyles get textStyle => Theme.of(this).extension<AppTextStyles>()!;
}
