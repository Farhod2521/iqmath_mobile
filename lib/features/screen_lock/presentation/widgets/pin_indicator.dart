import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

const Color _kPrimary = Color(0xFF2563EB);
const Color _kBoxBg = Color(0xFFF1F5FF);
const Color _kBoxBorder = Color(0xFFE2E8F5);
const Color _kDot = Color(0xFF0F172A);
const Color _kError = Color(0xFFDC3545);

/// 4 ta katak: to'ldirilgani ichida nuqta, navbatdagisi ko'k ramkada.
class PinIndicator extends StatelessWidget {
  final List<int> pin;
  final bool isCorrectPin;

  const PinIndicator({
    Key? key,
    required this.pin,
    required this.isCorrectPin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShakeWidget(
      shakeConstant: ShakeHorizontalConstant1(),
      duration: const Duration(milliseconds: 300),
      autoPlay: !isCorrectPin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final filled = i < pin.length;
          final active = i == pin.length;
          final borderColor = !isCorrectPin
              ? _kError
              : active
                  ? _kPrimary
                  : filled
                      ? _kPrimary.withOpacity(0.35)
                      : _kBoxBorder;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 54,
              width: 46,
              decoration: BoxDecoration(
                color: !isCorrectPin
                    ? const Color(0xFFFFF1F2)
                    : active
                        ? Colors.white
                        : _kBoxBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: active ? 2 : 1.5),
                boxShadow: active && isCorrectPin
                    ? [
                        BoxShadow(
                          color: _kPrimary.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: AnimatedScale(
                  scale: filled ? 1 : 0,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutBack,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrectPin ? _kDot : _kError,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
