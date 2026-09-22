import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../generated/l10n.dart';
import '../blocs/screen_lock_bloc.dart';
import 'biometrics_widget.dart';
import 'pin_indicator.dart';

const Color _kMuted = Color(0xFF64748B);
const Color _kPrimary = Color(0xFF2563EB);

class ScreenLockUpperLayout extends StatefulWidget {
  final String title;
  final List<int> pin;
  final bool? isBiometricsEnabled;
  final bool isCorrectPin;
  final int failedAttempts;
  final VoidCallback? onForgotPin;

  const ScreenLockUpperLayout(
      {super.key,
      required this.title,
      required this.pin,
      required this.isCorrectPin,
      this.isBiometricsEnabled,
      this.failedAttempts = 0,
      this.onForgotPin});

  @override
  State<ScreenLockUpperLayout> createState() => _ScreenLockUpperLayoutState();
}

class _ScreenLockUpperLayoutState extends State<ScreenLockUpperLayout> {
  var biometricsEnabled = false;
  late ScreenLockBloc screenLockBloc;
  late AppLocalization localization;

  @override
  void initState() {
    biometricsEnabled = widget.isBiometricsEnabled ?? false;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    screenLockBloc = context.read<ScreenLockBloc>();
    localization = AppLocalization.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _kMuted,
          ),
        ),
        const Gap(28),
        PinIndicator(
          isCorrectPin: widget.isCorrectPin,
          pin: widget.pin,
        ),
        const Gap(16),
        if (widget.failedAttempts > 0)
          AnimatedOpacity(
            opacity: widget.failedAttempts > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.failedAttempts >= 4
                    ? const Color(0xFFFFE9EA)
                    : const Color(0xFFEFF3FB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${5 - widget.failedAttempts} ta urinish qoldi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.failedAttempts >= 4
                      ? const Color(0xFFDC3545)
                      : _kMuted,
                ),
              ),
            ),
          ),
        if (widget.onForgotPin != null) ...[
          const Gap(20),
          GestureDetector(
            onTap: widget.onForgotPin,
            child: Text(
              localization.forgot_pin,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _kPrimary,
              ),
            ),
          ),
        ],
        if (widget.isBiometricsEnabled != null)
          if (!widget.isBiometricsEnabled!)
            const Gap(34)
          else if (widget.title == localization.create_pin)
            const Gap(34),
        if (widget.isBiometricsEnabled != null)
          if (!widget.isBiometricsEnabled!)
            BiometricsWidget(
              value: biometricsEnabled,
              onChanged: (value) {
                if (widget.title == localization.enter_pin &&
                    !widget.isBiometricsEnabled!) {
                  setState(() {
                    biometricsEnabled = value;
                  });
                } else {
                  context.read<ScreenLockBloc>().add(
                        ScreenLockSetBioMetrics(value),
                      );
                }
              },
            )
          else if (widget.title == localization.create_pin)
            BiometricsWidget(
              value: biometricsEnabled,
              onChanged: (value) {
                setState(() {
                  biometricsEnabled = value;
                });
              },
            ),
      ],
    );
  }

  @override
  void dispose() {
    if (widget.title == localization.enter_pin ||
        widget.title == localization.create_pin) {
      screenLockBloc.add(
        ScreenLockSetBioMetrics(biometricsEnabled),
      );
    }
    super.dispose();
  }
}
