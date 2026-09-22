import 'dart:async';

import 'package:my_flutter_template/features/screen_lock/presentation/widgets/screen_lock_upper_layout.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';
import '../../../../router/name_routes.dart';
import '../../../../services/local_auth_service.dart';
import '../blocs/screen_lock_bloc.dart';

class CheckScreenLock extends StatefulWidget {
  const CheckScreenLock({super.key});

  @override
  State<CheckScreenLock> createState() => _CheckScreenLockState();
}

class _CheckScreenLockState extends State<CheckScreenLock> {
  bool _biometricsChecked = false;

  @override
  void initState() {
    super.initState();

    // Darhol biometrics holatini o'qib, state ga qo'shamiz
    final localSource = sl<LocalSource>();
    final isBiometricsOn = localSource.getBiometricsOn() ?? false;

    if (isBiometricsOn) {
      // State ni darhol yangilaymiz (UI render bo'lishidan oldin)
      context.read<ScreenLockBloc>().add(const ScreenLockSetBioMetrics(true));
    }

    // UI tayyor bo'lgandan keyin biometrics autentifikatsiyasini boshlash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _checkBiometrics();
        }
      });
    });
  }

  void _checkBiometrics() async {
    if (_biometricsChecked) return;
    _biometricsChecked = true;

    final localSource = sl<LocalSource>();
    final isBiometricsOn = localSource.getBiometricsOn() ?? false;

    if (isBiometricsOn && mounted) {
      // Biometrics autentifikatsiyasini boshlash
      sl<LocalAuthService>().authenticate(context).then(
        (biometrics) {
          if (biometrics && mounted) {
            if (localSource.getUserRole() == 'student') {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.main, (route) => false);
            } else if (localSource.getUserRole() == 'parent') {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.mainParent, (route) => false);
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localSource = sl<LocalSource>();
    final localization = AppLocalization.of(context);
    return BlocConsumer<ScreenLockBloc, ScreenLockState>(
      listener: (context, state) {
        if (state is ScreenLockCheckState) {
          // 5 ta xato — logout qilish
          if (state.failedAttempts >= 5) {
            Timer(const Duration(milliseconds: 400), () async {
              if (mounted) {
                await localSource.clear();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.auth, (route) => false);
              }
            });
            return;
          }

          if (!state.isCorrectPin) {
            Timer(
              const Duration(milliseconds: 300),
              () {
                if (mounted) {
                  context.read<ScreenLockBloc>().add(
                        const ScreenLockSetErrorEvent(
                          isCorrectPin: true,
                          status: ScreenLockStatus.check,
                        ),
                      );
                }
              },
            );
          }
          if (state.pinCode?.length == 4) {
            if (localSource.getPinCode() == state.pinCode.toString()) {
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
            } else {
              context.read<ScreenLockBloc>().add(
                    const ScreenLockSetErrorEvent(
                      isCorrectPin: false,
                      status: ScreenLockStatus.check,
                    ),
                  );
            }
          }
        }
      },
      builder: (context, state) {
        if (state is ScreenLockCheckState) {
          return ScreenLockUpperLayout(
            isCorrectPin: state.isCorrectPin,
            title: localization.enter_pin,
            pin: state.pinCode ?? [],
            isBiometricsEnabled: state.isBiometricsEnabled,
            failedAttempts: state.failedAttempts,
            onForgotPin: () async {
              await localSource.clear();
              if (mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.auth, (route) => false);
              }
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
