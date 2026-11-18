import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../generated/l10n.dart';
import '../blocs/screen_lock_bloc.dart';
import 'biometrics_widget.dart';
import 'pin_indicator.dart';

const Color _kMuted = Color(0xFF64748B);
const Color _kPrimary = Color(0xFF2563EB);
const Color _kTitle = Color(0xFF0F172A);

/// Sarlavha ostidagi izoh matni (holatga va tilga qarab).
String _subtitle(AppLocalization l, String title, String lang) {
  const texts = {
    'create': {
      'uz': "Ilovani himoya qilish uchun 4 xonali PIN kod o'ylab toping",
      'ru': 'Придумайте 4-значный PIN-код для защиты приложения',
      'en': 'Create a 4-digit PIN code to protect the app',
    },
    'confirm': {
      'uz': 'Tasdiqlash uchun PIN kodni qayta kiriting',
      'ru': 'Повторите PIN-код для подтверждения',
      'en': 'Re-enter your PIN code to confirm',
    },
    'old': {
      'uz': "O'zgartirish uchun joriy PIN kodingizni kiriting",
      'ru': 'Введите текущий PIN-код, чтобы изменить его',
      'en': 'Enter your current PIN code to change it',
    },
    'new': {
      'uz': 'Yangi 4 xonali PIN kodni kiriting',
      'ru': 'Введите новый 4-значный PIN-код',
      'en': 'Enter a new 4-digit PIN code',
    },
    'enter': {
      'uz': 'Hisobingizga kirish uchun PIN kodni kiriting',
      'ru': 'Введите PIN-код, чтобы войти в аккаунт',
      'en': 'Please enter your PIN code to access your account',
    },
  };
  final key = title == l.create_pin
      ? 'create'
      : title == l.confirm_pin
          ? 'confirm'
          : title == l.enter_old_pin_code
              ? 'old'
              : title == l.enter_new_pin_code
                  ? 'new'
                  : 'enter';
  final byLang = texts[key]!;
  return byLang[lang] ?? byLang['uz']!;
}

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
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 76,
          width: 76,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _kPrimary, width: 2.2),
          ),
          child: Transform.rotate(
            angle: -0.6,
            child: const Icon(Icons.vpn_key_rounded, color: _kPrimary, size: 38),
          ),
        ),
        const Gap(22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _kTitle,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const Gap(8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _subtitle(localization, widget.title,
                Localizations.localeOf(context).languageCode),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _kMuted,
              height: 1.4,
            ),
          ),
        ),
        const Gap(26),
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
          ),
        ),
      ),
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
