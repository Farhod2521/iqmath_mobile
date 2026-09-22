import 'package:flutter/material.dart';

class ThemeColors extends ThemeExtension<ThemeColors> {
  final Color accentColor;
  final Color textColor;
  final Color secondaryColor;
  final Color primaryColor1;
  final Color primaryColor2;
  final Color primaryColor3;
  final Color primaryColor4;
  final Color primaryColor5;
  final Color mainText1;
  final Color mainText2;
  final Color mainText3;
  final Color mainText4;
  final Color mainText5;
  final Color bodyText;
  final Color alert1;
  final Color alert2;
  final Color icon1;
  final Color icon2;
  final Color icon3;
  final Color bg1;
  final Color bg2;
  final Color bg3;
  final Color black;
  final Color white;
  final Color textFieldFillColor;
  final Color blackWhiteColor;
  final Color bottomAppBarColor;
  final Color scaffoldBackGroundColor;
  final Color homeButtonsColor;

  const ThemeColors({
    required this.accentColor,
    required this.textColor,
    required this.secondaryColor,
    required this.primaryColor1,
    required this.primaryColor2,
    required this.primaryColor3,
    required this.primaryColor4,
    required this.primaryColor5,
    required this.mainText1,
    required this.mainText2,
    required this.mainText3,
    required this.mainText4,
    required this.mainText5,
    required this.bodyText,
    required this.alert1,
    required this.alert2,
    required this.icon1,
    required this.icon2,
    required this.icon3,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.black,
    required this.white,
    required this.textFieldFillColor,
    required this.blackWhiteColor,
    required this.bottomAppBarColor,
    required this.scaffoldBackGroundColor,
    required this.homeButtonsColor,
  });

  static const light = ThemeColors(
    accentColor: Color(0xFF0ABAB5),
    textColor: Color(0xFF212121),
    secondaryColor: Color(0xFF767676),
    primaryColor1: Color(0xFF5d87ff),
    primaryColor2: Color(0xFF0ABAB5),
    primaryColor3: Color(0xFFE17F60),
    primaryColor4: Color(0xFFE9A28B),
    primaryColor5: Color(0xFFF1C4B6),
    mainText1: Color(0xFF2F2E2E),
    mainText2: Color(0xFF484747),
    mainText3: Color(0xFF626060),
    mainText4: Color(0xFF7B7979),
    mainText5: Color(0xFF959393),
    bodyText: Color(0xFF2F2E2E),
    alert1: Color(0xFFDE1010),
    alert2: Color(0xFFF03333),
    icon1: Color(0xFF292D32),
    icon2: Color(0xFF959393),
    icon3: Color(0xFF999999),
    bg1: Color(0xFFFFFFFF),
    bg2: Color(0xFFFCFCFC),
    bg3: Color(0xFFFAFAFA),
    black: Color(0xFF000000),
    white: Color(0xFFFFFFFF),
    textFieldFillColor: Color(0xFFF5F5F5),
    blackWhiteColor: Color(0xFF000000),
    bottomAppBarColor: Color(0xFFD9D9D9),
    scaffoldBackGroundColor: Color(0xFFF5F5F5),
    homeButtonsColor: Color(0xFFFFF0EB),
  );

  static const dark = ThemeColors(
    accentColor: Color(0xFFFF8A33),
    textColor: Color(0xFFE0E0E0),
    secondaryColor: Color(0xFF989898),
    primaryColor1: Color(0xFF6C63FF),
    primaryColor2: Color(0xFFD95C35),
    primaryColor3: Color(0xFFE17F60),
    primaryColor4: Color(0xFFE9A28B),
    primaryColor5: Color(0xFFF1C4B6),
    mainText1: Color(0xFFFFFFFF),
    mainText2: Color(0xFF484747),
    mainText3: Color(0xFF626060),
    mainText4: Color(0xFF7B7979),
    mainText5: Color(0xFF959393),
    bodyText: Color(0xFFBCBCBC),
    alert1: Color(0xFFFF0808),
    alert2: Color(0xFFFF3D3D),
    icon1: Color(0xFFABA8A8),
    icon2: Color(0xFF827F7F),
    icon3: Color(0xFF535151),
    bg1: Color(0xFF252321),
    bg2: Color(0xFF151413),
    bg3: Color(0xFF1b1b1b),
    black: Color(0xFF000000),
    white: Color(0xFFFFFFFF),
    textFieldFillColor: Color(0xFF22201E),
    blackWhiteColor: Color(0xFFFFFFFF),
    bottomAppBarColor: Color(0xFF22201E),
    scaffoldBackGroundColor: Color(0xFF161414),
    homeButtonsColor: Color(0xFF22201E),
  );

