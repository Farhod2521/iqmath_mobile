import 'package:another_flushbar/flushbar.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/theme/colors/app_gradients.dart';
import 'package:my_flutter_template/core/utils/app_utils.dart';
import 'package:my_flutter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../../router/name_routes.dart';
import '../../../screen_lock/presentation/blocs/screen_lock_bloc.dart';
import '../../../screen_lock/presentation/page_args/screen_lock_args.dart';

mixin AuthPageMixin {
  // Function() authButtonOnPressed({
  //   required BuildContext context,
  //   required AuthState state,
  // }) {
  //   return () {
  //     FocusScope.of(context).unfocus();
  //     switch (state.status) {
  //       case AuthStatus.phoneNumber:
  //         context.read<AuthBloc>().add(
  //               const AuthPhoneNumberButtonClickEvent(),
  //             );
  //         break;
  //       case AuthStatus.nameEnter:
  //         context.read<AuthBloc>().add(const AuthNameButtonClickEvent());
  //         break;
  //       case AuthStatus.smsCode:
  //         context.read<AuthBloc>().add(const AuthSmsCodeButtonClickEvent());
  //         break;
  //     }
  //   };
  // }

  void authListener({
    required BuildContext context,
    required AuthState state,
    // required PageController pageController,
  }) {
    final localization = AppLocalization.of(context);
    switch (state.status) {
      // case AuthStatus.phoneNumber:
      //   if (state.stateStatus.isSuccess) {
      //     if (state.isUserExists) {
      //       pageController.animateToPage(
      //         2,
      //         duration: const Duration(milliseconds: 300),
      //         curve: Curves.linear,
      //       );
      //     } else {
      //       pageController.nextPage(
      //         duration: const Duration(milliseconds: 300),
      //         curve: Curves.linear,
      //       );
      //     }
      //   } else if (state.stateStatus.isError) {
      //     AppUtils.showSnackBar(
      //       context: context,
      //       message: state.errorMessage?.message ?? 'empty',
      //       title: state.errorMessage?.title ?? 'empty',
      //     );
      //   }
      //   break;
      // case AuthStatus.nameEnter:
      //   if (state.stateStatus.isSuccess) {
      //     pageController.nextPage(
      //       duration: const Duration(milliseconds: 300),
      //       curve: Curves.linear,
      //     );
      //   } else if (state.stateStatus.isError) {
      //     AppUtils.showSnackBar(
      //       context: context,
      //       message: localization.please_fill,
      //       title: '',
      //     );
      //   }
      //   break;
      case AuthStatus.smsCode:
        if (state.stateStatus.isSuccess) {
          Navigator.of(mainRootNavigatorKey.currentContext!)
              .pushReplacementNamed(
            Routes.screenLock,
            arguments: ScreenLockPageArgs(
              status: ScreenLockStatus.create,
            ),
          );
        } else if (state.stateStatus.isError) {
          AppUtils.showSnackBar(
            context: context,
            message: state.errorMessage?.message ?? 'empty',
            title: state.errorMessage?.title ?? 'empty',
          );
        }
        break;
      case AuthStatus.phoneNumber:
        // TODO: Handle this case.
        throw UnimplementedError();
      case AuthStatus.nameEnter:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  bool checkAuthButton(AuthState state) {
    switch (state.status) {
      case AuthStatus.phoneNumber:
        return state.phoneNumber?.length == 9;
      case AuthStatus.nameEnter:
        return state.firstName != null &&
            state.surname != null &&
            state.firstName!.isNotEmpty &&
            state.surname!.isNotEmpty;
      case AuthStatus.smsCode:
        return state.smsCode != null && state.smsCode!.isNotEmpty;
      }
  }
}
