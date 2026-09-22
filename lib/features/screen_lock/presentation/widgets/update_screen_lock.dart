import 'dart:async';

import 'package:my_flutter_template/features/screen_lock/presentation/widgets/screen_lock_upper_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../generated/l10n.dart';
import '../../../../injector_container.dart';
import '../../../../router/name_routes.dart';
import '../blocs/screen_lock_bloc.dart';

class UpdateScreenLock extends StatefulWidget {
  const UpdateScreenLock({super.key});

  @override
  State<UpdateScreenLock> createState() => _UpdateScreenLockState();
}

class _UpdateScreenLockState extends State<UpdateScreenLock> {
  final PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final localSource = sl<LocalSource>();
    return BlocConsumer<ScreenLockBloc, ScreenLockState>(
      listener: (context, state) {
        if (state is ScreenLockUpdateState) {
          if (!state.isCorrectPin) {
            Timer(
              const Duration(milliseconds: 300),
              () {
                context.read<ScreenLockBloc>().add(
                      const ScreenLockSetErrorEvent(
                        isCorrectPin: true,
                        status: ScreenLockStatus.update,
                      ),
                    );
              },
            );
          } else {
            final isFirstPageEnd = state.oldPinCode != null &&
                state.oldPinCode?.length == 4 &&
                (state.newPinCode == null) &&
                (state.confirmPinCode == null);
            final isSecondPageEnd = state.newPinCode != null &&
                state.newPinCode?.length == 4 &&
                (state.confirmPinCode == null);
            final isThirdPageEnd = state.confirmPinCode != null &&
                state.confirmPinCode?.length == 4;
            if (isThirdPageEnd) {
              if (listEquals(state.newPinCode, state.confirmPinCode)) {
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
                localSource.setPinCode(state.newPinCode.toString());
              } else {
                context.read<ScreenLockBloc>().add(
                      const ScreenLockSetErrorEvent(
                        isCorrectPin: false,
                        status: ScreenLockStatus.update,
                      ),
                    );
              }
            } else if (isSecondPageEnd) {
              ///TODO: We need to check if the new pin code is different from the old one
              pageController.nextPage(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            } else if (isFirstPageEnd) {
              if (state.oldPinCode.toString() == localSource.getPinCode()) {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              } else {
                context.read<ScreenLockBloc>().add(
                      const ScreenLockSetErrorEvent(
                        isCorrectPin: false,
                        status: ScreenLockStatus.update,
                      ),
                    );
              }
            }
          }
        }
      },
      builder: (context, state) {
        if (state is ScreenLockUpdateState) {
          return PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ScreenLockUpperLayout(
                isCorrectPin: state.isCorrectPin,
                title: localization.enter_old_pin_code,
                pin: state.oldPinCode ?? [],
              ),
              ScreenLockUpperLayout(
                isCorrectPin: state.isCorrectPin,
                title: localization.enter_new_pin_code,
                pin: state.newPinCode ?? [],
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