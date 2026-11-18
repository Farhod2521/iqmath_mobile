import 'package:my_flutter_template/features/screen_lock/presentation/blocs/screen_lock_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color _kPrimary = Color(0xFF2563EB);
const Color _kKeyBg = Color(0xFFEEF3FF);
const Color _kKeyText = Color(0xFF0F172A);
const Color _kIcon = Color(0xFF475569);

/// Dumaloq raqam tugmasi: oddiy holatda och ko'k, bosilganda to'q ko'k + oq raqam.
class ButtonItem extends StatefulWidget {
  final int? number;
  final String? icon;
  final VoidCallback? onTap;
  final ScreenLockStatus? status;

  const ButtonItem({Key? key, this.number, this.icon, this.onTap, this.status})
      : super(key: key);

  @override
  State<ButtonItem> createState() => _ButtonItemState();
}

class _ButtonItemState extends State<ButtonItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (widget.onTap != null) {
      widget.onTap!();
    } else if (widget.number != null && widget.status != null) {
      context.read<ScreenLockBloc>().add(
            ScreenLockNumberTapped(
              number: widget.number!,
              status: widget.status!,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBackspace = widget.icon != null;
    final isEmpty = widget.number == null && widget.icon == null;
    if (isEmpty) return const SizedBox(width: 72, height: 72);

    // Backspace bosilganda ko'k bo'lmaydi — faqat biroz quyuqlashadi
    final bg = _pressed
        ? (isBackspace ? const Color(0xFFDDE6FB) : _kPrimary)
        : (isBackspace ? Colors.transparent : _kKeyBg);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 90), () {
          if (mounted) _setPressed(false);
        });
      },
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          boxShadow: _pressed && !isBackspace
              ? [
                  BoxShadow(
                    color: _kPrimary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isBackspace
              ? SvgPicture.asset(
                  widget.icon!,
                  fit: BoxFit.scaleDown,
                  colorFilter: const ColorFilter.mode(_kIcon, BlendMode.srcIn),
                  height: 26,
                  width: 26,
                )
              : AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 110),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: _pressed ? Colors.white : _kKeyText,
                    height: 1,
                  ),
                  child: Text(widget.number.toString()),
                ),
        ),
      ),
    );
  }
}