  @override
  ThemeExtension<ThemeColors> copyWith({
    Color? accentColor,
    Color? textColor,
    Color? secondaryColor,
    Color? primaryColor1,
    Color? primaryColor2,
    Color? primaryColor3,
    Color? primaryColor4,
    Color? primaryColor5,
    Color? mainText1,
    Color? mainText2,
    Color? mainText3,
    Color? mainText4,
    Color? mainText5,
    Color? bodyText,
    Color? alert1,
    Color? alert2,
    Color? icon1,
    Color? icon2,
    Color? icon3,
    Color? bg1,
    Color? bg2,
    Color? bg3,
    Color? black,
    Color? white,
    Color? textFieldFillColor,
    Color? blackWhiteColor,
    Color? bottomAppBarColor,
    Color? scaffoldBackGroundColor,
    Color? homeButtonsColor,
  }) {
    return ThemeColors(
      accentColor: accentColor ?? this.accentColor,
      textColor: textColor ?? this.textColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      primaryColor1: primaryColor1 ?? this.primaryColor1,
      primaryColor2: primaryColor2 ?? this.primaryColor2,
      primaryColor3: primaryColor3 ?? this.primaryColor3,
      primaryColor4: primaryColor4 ?? this.primaryColor4,
      primaryColor5: primaryColor5 ?? this.primaryColor5,
      mainText1: mainText1 ?? this.mainText1,
      mainText2: mainText2 ?? this.mainText2,
      mainText3: mainText3 ?? this.mainText3,
      mainText4: mainText4 ?? this.mainText4,
      mainText5: mainText5 ?? this.mainText5,
      bodyText: bodyText ?? this.bodyText,
      alert1: alert1 ?? this.alert1,
      alert2: alert2 ?? this.alert2,
      icon1: icon1 ?? this.icon1,
      icon2: icon2 ?? this.icon2,
      icon3: icon3 ?? this.icon3,
      bg1: bg1 ?? this.bg1,
      bg2: bg2 ?? this.bg2,
      bg3: bg3 ?? this.bg3,
      black: black ?? this.black,
      white: white ?? this.white,
      textFieldFillColor: textFieldFillColor ?? this.textFieldFillColor,
      blackWhiteColor: blackWhiteColor ?? this.blackWhiteColor,
      bottomAppBarColor: bottomAppBarColor ?? this.bottomAppBarColor,
      scaffoldBackGroundColor:
          scaffoldBackGroundColor ?? this.scaffoldBackGroundColor,
      homeButtonsColor: homeButtonsColor ?? this.homeButtonsColor,
    );
  }

  @override
  ThemeExtension<ThemeColors> lerp(
      ThemeExtension<ThemeColors>? other, double t) {
    if (other is! ThemeColors) {
      return this;
    }
    return ThemeColors(
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      primaryColor1: Color.lerp(primaryColor1, other.primaryColor1, t)!,
      primaryColor2: Color.lerp(primaryColor2, other.primaryColor2, t)!,
      primaryColor3: Color.lerp(primaryColor3, other.primaryColor3, t)!,
      primaryColor4: Color.lerp(primaryColor4, other.primaryColor4, t)!,
      primaryColor5: Color.lerp(primaryColor5, other.primaryColor5, t)!,
      mainText1: Color.lerp(mainText1, other.mainText1, t)!,
      mainText2: Color.lerp(mainText2, other.mainText2, t)!,
      mainText3: Color.lerp(mainText3, other.mainText3, t)!,
      mainText4: Color.lerp(mainText4, other.mainText4, t)!,
      mainText5: Color.lerp(mainText5, other.mainText5, t)!,
      bodyText: Color.lerp(bodyText, other.bodyText, t)!,
      alert1: Color.lerp(alert1, other.alert1, t)!,
      alert2: Color.lerp(alert2, other.alert2, t)!,
      icon1: Color.lerp(icon1, other.icon1, t)!,
      icon2: Color.lerp(icon2, other.icon2, t)!,
      icon3: Color.lerp(icon3, other.icon3, t)!,
      bg1: Color.lerp(bg1, other.bg1, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      bg3: Color.lerp(bg3, other.bg3, t)!,
      black: Color.lerp(black, other.black, t)!,
      white: Color.lerp(white, other.white, t)!,
      textFieldFillColor:
          Color.lerp(textFieldFillColor, other.textFieldFillColor, t)!,
      blackWhiteColor: Color.lerp(blackWhiteColor, other.blackWhiteColor, t)!,
      bottomAppBarColor:
          Color.lerp(bottomAppBarColor, other.bottomAppBarColor, t)!,
      scaffoldBackGroundColor: Color.lerp(
          scaffoldBackGroundColor, other.scaffoldBackGroundColor, t)!,
      homeButtonsColor:
          Color.lerp(homeButtonsColor, other.homeButtonsColor, t)!,
    );
  }
}

extension BuildContextY on BuildContext {
  ThemeColors get color => Theme.of(this).extension<ThemeColors>()!;
}
