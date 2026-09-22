import 'package:my_flutter_template/core/theme/app_text_style.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/blocs/screen_lock_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ButtonItem extends StatelessWidget {
  final int? number;
  final String? icon;
  final VoidCallback? onTap;
  final ScreenLockStatus? status;

  const ButtonItem(
      {Key? key, this.number, this.icon, this.onTap, this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBackspace = icon != null;
    final isEmpty = number == null && icon == null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else if (number != null && status != null) {
          context.read<ScreenLockBloc>().add(
                ScreenLockNumberTapped(
                  number: number!,
                  status: status!,
                ),
              );
        }
      },
      child: Container(
        height: 68,
        width: 68,
        decoration: isEmpty
            ? null
            : const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F3F9),
              ),
        child: isEmpty
            ? const SizedBox.shrink()
            : Center(
                child: isBackspace
                    ? SvgPicture.asset(
                        icon!,
                        fit: BoxFit.scaleDown,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF64748B),
                          BlendMode.srcIn,
                        ),
                        height: 24,
                        width: 24,
                      )
                    : Text(
                        number.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          height: 1,
                        ),
                      ),
              ),
      ),
    );
  }
}
