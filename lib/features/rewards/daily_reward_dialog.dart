import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/dash_ui.dart';
import 'confetti_overlay.dart';
import 'rewards_api.dart';
import 'rewards_texts.dart';

const _ink = Color(0xFF0B1B3F);
const _blue = Color(0xFF1D6BFF);
const _green = Color(0xFF22C55E);
const _amber = Color(0xFFF59E0B);
const _muted = Color(0xFF64748B);

/// Kundalik kirish mukofoti: ilova ochilganda bugungi +1 gol avtomatik olinadi ("olish" tugmasi yo'q).
/// Gol qo'shilgan bo'lsa — oyna ochiladi va konfetti sochiladi. Bugun allaqachon olingan bo'lsa — hech narsa.
/// Ilova sessiyasida bir marta tekshiriladi; backend takroriy so'rovda gol qo'shmaydi.
class DailyReward {
  DailyReward._();

  static bool _checked = false;

  static Future<void> claimAndShow(BuildContext context, String locale) async {
    if (_checked || !TariffService.isStudent) return;
    _checked = true;
    try {
      final data = await RewardsApi.claimDaily();
      final awarded = asInt(data['awarded']);
      if (awarded <= 0 || !context.mounted) return;
      HapticFeedback.mediumImpact();
      await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'daily-reward',
        barrierColor: const Color(0xFF0B1B3F).withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => _DailyRewardView(data: data, awarded: awarded, locale: locale),
        transitionBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(curved), child: child),
          );
        },
      );
    } catch (_) {
      // Tarmoq xatosi — keyingi ochilishda yana urinib ko'riladi
      _checked = false;
    }
  }

  /// Chiqib, boshqa hisob bilan kirganda qayta tekshirilishi uchun
  static void reset() => _checked = false;
}

class _DailyRewardView extends StatelessWidget {
  const _DailyRewardView({required this.data, required this.awarded, required this.locale});

  final Map<String, dynamic> data;
  final int awarded;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final days = asMapList(data['days']);
    final todayDay = asInt(data['today_day']);
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF7FAFF), Colors.white, Color(0xFFEEF4FF)],
                    ),
                    boxShadow: [
                      BoxShadow(color: _ink.withOpacity(0.25), blurRadius: 40, offset: const Offset(0, 18)),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _badge(),
                            const Spacer(),
                            _closeButton(context),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Image.asset(
                            'assets/images/daily_reward_calendar.webp',
                            height: 130,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox(height: 8),
                          ),
                        ),
                        Text(
                          rt(locale, 'congrats'),
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _ink, height: 1.15),
                        ),
                        Text(
                          rtf(locale, 'todayGot', awarded),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _blue, height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rt(locale, 'rewardSub'),
                          style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
                        ),
                        const SizedBox(height: 18),
                        _DaysRow(days: days, todayDay: todayDay, locale: locale),
                        const SizedBox(height: 16),
                        _stats(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(rt(locale, 'continue'),
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 22),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            rt(locale, 'tomorrow'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: _muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Konfetti oyna ustida — bosishni to'smaydi
        const Positioned.fill(child: ConfettiOverlay()),
      ],
    );
  }

  Widget _badge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFE6EEFF), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_available_rounded, size: 17, color: Color(0xFF1D4ED8)),
          const SizedBox(width: 6),
          Text(rt(locale, 'badge'),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
        ],
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(20),
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.close_rounded, size: 26, color: _muted),
      ),
    );
  }

  Widget _stats() {
    Widget cell(IconData icon, Color color, String label, String value) => Expanded(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                    Text(value,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                  ],
                ),
              ),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFEAF1FC), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          cell(Icons.sports_soccer_rounded, _ink, rt(locale, 'streak'), rtf(locale, 'streakValue', asInt(data['streak']))),
          Container(width: 1, height: 34, color: const Color(0xFFCBD8EE), margin: const EdgeInsets.symmetric(horizontal: 10)),
          cell(Icons.star_rounded, _amber, rt(locale, 'week'), rtf(locale, 'weekValue', asInt(data['week_total']))),
        ],
      ),
    );
  }
}

/// 7 kun: kichik kartalar va ostida progress chizig'i (telefon eniga sig'adi)
class _DaysRow extends StatelessWidget {
  const _DaysRow({required this.days, required this.todayDay, required this.locale});

  final List<Map<String, dynamic>> days;
  final int todayDay;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    final claimedUntil = days.lastIndexWhere((d) => d['state'] == 'claimed');
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < days.length; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              Expanded(child: _dayCard(days[i], i == days.length - 1)),
            ],
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (context, c) {
          final step = c.maxWidth / days.length;
          return SizedBox(
            height: 20,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned(
                  left: step / 2,
                  right: step / 2,
                  child: Container(height: 2, color: const Color(0xFFCBD3DF)),
                ),
                if (claimedUntil > 0)
                  Positioned(
                    left: step / 2,
                    width: step * claimedUntil,
                    child: Container(height: 3, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
                  ),
                for (var i = 0; i < days.length; i++)
                  Positioned(
                    left: step * i + step / 2 - 9,
                    child: _dot(days[i]),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _dot(Map<String, dynamic> day) {
    final claimed = day['state'] == 'claimed';
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: claimed ? _green : Colors.white,
        border: claimed ? null : Border.all(color: const Color(0xFFC5CDD9), width: 2),
      ),
      child: claimed ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
    );
  }

  Widget _dayCard(Map<String, dynamic> day, bool isLast) {
    final n = asInt(day['day']);
    final claimed = day['state'] == 'claimed';
    final isToday = n == todayDay;
    final Color bg = claimed
        ? const Color(0xFFEEFAF1)
        : isLast
            ? const Color(0xFFFFF8E7)
            : const Color(0xFFF7F9FC);
    final Color border = isToday
        ? _green
        : claimed
            ? const Color(0xFFCDEFD6)
            : isLast
                ? const Color(0xFFFBE5B0)
                : const Color(0xFFE8ECF3);
    final Widget icon = claimed
        ? Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
          )
        : isLast
            ? const Icon(Icons.card_giftcard_rounded, size: 22, color: _amber)
            : const Icon(Icons.lock_rounded, size: 19, color: Color(0xFF8A94A6));
    return AnimatedScale(
      scale: isToday ? 1.06 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: isToday ? 2 : 1),
        ),
        child: Column(
          children: [
            SizedBox(height: 24, child: Center(child: icon)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(rtf(locale, 'day', n),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _ink)),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                rtf(locale, 'plusGol', asInt(day['gol'])),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: claimed ? const Color(0xFF16A34A) : isLast ? const Color(0xFFD97706) : _muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
