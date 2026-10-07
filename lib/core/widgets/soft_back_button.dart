import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Oq, yumaloq "orqaga" tugmasi (tahrirlash va bildirishnomalar sahifalari uchun)
class SoftBackButton extends StatelessWidget {
  const SoftBackButton({super.key, this.onTap, this.size = 48});

  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.lightImpact();
          if (onTap != null) {
            onTap!();
          } else {
            Navigator.maybePop(context);
          }
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E1A4C).withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 24),
        ),
      ),
    );
  }
}
