import 'package:flutter/material.dart';
import 'battle_theme.dart';

class BattleLevelBadge extends StatelessWidget {
  final int level;
  final double size;

  const BattleLevelBadge({super.key, required this.level, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final color = BattleColors.levelColor(level);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$level',
        style: TextStyle(
          fontSize: size * 0.48,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
