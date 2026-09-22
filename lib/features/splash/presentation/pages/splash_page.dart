import 'dart:developer';

import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/features/auth/presentation/page_args/auth_args.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/page_args/screen_lock_args.dart';
import 'package:my_flutter_template/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../../../injector_container.dart';
import '../../../../router/name_routes.dart';
import '../../../screen_lock/presentation/blocs/screen_lock_bloc.dart';
import '../bloc/splash_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localSource = sl<LocalSource>();
      log('Access token: ${localSource.getAccessToken()}');

      if (localSource.getAccessToken() == null) {
        if (sl<LocalSource>().getIsLoggedIn() == null ||
            sl<LocalSource>().getIsLoggedIn() == true) {
          sl<LocalSource>().setIsLoggedIn(false);
          // Navigator.pushReplacementNamed(context, Routes.onBoarding);
          Navigator.pushReplacementNamed(context, Routes.auth);
        } else {
          Navigator.pushReplacementNamed(
            context,
            Routes.auth,
            arguments: AuthPageArgs(),
          );
        }
      } else {
        if (sl<LocalSource>().getPinCode() != null) {
          Navigator.pushReplacementNamed(
            context,
            Routes.screenLock,
            arguments: ScreenLockPageArgs(
              status: ScreenLockStatus.check,
            ),
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            Routes.screenLock,
            arguments: ScreenLockPageArgs(
              status: ScreenLockStatus.create,
            ),
          );
        }
      }
    });
  }

  // @override
  // void initState() {
  //   context.read<SplashBloc>().add(const SplashEvent());
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        // if (state.isTimerFinished) {
        //   final localSource = sl<LocalSource>();
        //   log('Access token: ${localSource.getAccessToken()}');
        //   if (localSource.getAccessToken() == null) {
        //     if (sl<LocalSource>().getIsLoggedIn() == null ||
        //         sl<LocalSource>().getIsLoggedIn() == true) {
        //       sl<LocalSource>().setIsLoggedIn(false);
        //       Navigator.pushReplacementNamed(context, Routes.onBoarding);
        //     } else {
        //       Navigator.pushReplacementNamed(
        //         context,
        //         Routes.auth,
        //         arguments: AuthPageArgs(),
        //       );
        //     }
        //     // Navigator.pushReplacementNamed(context, Routes.onBoarding);
        //     // Navigator.pushReplacementNamed(
        //     //   context,
        //     //   Routes.main,
        //     // );
        //   } else {
        //     if (sl<LocalSource>().getPinCode() != null) {
        //       Navigator.pushReplacementNamed(
        //         context,
        //         Routes.screenLock,
        //         arguments: ScreenLockPageArgs(
        //           status: ScreenLockStatus.check,
        //         ),
        //       );
        //     } else {
        //       Navigator.pushReplacementNamed(
        //         context,
        //         Routes.screenLock,
        //         arguments: ScreenLockPageArgs(
        //           status: ScreenLockStatus.create,
        //         ),
        //       );
        //     }
        //   }
        // }
      },
      child: Scaffold(
        backgroundColor: context.color.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SvgPicture.asset(
              //   Assets.svgSlash,
              //   height: 38,
              //   width: 122,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     // Image.asset(Assets.pngLogo, height: 48, width: 48),
              //     Text(
              //       'IQMATH',
              //       style: context.textStyle.fontSize24FontWeight700.copyWith(
              //         color: context.color.black,
              //         fontSize: 48,
              //       ),
              //     ),
              //   ],
              // ),
              // const Gap(6),
              // TweenAnimationBuilder(
              //   tween: Tween<double>(begin: 0, end: 1),
              //   duration: const Duration(milliseconds: 1550),
              //   child: Container(
              //     height: 4,
              //     decoration: BoxDecoration(
              //       color: context.color.black,
              //     ),
              //   ),
              //   builder: (context, animation, child) => Container(
              //     height: 4,
              //     width: 122,
              //     alignment: Alignment.centerLeft,
              //     decoration: const BoxDecoration(
              //       color: Color(0xFFE0E0E0),
              //     ),
              //     child: FractionallySizedBox(
              //       widthFactor: animation,
              //       child: child,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
