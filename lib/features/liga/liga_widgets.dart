import 'package:flutter/material.dart';

/// Liga ranglari — saytdagi (#1F7AEC, #191C1D, #64748B ...) bilan bir xil
class LigaColors {
  static const primary = Color(0xFF1F7AEC);
  static const primarySoft = Color(0xFFEAF3FF);
  static const ink = Color(0xFF191C1D);
  static const muted = Color(0xFF64748B);
  static const text = Color(0xFF475569);
  static const border = Color(0xFFE6ECF7);
  static const rowBorder = Color(0xFFE3EAF6);
  static const soft = Color(0xFFF7FAFE);
  static const chip = Color(0xFFF1F5FB);
  static const bg = Color(0xFFF5F8FE);
  static const green = Color(0xFF15803D);
  static const greenSoft = Color(0xFFE7F8EF);
  static const red = Color(0xFFDC2626);
  static const redSoft = Color(0xFFFEECEC);
  static const amber = Color(0xFFF59E0B);
  static const teal = Color(0xFF13A97F);
}

/// Oq, yumaloq, yengil ko'k soyali karta (saytdagi CARD)
class LigaCard extends StatelessWidget {
  const LigaCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LigaColors.border),
        boxShadow: [
          BoxShadow(color: LigaColors.primary.withOpacity(0.10), blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      child: child,
    );
  }
}

/// Karta sarlavhasi: ko'k kvadrat ikonka + sarlavha + izoh (+ o'ngda tugma)
class LigaCardHead extends StatelessWidget {
  const LigaCardHead({super.key, required this.icon, required this.title, this.text, this.trailing});

  final IconData icon;
  final String title;
  final String? text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LigaIconBox(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: LigaColors.ink)),
              if (text != null)
                Text(text!, style: const TextStyle(fontSize: 13, color: LigaColors.muted, height: 1.3)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class LigaIconBox extends StatelessWidget {
  const LigaIconBox({super.key, required this.icon, this.size = 44, this.color = LigaColors.primary, this.bg = LigaColors.primarySoft});

  final IconData icon;
  final double size;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.32)),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// O'rin medali: 1 — oltin, 2 — kumush, 3 — bronza, qolganlari kulrang
class LigaMedal extends StatelessWidget {
  const LigaMedal({super.key, required this.place, this.size = 34});

  final int place;
  final double size;

  static const _gradients = [
    [Color(0xFFFDE68A), Color(0xFFF59E0B)],
    [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
    [Color(0xFFFDBA74), Color(0xFFC2410C)],
  ];

  @override
  Widget build(BuildContext context) {
    final medal = place >= 1 && place <= 3;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: medal ? null : const Color(0xFFEEF3FA),
        gradient: medal
            ? LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: _gradients[place - 1])
            : null,
      ),
      child: Text(
        '$place',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: medal ? Colors.white : LigaColors.muted),
      ),
    );
  }
}

/// Sahifa boshi: ikonka, sarlavha, izoh va o'ngda kubok rasmi (saytdagi LigaHero)
class LigaHero extends StatelessWidget {
  const LigaHero({super.key, required this.title, required this.subtitle, this.onBack});

  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, Color(0xFFEFF5FF), Color(0xFFDDEAFF)],
        ),
        border: Border.all(color: LigaColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: 0,
            bottom: 0,
            child: ShaderMask(
              // Rasm chapga qarab yumshoq so'nadi
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.center,
                colors: [Colors.transparent, Colors.black],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Image.asset('assets/images/liga_student_hero.webp', fit: BoxFit.cover, width: 220),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 120, 14),
            child: Row(
              children: [
                if (onBack != null) ...[
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onBack,
                      child: const Padding(
                        padding: EdgeInsets.all(9),
                        child: Icon(Icons.arrow_back_rounded, size: 22, color: LigaColors.ink),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else ...[
                  const LigaIconBox(icon: Icons.emoji_events_outlined, size: 52),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: LigaColors.ink, height: 1.15)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 13.5, color: LigaColors.text)),
                    ],
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

/// Asosiy ko'k tugma
class LigaButton extends StatelessWidget {
  const LigaButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.arrow_forward_rounded,
    this.color = LigaColors.primary,
    this.textColor = Colors.white,
    this.busy = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final bool busy;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = ElevatedButton(
      onPressed: busy ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        disabledBackgroundColor: color.withOpacity(0.6),
        elevation: 0,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: busy
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                if (icon != null) ...[const SizedBox(width: 6), Icon(icon, size: 18)],
              ],
            ),
    );
    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}

/// Saytdagi LigaDialog: ikonka, sarlavha, matn va tugmalar. true — tasdiqlandi.
Future<bool> showLigaDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? text,
  Widget? body,
  required String confirmLabel,
  String? cancelLabel,
  bool danger = false,
}) async {
  final color = danger ? LigaColors.red : LigaColors.primary;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LigaIconBox(icon: icon, size: 52, color: color, bg: danger ? LigaColors.redSoft : LigaColors.primarySoft),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: LigaColors.ink)),
            if (text != null) ...[
              const SizedBox(height: 8),
              Text(text, style: const TextStyle(fontSize: 14, color: LigaColors.text, height: 1.45)),
            ],
            if (body != null) ...[const SizedBox(height: 12), body],
            const SizedBox(height: 18),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        side: const BorderSide(color: Color(0xFFDFE6F2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(cancelLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: LigaButton(
                    label: confirmLabel,
                    icon: null,
                    color: color,
                    expand: true,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result == true;
}

/// O'quvchi ismi va ID'si suv belgisi (saytdagi LigaGuard): skrinshot tarqalsa, kimniki ekani bilinadi
class LigaWatermark extends StatelessWidget {
  const LigaWatermark({super.key, required this.viewer, required this.child});

  final String? viewer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (viewer == null || viewer!.isEmpty) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRect(
              child: Transform.rotate(
                angle: -0.21,
                child: OverflowBox(
                  maxWidth: 900,
                  maxHeight: 2400,
                  child: SizedBox(
                    width: 900,
                    height: 2400,
                    child: Wrap(
                    spacing: 60,
                    runSpacing: 90,
                    children: List.generate(
                      80,
                      (_) => Text(
                        viewer!,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: LigaColors.ink.withOpacity(0.06)),
                      ),
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
