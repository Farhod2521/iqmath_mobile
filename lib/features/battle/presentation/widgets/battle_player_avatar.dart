import 'package:flutter/material.dart';
import 'battle_level_badge.dart';
import 'battle_theme.dart';

class BattlePlayerAvatar extends StatelessWidget {
  final String name;
  final int? level;
  final double size;

  const BattlePlayerAvatar({
    super.key,
    required this.name,
    this.level,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = BattleColors.avatarGradientFor(name);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        if (level != null)
          Positioned(
            right: -2,
            bottom: -2,
            child: BattleLevelBadge(level: level!, size: size * 0.4),
          ),
      ],
    );
  }
}
