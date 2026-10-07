import 'package:flutter/material.dart';

/// O'quvchi statistikasi kartasi: Streak, Ball, Tanga, So'm.
/// Har biri o'z rangli bo'lagida, 3D rasm bilan (assets/images/stat_*.webp).
/// `null` qiymat — hali yuklanmoqda ("…" ko'rsatiladi).
class StudentStatsCard extends StatelessWidget {
  const StudentStatsCard({
    super.key,
    required this.locale,
    this.streak,
    this.score,
    this.coin,
    this.sum,
    this.onTap,
  });

  final String locale;
  final int? streak;
  final int? score;
  final int? coin;
  final int? sum;
  final VoidCallback? onTap;

  static const _uz = {'streak': 'Streak', 'ball': 'Ball', 'coin': 'Tanga', 'sum': "so'm"};
  static const _ru = {'streak': 'Серия', 'ball': 'Балл', 'coin': 'Монеты', 'sum': 'сум'};

  String _label(String key) => (locale == 'ru' ? _ru : _uz)[key] ?? key;

  /// 1250000 -> "1 250 000"
  static String formatNumber(int? value) {
    if (value == null) return '…';
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatTile(
                image: 'assets/images/stat_fire.webp',
                value: formatNumber(streak),
                label: _label('streak'),
                colors: const [Color(0xFFFFE9DE), Color(0xFFFFF5EE)],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _StatTile(
                image: 'assets/images/stat_ball.webp',
                value: formatNumber(score),
                label: _label('ball'),
                colors: const [Color(0xFFFFF3D2), Color(0xFFFFFAEB)],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _StatTile(
                image: 'assets/images/stat_coins.webp',
                value: formatNumber(coin),
                label: _label('coin'),
                colors: const [Color(0xFFEFE7FF), Color(0xFFF7F2FF)],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _StatTile(
                image: 'assets/images/stat_money.webp',
                value: formatNumber(sum),
                label: _label('sum'),
                colors: const [Color(0xFFE3F0FF), Color(0xFFF1F7FF)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.image,
    required this.value,
    required this.label,
    required this.colors,
  });

  final String image;
  final String value;
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            image,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Katta sonlar (masalan 1 250 000) sig'ishi uchun kichrayadi
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B1324),
                      height: 1.1,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5B6476),
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
