import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/local_source/local_source.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/top_notification.dart';
import '../../injector_container.dart';
import '../home/presentation/pages/home/widgets/payment_screen.dart';
import '../rewards/daily_reward_dialog.dart';
import '../rewards/rewards_api.dart';
import 'liga_api.dart';
import 'liga_join_sheet.dart';
import 'liga_widgets.dart';

const _texts = {
  'uz': {
    'badge': 'Yangi mavsum boshlandi!',
    'title': 'Matematik Liga — {n}-mavsum ochildi',
    'text': 'Ligaga qo‘shiling, har hafta test ishlang, sinfingiz reytingida ko‘tariling va sovg‘alarni yutib oling!',
    'weeks': '{n} hafta',
    'weekly': 'Haftalik testlar',
    'prizes': 'Sovg‘alar',
    'gol': 'Har kuni +1 gol',
    'join': 'Ishtirok etish',
    'pay': 'Tarifni tanlash',
    'needPay': 'Ligada qatnashish uchun obuna faol bo‘lishi kerak.',
    'later': 'Keyinroq',
    'joined': 'Ligaga qo‘shildingiz! Omad!',
  },
  'ru': {
    'badge': 'Начался новый сезон!',
    'title': 'Математическая лига — открыт сезон {n}',
    'text': 'Вступайте в лигу, проходите тесты каждую неделю, поднимайтесь в рейтинге класса и выигрывайте призы!',
    'weeks': '{n} нед.',
    'weekly': 'Еженедельные тесты',
    'prizes': 'Призы',
    'gol': 'Каждый день +1 гол',
    'join': 'Участвовать',
    'pay': 'Выбрать тариф',
    'needPay': 'Для участия в лиге нужна активная подписка.',
    'later': 'Позже',
    'joined': 'Вы вступили в лигу! Удачи!',
  },
};

String _t(String locale, String key, [Object? n]) {
  final text = (_texts[locale == 'ru' ? 'ru' : 'uz']![key]) ?? key;
  return n == null ? text : text.replaceAll('{n}', '$n');
}

/// Mavsum ochiq deb e'lon qilinganda ligaga qo'shilmagan o'quvchiga chiqadigan oyna (saytdagi kabi).
/// "Ishtirok etish" → sinf tanlash → ligaga qo'shiladi va bugungi gol shu zahoti beriladi.
/// Har mavsum uchun kuniga bir marta ko'rsatiladi.
class LigaAnnounce {
  LigaAnnounce._();

  static bool _checked = false;

  static void reset() => _checked = false;

  static Future<void> showIfNeeded(BuildContext context, String locale) async {
    if (_checked || !TariffService.isStudent) return;
    _checked = true;
    Map<String, dynamic> data;
    try {
      data = await LigaApi.current();
    } catch (_) {
      _checked = false;
      return;
    }
    final season = data['season'] is Map ? asMap(data['season']) : null;
    if (season == null || season['is_closed'] == true || data['joined'] != false) return;

    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    final key = 'liga_announce_${asInt(season['id'])}';
    final box = sl<LocalSource>().box;
    if (box.get(key) == today) return;
    box.put(key, today);
    if (!context.mounted) return;

    final action = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'liga-announce',
      barrierColor: const Color(0xFF0B1B3F).withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => _AnnounceView(locale: locale, season: season, active: data['subscription_active'] == true),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
          child: child,
        ),
      ),
    );
    if (!context.mounted) return;

    if (action == 'pay') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TarifRejasiScreen()));
      return;
    }
    if (action != 'join') return;

    var grades = asMapList(data['grades']);
    if (grades.isEmpty) {
      try {
        grades = await LigaApi.classes();
      } catch (_) {}
    }
    if (!context.mounted) return;
    final grade = await showLigaJoinSheet(
      context,
      locale: locale,
      grades: grades,
      initialGrade: data['profile_grade_id'] == null ? null : asInt(data['profile_grade_id']),
    );
    if (grade == null || !context.mounted) return;
    try {
      HapticFeedback.mediumImpact();
      await LigaApi.join(asInt(season['id']), grade);
      if (!context.mounted) return;
      TopNotification.showSuccess(context, message: _t(locale, 'joined'));
      // Ligaga qo'shilgach gol yig'ish boshlanadi: bugungi gol darhol (konfetti bilan)
      DailyReward.reset();
      await DailyReward.claimAndShow(context, locale);
    } catch (e) {
      if (context.mounted) TopNotification.showError(context, message: LigaApi.errorText(e) ?? 'Xatolik');
    }
  }
}

class _AnnounceView extends StatelessWidget {
  const _AnnounceView({required this.locale, required this.season, required this.active});

  final String locale;
  final Map<String, dynamic> season;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.event_available_rounded, _t(locale, 'weeks', season['weeks_count'] ?? 12)),
      (Icons.assignment_outlined, _t(locale, 'weekly')),
      (Icons.card_giftcard_rounded, _t(locale, 'prizes')),
      (Icons.sports_soccer_rounded, _t(locale, 'gol')),
    ];
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE8F1FF), Color(0xFFF3F8FF), Colors.white],
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(color: LigaColors.primary, borderRadius: BorderRadius.circular(20)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.emoji_events_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(_t(locale, 'badge'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                              ]),
                            ),
                            const SizedBox(height: 10),
                            Image.asset('assets/images/join_trophy.png', height: 120, fit: BoxFit.contain),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: LigaColors.text),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Column(
                      children: [
                        Text(_t(locale, 'title', season['number']),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: LigaColors.ink, height: 1.2)),
                        const SizedBox(height: 8),
                        Text(_t(locale, 'text'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13.5, color: LigaColors.muted, height: 1.45)),
                        const SizedBox(height: 14),
                        for (var i = 0; i < features.length; i += 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(children: [
                              Expanded(child: _feature(features[i])),
                              const SizedBox(width: 8),
                              Expanded(child: _feature(features[i + 1])),
                            ]),
                          ),
                        if (!active)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_t(locale, 'needPay'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFB45309))),
                          ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: LigaColors.chip,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(_t(locale, 'later'),
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: LigaColors.text)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: LigaButton(
                                label: _t(locale, active ? 'join' : 'pay'),
                                expand: true,
                                onTap: () => Navigator.of(context).pop(active ? 'join' : 'pay'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _feature((IconData, String) item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(color: LigaColors.soft, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          LigaIconBox(icon: item.$1, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Text(item.$2,
                maxLines: 2,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: LigaColors.ink)),
          ),
        ]),
      );
}
