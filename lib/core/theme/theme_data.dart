import 'package:my_flutter_template/app.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:flutter/material.dart';

import 'app_text_style.dart';
import 'colors/app_colors.dart';
import 'colors/app_gradients.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  applyElevationOverlayColor: true,
  visualDensity: VisualDensity.standard,
  materialTapTargetSize: MaterialTapTargetSize.padded,
  fontFamily: 'SFProText',
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.zero,
      ),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
  ),
  dividerTheme: const DividerThemeData(
    thickness: 1,
    space: 1,
  ),
);

final violetLightTheme = appTheme.copyWith(
  primaryColor: ThemeColors.light.primaryColor1,
  scaffoldBackgroundColor: ThemeColors.light.bg1,
  brightness: Brightness.light,
  dividerTheme: appTheme.dividerTheme.copyWith(
    color: ThemeColors.light.scaffoldBackGroundColor,
  ),
  extensions: <ThemeExtension<dynamic>>[
    AppTextStyles.light,
    ThemeColors.light,
    ThemeGradients.light,
  ],
  appBarTheme: AppBarTheme(
    elevation: 0,
    foregroundColor: ThemeColors.light.black,
    backgroundColor: ThemeColors.light.bg1,
    surfaceTintColor: ThemeColors.light.bg1,
    titleTextStyle: AppTextStyles.light.fontSize18FontWeight700,
    toolbarHeight: 56,
    scrolledUnderElevation: 1,
    iconTheme: IconThemeData(
      color: ThemeColors.light.black,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: AppUtils.kPaddingAll16,
    alignLabelWithHint: true,
    isDense: true,
    constraints: const BoxConstraints(
      minHeight: 56,
      maxHeight: 56,
    ),
    fillColor: ThemeColors.light.textFieldFillColor,
    border: const OutlineInputBorder(
      borderRadius: AppUtils.kBorderRadius10,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppUtils.kBorderRadius10,
      borderSide: BorderSide(
        color: ThemeColors.light.primaryColor1,
        width: 1,
      ),
    ),
    disabledBorder: const OutlineInputBorder(
      borderRadius: AppUtils.kBorderRadius10,
      borderSide: BorderSide.none,
    ),
    filled: true,
    floatingLabelAlignment: FloatingLabelAlignment.start,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintStyle: AppTextStyles.light.fontSize16FontWeight700.copyWith(
      color: ThemeColors.light.black.withOpacity(0.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        return ThemeColors.light.white;
      }),
      textStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
        return AppTextStyles.light.fontSize16FontWeight700.copyWith(
          color: ThemeColors.light.white,
        );
      }),
      surfaceTintColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return ThemeColors.light.primaryColor1.withOpacity(0.5);
        } else {
          return ThemeColors.light.primaryColor1;
        }
      }),
      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return ThemeColors.light.primaryColor1.withOpacity(0.5);
        } else {
          return ThemeColors.light.primaryColor1;
        }
      }),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
          borderRadius: AppUtils.kBorderRadius10,
        ),
      ),
      maximumSize: MaterialStateProperty.all<Size>(
        const Size(double.infinity, 56),
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        const Size(double.infinity, 56),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return ThemeColors.light.accentColor.withOpacity(0.5);
        } else {
          return ThemeColors.light.accentColor;
        }
      }),
      textStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
        return AppTextStyles.light.fontSize16FontWeight700;
      }),
      maximumSize: MaterialStateProperty.all<Size>(
        const Size(double.infinity, 40),
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        const Size(double.infinity, 40),
      ),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: ThemeColors.light.white,
    landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    selectedItemColor: ThemeColors.light.primaryColor1,
    unselectedItemColor: ThemeColors.light.black,
    selectedLabelStyle: AppTextStyles.light.fontSize10FontWeight700.copyWith(
      color: ThemeColors.light.primaryColor1,
    ),
    unselectedLabelStyle: AppTextStyles.light.fontSize10FontWeight700.copyWith(
      color: ThemeColors.light.icon1,
    ),
  ),
);

final violetDarkTheme = appTheme.copyWith(
  primaryColor: ThemeColors.dark.primaryColor1,
  scaffoldBackgroundColor: ThemeColors.dark.bg1,
  brightness: Brightness.dark,
  dividerTheme: appTheme.dividerTheme.copyWith(
    color: ThemeColors.dark.scaffoldBackGroundColor,
    thickness: 1,
    space: 1,
  ),
  extensions: <ThemeExtension<dynamic>>[
    AppTextStyles.dark,
    ThemeColors.dark,
    ThemeGradients.dark,
  ],
  appBarTheme: AppBarTheme(
    elevation: 0,
    foregroundColor: ThemeColors.dark.black,
    backgroundColor: ThemeColors.dark.bg1,
    surfaceTintColor: ThemeColors.dark.bg1,
    titleTextStyle: AppTextStyles.dark.fontSize18FontWeight700,
    toolbarHeight: 56,
    scrolledUnderElevation: 1,
    iconTheme: IconThemeData(
      color: ThemeColors.dark.black,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    contentPadding: AppUtils.kPaddingAll16,
    isDense: true,
    alignLabelWithHint: true,
    constraints: const BoxConstraints(
      minHeight: 56,
      maxHeight: 56,
    ),
    fillColor: ThemeColors.dark.textFieldFillColor,
    border: const OutlineInputBorder(
      borderRadius: AppUtils.kBorderRadius10,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppUtils.kBorderRadius10,
      borderSide: BorderSide(
        color: ThemeColors.dark.primaryColor1,
        width: 1,
      ),
    ),
    disabledBorder: const OutlineInputBorder(
      borderRadius: AppUtils.kBorderRadius10,
      borderSide: BorderSide.none,
    ),
    filled: true,
    floatingLabelAlignment: FloatingLabelAlignment.start,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintStyle: AppTextStyles.dark.fontSize16FontWeight700.copyWith(
      color: ThemeColors.dark.white.withOpacity(0.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        return ThemeColors.dark.white;
      }),
      textStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
        return AppTextStyles.dark.fontSize16FontWeight700.copyWith(
          color: ThemeColors.dark.white,
        );
      }),
      surfaceTintColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return ThemeColors.dark.primaryColor1.withOpacity(0.5);
        } else {
          return ThemeColors.dark.primaryColor1;
        }
      }),
      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return ThemeColors.dark.primaryColor1.withOpacity(0.5);
        } else {
          return ThemeColors.dark.primaryColor1;
        }
      }),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
          borderRadius: AppUtils.kBorderRadius10,
        ),
      ),
      maximumSize: MaterialStateProperty.all<Size>(
        const Size(double.infinity, 56),
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        const Size(double.infinity, 56),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return ThemeColors.dark.accentColor.withOpacity(0.5);
        } else {
          return ThemeColors.dark.accentColor;
        }
      }),
      textStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
        return AppTextStyles.dark.fontSize16FontWeight700;
      }),
      maximumSize: MaterialStateProperty.all<Size>(
        const Size(double.infinity, 40),
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        const Size(double.infinity, 40),
      ),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: ThemeColors.dark.white,
    landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    selectedItemColor: ThemeColors.dark.primaryColor1,
    unselectedItemColor: ThemeColors.dark.black,
    selectedLabelStyle: AppTextStyles.dark.fontSize10FontWeight700.copyWith(
      color: ThemeColors.dark.primaryColor1,
    ),
    unselectedLabelStyle: AppTextStyles.dark.fontSize10FontWeight700.copyWith(
      color: ThemeColors.dark.icon1,
    ),
  ),
);
