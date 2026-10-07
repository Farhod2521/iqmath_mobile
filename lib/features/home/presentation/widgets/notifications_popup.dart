import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Qo'ng'iroqcha bosilganda tugma ostida ochiladigan kichik oyna:
/// oxirgi bildirishnomalar ro'yxati. Biror bildirishnoma yoki
/// "Barchasini ko'rish" bosilsa — to'liq bildirishnomalar sahifasi ochiladi.
Future<void> showNotificationsPopup(
  BuildContext context, {
  required Rect anchor,
  required String locale,
  required VoidCallback onOpenAll,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'notifications',
    barrierColor: const Color(0xFF0F172A).withOpacity(0.18),
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (dialogContext, _, __) {
      final screen = MediaQuery.of(dialogContext).size;
      const margin = 16.0;
      final width = (screen.width - margin * 2).clamp(0.0, 380.0);
      // Oyna tugmaning o'ng chetiga tekislanadi, lekin har doim ekran ichida qoladi
      final left = (anchor.right - width).clamp(margin, screen.width - width - margin);
      return Stack(
        children: [
          Positioned(
            top: anchor.bottom + 8,
            left: left,
            width: width,
            child: Material(
              color: Colors.transparent,
              child: _NotificationsPanel(
                locale: locale,
                onOpenAll: () {
                  Navigator.of(dialogContext).pop();
                  onOpenAll();
                },
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (_, animation, __, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        alignment: Alignment.topRight,
        scale: Tween(begin: 0.96, end: 1.0).animate(animation),
        child: child,
      ),
    ),
  );
}

class _PopupItem {
  final String title;
  final String text;
  final DateTime? createdAt;

  const _PopupItem(this.title, this.text, this.createdAt);
}

class _NotificationsPanel extends StatefulWidget {
  const _NotificationsPanel({required this.locale, required this.onOpenAll});

  final String locale;
  final VoidCallback onOpenAll;

  @override
  State<_NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<_NotificationsPanel> {
  List<_PopupItem>? _items;
  bool _error = false;

  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _primary = Color(0xFF2563EB);

  String _t(String key) {
    const uz = {
      'title': 'Bildirishnomalar',
      'all': "Barchasini ko'rish",
      'empty': "Hozircha bildirishnoma yo'q",
      'error': "Yuklab bo'lmadi",
    };
    const ru = {
      'title': 'Уведомления',
      'all': 'Смотреть все',
      'empty': 'Пока уведомлений нет',
      'error': 'Не удалось загрузить',
    };
    return (widget.locale == 'ru' ? ru : uz)[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _plain(String? html) => (html ?? '')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'&#39;|&rsquo;|&lsquo;'), "'")
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Future<void> _load() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/management/app/elon-list/'),
      );
      if (response.statusCode != 200) throw Exception();
      final list = (json.decode(response.body) as List).whereType<Map>();
      final ru = widget.locale == 'ru';
      final items = list
          .where((e) => e['notification_status'] == true)
          .map((e) => _PopupItem(
                _plain((ru ? e['title_ru'] : null) ?? e['title_uz']),
                _plain((ru ? e['text_ru'] : null) ?? e['text_uz']),
                DateTime.tryParse(e['created_at']?.toString() ?? ''),
              ))
          .take(4)
          .toList();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  String _date(DateTime? d) {
    if (d == null) return '';
    final l = d.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(l.day)}.${two(l.month)}.${l.year}';
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_error) {
      body = _note(_t('error'));
    } else if (_items == null) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: _primary),
          ),
        ),
      );
    } else if (_items!.isEmpty) {
      body = _note(_t('empty'));
    } else {
      body = Column(
        children: [
          for (var i = 0; i < _items!.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEEF1F6)),
            _row(_items![i]),
          ],
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E1A4C).withOpacity(0.16),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.notifications_rounded, color: _primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  _t('title'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: SingleChildScrollView(child: body),
          ),
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onOpenAll();
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _t('all'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _primary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 17, color: _primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _note(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        child: Text(text, style: const TextStyle(fontSize: 14, color: _muted)),
      );

  Widget _row(_PopupItem item) {
    return InkWell(
      onTap: widget.onOpenAll,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.campaign_rounded, color: _primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: _muted, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _date(item.createdAt),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
