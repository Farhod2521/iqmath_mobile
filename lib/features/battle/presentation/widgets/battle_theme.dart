import 'package:flutter/material.dart';

/// Battle funksiyasi uchun umumiy rang palitrasi — veb ilovadagi
/// indigo-asosli mavzuga mos.
class BattleColors {
  static const Color primary = Color(0xFF6366F1); // indigo-500
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color purple = Color(0xFFA855F7);
  static const Color rose = Color(0xFFF43F5E);
  static const Color win = Color(0xFFF59E0B); // amber
  static const Color loss = Color(0xFF9CA3AF); // gray
  static const Color draw = Color(0xFF6366F1); // indigo
  static const Color historyWin = Color(0xFF10B981); // emerald
  static const Color historyLoss = Color(0xFFEF4444); // red
  static const Color ink = Color(0xFF191C1D);
  static const Color muted = Color(0xFF8A8A8E);
  static const Color background = Color(0xFFF7FAFE);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFF0F0F0);

  // A/B/C/D javob variantlari uchun ranglar (veb bilan bir xil)
  static const List<Color> choiceColors = [
    Color(0xFF3B82F6), // blue
    Color(0xFFA855F7), // purple
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
  ];

  // 1..10 daraja uchun rang ramp'i (BattleLevelBadge'dagi LEVEL_COLORS bilan bir xil)
  static const Map<int, Color> levelColors = {
    1: Color(0xFF9CA3AF),
    2: Color(0xFF22C55E),
    3: Color(0xFF16A34A),
    4: Color(0xFF0EA5E9),
    5: Color(0xFF2563EB),
    6: Color(0xFF7C3AED),
    7: Color(0xFFA855F7),
    8: Color(0xFFF97316),
    9: Color(0xFFEA580C),
    10: Color(0xFFF59E0B),
  };

  static Color levelColor(int level) =>
      levelColors[level.clamp(1, 10)] ?? primary;

  // Ismning bosh harfi kodiga qarab tanlangan avatar gradienti
  static const List<List<Color>> avatarGradients = [
    [Color(0xFF3B82F6), Color(0xFF6366F1)],
    [Color(0xFF8B5CF6), Color(0xFFA855F7)],
    [Color(0xFFEC4899), Color(0xFFF43F5E)],
    [Color(0xFF10B981), Color(0xFF14B8A6)],
    [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
    [Color(0xFF6366F1), Color(0xFF4F46E5)],
    [Color(0xFFF43F5E), Color(0xFFEF4444)],
    [Color(0xFF14B8A6), Color(0xFF10B981)],
  ];

  static List<Color> avatarGradientFor(String name) {
    final code = name.isNotEmpty ? name.codeUnitAt(0) : 0;
    return avatarGradients[code % avatarGradients.length];
  }
}
