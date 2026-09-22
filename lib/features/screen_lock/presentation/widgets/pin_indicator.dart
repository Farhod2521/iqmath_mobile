import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

const Color _kPrimary = Color(0xFF2563EB);
const Color _kDotEmpty = Color(0xFFD7DCE7);
const Color _kError = Color(0xFFDC3545);

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
          final color = !isCorrectPin
              ? _kError
              : filled
                  ? _kPrimary
                  : Colors.transparent;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: !isCorrectPin
                      ? _kError
                      : filled
                          ? _kPrimary
                          : _kDotEmpty,
                  width: 2,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
