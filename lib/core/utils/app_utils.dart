import 'package:another_flushbar/flushbar.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/theme/colors/app_gradients.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppUtils {
  AppUtils._();

  ///sliver
  static const kSliverGap = SliverGap(0);
  static const kSliverGap2 = SliverGap(2);
  static const kSliverGap4 = SliverGap(4);
  static const kSliverGap6 = SliverGap(6);
  static const kSliverGap8 = SliverGap(8);
  static const kSliverGap10 = SliverGap(10);
  static const kSliverGap12 = SliverGap(12);
  static const kSliverGap16 = SliverGap(16);
  static const kSliverGap20 = SliverGap(20);
  static const kSliverGap24 = SliverGap(24);
  static const kSliverGap32 = SliverGap(32);
  static const kSliverGap40 = SliverGap(40);

  /// divider
  static const kDivider = Divider(height: 1, thickness: 1);
  static const kDividerVertical = VerticalDivider(
    width: 1,
    thickness: 1,
  );
  static const kPad16Divider = Padding(
    padding: EdgeInsets.only(left: 16),
    child: Divider(height: 1, thickness: 1),
  );
  static const kPadHor16Divider = Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1, thickness: 1),
  );

  /// spacer
  static const kSpacer = Spacer();

  /// padding
  static const kPaddingAll4 = EdgeInsets.all(4);
  static const kPaddingAll6 = EdgeInsets.all(6);
  static const kPaddingAll8 = EdgeInsets.all(8);
  static const kPaddingAll12 = EdgeInsets.all(12);
  static const kPaddingAll16 = EdgeInsets.all(16);
  static const kPaddingAllB16 = EdgeInsets.fromLTRB(16, 16, 16, 0);
  static const kPaddingAll24 = EdgeInsets.all(24);
  static const kPaddingHorizontal16 = EdgeInsets.symmetric(horizontal: 16);
  static const kPaddingHorizontal12 = EdgeInsets.symmetric(horizontal: 12);
  static const kPaddingHorizontal8 = EdgeInsets.symmetric(horizontal: 8);
  static const kPaddingHorizontal6 = EdgeInsets.symmetric(horizontal: 6);
  static const kPaddingVertical6 = EdgeInsets.symmetric(vertical: 6);
  static const kPaddingVertical16 = EdgeInsets.symmetric(vertical: 16);
  static const kPaddingHor32Ver20 =
      EdgeInsets.symmetric(horizontal: 32, vertical: 20);
  static const kPaddingHor12Ver14 =
      EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  static const kPaddingHor16Ver12 =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const kPaddingHor16Ver8 =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const kPaddingHor12Ver6 =
      EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static const kPaddingHor12Ver8 =
      EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const kPaddingHor12Ver10 =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const kPaddingHor8Ver4 =
      EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const kPaddingLeft12Right6Ver8 =
      EdgeInsets.only(left: 12, right: 6, top: 8, bottom: 8);
  static const kPaddingLeft12Right12 = EdgeInsets.only(
    left: 12,
    right: 12,
    top: 0,
    bottom: 0,
  );
  static const kPaddingLeft12Right12Bottom16 = EdgeInsets.only(
    left: 12,
    right: 12,
    top: 0,
    bottom: 16,
  );
  static const kPaddingLeft12Right12Top12Bottom4 =
      EdgeInsets.fromLTRB(12, 12, 12, 4);
  static const kPaddingLeft12Right12Top4Bottom4 =
      EdgeInsets.fromLTRB(12, 4, 12, 4);

  /// border radius
  static const kRadius = Radius.zero;
  static const kRadius8 = Radius.circular(8);
  static const kRadius12 = Radius.circular(12);
  static const kBorderRadius = BorderRadius.all(Radius.circular(0));
  static const kBorderRadius2 = BorderRadius.all(Radius.circular(2));
  static const kBorderRadius4 = BorderRadius.all(Radius.circular(4));
  static const kBorderRadius6 = BorderRadius.all(Radius.circular(6));
  static const kBorderRadius8 = BorderRadius.all(Radius.circular(8));
  static const kBorderRadius10 = BorderRadius.all(Radius.circular(10));
  static const kBorderRadius12 = BorderRadius.all(Radius.circular(12));
  static const kBorderRadius16 = BorderRadius.all(Radius.circular(16));
  static const kBorderRadius20 = BorderRadius.all(Radius.circular(20));
  static const kBorderRadius48 = BorderRadius.all(Radius.circular(48));
  static const kBorderRadius64 = BorderRadius.all(Radius.circular(64));
  static const kBorderRadius100 = BorderRadius.all(Radius.circular(100));
  static const kBorderRadius50 = BorderRadius.all(Radius.circular(50));

  ///SizedBoxHeight
  static const kSizedBox = SizedBox();
  static const kSizedBoxHeight12 = SizedBox(height: 12);
  static const kSizedBoxHeight4 = SizedBox(height: 4);
  static const kSizedBoxHeight2 = SizedBox(height: 2);
  static const kSizedBoxHeight6 = SizedBox(height: 6);

  ///SizedBoxWidth
  static const kSizedBoxWidth8 = SizedBox(width: 8);
  static const kSizedBoxWidth12 = SizedBox(width: 12);

  // static const kTabBarBoxDecoration = BoxDecoration(
  //   color: AppColors.bgGrey2,
  //   borderRadius: kBorderRadius8,
  // );
  // static const kTabBarBoxDecorationDark = BoxDecoration(
  //   color: ThemeColors.backgroundDark,
  //   borderRadius: kBorderRadius8,
  // );
  // static const kTabBoxDecoration = BoxDecoration(
  //   color: AppColors.white,
  //   borderRadius: kBorderRadius8,
  // );
  static Size? _currentSize;

  static setCurrentSize(Size u) {
    _currentSize = u;
  }

  static Size get currentSize => _currentSize ?? const Size(375, 812);

  static void showSnackBar({
    required BuildContext context,
    required String? message,
    required String? title,
  }) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text("Hello"),
    //   ),
    // );
    Flushbar(
      backgroundColor: context.color.alert1,
      backgroundGradient: context.gradients.errorFlushBarGradient,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      margin: const EdgeInsets.all(16),
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
    ).show(context);
  }

  static void showSnackBarSuccess({
    required BuildContext context,
    required String? message,
    required String? title,
  }) {
    Flushbar(
      backgroundColor: Color(0xFF32BC32),
      // backgroundGradient: context.gradients.sliverAppBarGradient,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      margin: const EdgeInsets.all(16),
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
    ).show(context);
  }
}
