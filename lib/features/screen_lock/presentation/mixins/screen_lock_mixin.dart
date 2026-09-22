// import 'dart:async';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/local_source/local_source.dart';
// import '../../../../injector_container.dart';
// import '../../../../router/name_routes.dart';
// import '../../../../services/local_auth_service.dart';
// import '../blocs/screen_lock_bloc.dart';
//
// mixin ScreenLockMixin {
//   void listenerHandler(BuildContext context, ScreenLockState state,
//       PageController pageController) {
//     if (!state.isCorrectPin) {
//       Timer(const Duration(milliseconds: 300), () {
//         context.read<ScreenLockBloc>().add(
//               const ScreenLockSetErrorEvent(isCorrectPin: true),
//             );
//       });
//     }
//     switch (state.status) {
//       case ScreenLockStatus.create:
//         createPinHandler(context, state, pageController);
//         break;
//       case ScreenLockStatus.confirm:
//         confirmPinHandler(context, state, pageController);
//         break;
//       case ScreenLockStatus.check:
//         checkPinHandler(context, state, pageController);
//         break;
//     }
//   }
//
//   void biometricsListenerHandler(BuildContext context, ScreenLockState state) {
//     if (state.isBiometricsEnabled && state.status.isCheck) {
//       checkBiometrics(context);
//     }
//   }
//
//   void createPinHandler(BuildContext context, ScreenLockState state,
//       PageController pageController) {
//     pageController.animateToPage(
//       state.status.index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeIn,
//     );
//     if (state.pinCode != null && state.pinCode!.length == 4) {
//       pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeIn,
//       );
//     }
//   }
//
//   void confirmPinHandler(BuildContext context, ScreenLockState state,
//       PageController pageController) {
//     if (state.confirmPinCode != null && state.confirmPinCode!.length == 4) {
//       if (listEquals(state.pinCode, state.confirmPinCode)) {
//         final localSource = sl<LocalSource>();
//         localSource.setPinCode(state.pinCode.toString());
//         Navigator.of(context)
//             .pushNamedAndRemoveUntil(Routes.main, (route) => false);
//       } else {
//         HapticFeedback.mediumImpact();
//         context.read<ScreenLockBloc>().add(
//               const ScreenLockSetErrorEvent(
//                 isCorrectPin: false,
//                 fromConfirm: true,
//               ),
//             );
//       }
//     }
//   }
//
//   void checkPinHandler(BuildContext context, ScreenLockState state,
//       PageController pageController) {
//     if (state.pinCode != null && state.pinCode!.length == 4) {
//       final localSource = sl<LocalSource>();
//       if (state.pinCode.toString() == localSource.getPinCode()) {
//         Navigator.of(context)
//             .pushNamedAndRemoveUntil(Routes.main, (route) => false);
//       } else {
//         HapticFeedback.mediumImpact();
//         context.read<ScreenLockBloc>().add(
//               const ScreenLockSetErrorEvent(isCorrectPin: false),
//             );
//       }
//     }
//   }
//
//   void checkBiometrics(BuildContext context) {
//     sl<LocalAuthService>().authenticate(context).then(
//       (biometrics) {
//         if (biometrics) {
//           Navigator.of(context)
//               .pushNamedAndRemoveUntil(Routes.main, (route) => false);
//         } else {
//           context.read<ScreenLockBloc>().add(
//                 ScreenLockSetBioMetrics(biometrics),
//               );
//         }
//       },
//     );
//   }
// }
