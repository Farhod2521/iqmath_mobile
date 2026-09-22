import 'dart:async';

import 'package:my_flutter_template/features/screen_lock/presentation/widgets/screen_lock_upper_layout.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';
import '../../../../router/name_routes.dart';
import '../blocs/screen_lock_bloc.dart';

class CreateScreenLock extends StatefulWidget {
  const CreateScreenLock({super.key});

  @override
  State<CreateScreenLock> createState() => _CreateScreenLockState();
}

class _CreateScreenLockState extends State<CreateScreenLock> {
  final PageController pageController = PageController(initialPage: 0);
  final localSource = sl<LocalSource>();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return BlocConsumer<ScreenLockBloc, ScreenLockState>(
      listener: (context, state) {
        if (state is ScreenLockCreateState) {
          if (!state.isCorrectPin) {
            Timer(
              const Duration(milliseconds: 300),
              () {
                context.read<ScreenLockBloc>().add(
                      const ScreenLockSetErrorEvent(
                        isCorrectPin: true,
                        status: ScreenLockStatus.create,
                      ),
                    );
              },
            );
          }
          final isFirstPageEnded =
              (state.pinCode?.length == 4 && (state.confirmPinCode == null));
          final isSecondPageEnded = (state.confirmPinCode?.length == 4);
          if (isFirstPageEnded) {
            pageController.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          } else if (isSecondPageEnded) {
            if (listEquals(state.pinCode, state.confirmPinCode)) {
              debugPrint('PIN codes match. Saving PIN code.');
              if (Navigator.canPop(context)) {
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              } else {
                // Navigator.pushReplacementNamed(context, Routes.main);
                if (localSource.getUserRole() == 'student') {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.main, (route) => false);
                } else if (localSource.getUserRole() == 'parent') {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.mainParent, (route) => false);
                } else if (localSource.getUserRole() == 'tutor') {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.mainTeacher, (route) => false);
                }
              }
              sl<LocalSource>().setPinCode(state.pinCode.toString());
            } else {
              context.read<ScreenLockBloc>().add(
                    const ScreenLockSetErrorEvent(
                      isCorrectPin: false,
                      status: ScreenLockStatus.create,
                    ),
                  );
            }
          }
        }
      },
      builder: (context, state) {
        if (state is ScreenLockCreateState) {
          return PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ScreenLockUpperLayout(
                isCorrectPin: state.isCorrectPin,
                title: localization.create_pin,
                pin: state.pinCode ?? [],
                isBiometricsEnabled: state.isBiometricsEnabled,
              ),
              ScreenLockUpperLayout(
                isCorrectPin: state.isCorrectPin,
                title: localization.confirm_pin,
                pin: state.confirmPinCode ?? [],
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
