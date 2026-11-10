import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_bloc/app_bloc.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/soft_back_button.dart';
import 'rewards_api.dart';
import 'rewards_texts.dart';

const _ink = Color(0xFF0B1B3F);
const _blue = Color(0xFF1D6BFF);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE8ECF3);

/// Tarix: ball, tanga, so'm va gol bo'yicha barcha kirim/chiqimlar (saytdagi /dashboard/student/history).
class WalletHistoryPage extends StatefulWidget {
  const WalletHistoryPage({super.key});

  @override
  State<WalletHistoryPage> createState() => _WalletHistoryPageState();
}

class _WalletHistoryPageState extends State<WalletHistoryPage> {
  static const _pageSize = 20;
  static const _tabs = ['all', 'score', 'coin', 'som', 'gol'];

  final _scroll = ScrollController();
  String _tab = 'all';
  DateTimeRange? _range;

  final List<Map<String, dynamic>> _rows = [];
  Map<String, dynamic> _summary = {};
  int _count = 0;
  int _page = 0;
  bool _loading = false;
  bool _error = false;
  int _requestId = 0;

  bool get _hasMore => _rows.length < _count;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) _loadMore();
    });
    _reload();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    _rows.clear();
    _page = 0;
    _count = 0;
    await _loadMore(force: true);
  }

  Future<void> _loadMore({bool force = false}) async {
    if (_loading && !force) return;
    if (!force && !_hasMore) return;
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final data = await RewardsApi.walletHistory(
        currency: _tab == 'all' ? null : _tab,
        dateFrom: _range?.start,
        dateTo: _range?.end,
        page: _page + 1,
        pageSize: _pageSize,
      );
      if (!mounted || id != _requestId) return; // filtr o'zgargan — eski javob tashlanadi
      setState(() {
        _page += 1;
        _count = asInt(data['count']);
        _summary = asMap(data['summary']);
        _rows.addAll(asMapList(data['results']));
      });
    } catch (_) {
      if (mounted && id == _requestId) setState(() => _error = true);
    } finally {
      if (mounted && id == _requestId) setState(() => _loading = false);
    }
  }

  void _selectTab(String tab) {
    if (tab == _tab) return;
    HapticFeedback.selectionClick();
    setState(() => _tab = tab);
    _reload();
  }

  Future<void> _pickRange(String locale) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      // Ilova tili bilan ochiladi
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: _range,
      helpText: rt(locale, 'history'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: _blue)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _range = picked);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select<AppBloc, String>((b) => b.state.appLocale ?? 'uz');
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: _blue,
          onRefresh: _reload,
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(locale)),
              SliverToBoxAdapter(child: _summaryGrid(locale)),
              SliverToBoxAdapter(child: _filters(locale)),
              ..._list(locale),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(String locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
      child: Row(
        children: [
          SoftBackButton(onTap: () => Navigator.of(context).maybePop()),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rt(locale, 'history'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _ink)),
                Text(rt(locale, 'historySub'), style: const TextStyle(fontSize: 13, color: _muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryGrid(String locale) {
    final loading = _summary.isEmpty && _loading;
    Widget card(String key, Color bg, Color circle, Widget icon, String unit, String label) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
              child: Center(child: icon),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: loading ? '…' : fmtMoney(_summary[key] ?? 0),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _ink),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
                        ),
                      ]),
                    ),
                  ),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: card('gol', const Color(0xFFEAF2FF), const Color(0xFFD6E5FF), _currencyIcon('gol', 26),
                  rt(locale, 'gol'), rt(locale, 'totalGol')),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: card('som', const Color(0xFFE6F8EC), const Color(0xFFCDEFD8), _currencyIcon('som', 26),
                  rt(locale, 'som'), rt(locale, 'totalSom')),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: card('coin', const Color(0xFFFFF5E0), const Color(0xFFFDE8BC), _currencyIcon('coin', 26),
                  rt(locale, 'coin'), rt(locale, 'totalCoin')),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: card('score', const Color(0xFFF1ECFF), const Color(0xFFE2D8FF), _currencyIcon('score', 26),
                  rt(locale, 'score'), rt(locale, 'totalScore')),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _filters(String locale) {
    const labels = {'all': 'tabAll', 'score': 'tabScore', 'coin': 'tabCoin', 'som': 'tabSom', 'gol': 'tabGol'};
    final rangeText = _range == null
        ? rt(locale, 'allTime')
        : '${fmtDate(_range!.start.toIso8601String())} – ${fmtDate(_range!.end.toIso8601String())}';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final key = _tabs[i];
                final active = key == _tab;
                return GestureDetector(
                  onTap: () => _selectTab(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: active ? _blue : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: active ? _blue : _line),
                      boxShadow: active
                          ? [BoxShadow(color: _blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))]
                          : null,
                    ),
                    child: Row(
                      children: [
                        key == 'all'
                            ? Icon(Icons.grid_view_rounded, size: 18, color: active ? Colors.white : _ink)
                            : _currencyIcon(key, 18, onDark: active),
                        const SizedBox(width: 6),
                        Text(rt(locale, labels[key]!),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700, color: active ? Colors.white : _ink)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _pickRange(locale),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _line),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF475569)),
                        const SizedBox(width: 8),
                        Text(rangeText,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _ink)),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more_rounded, size: 18, color: _muted),
                      ],
                    ),
                  ),
                ),
                if (_range != null) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      setState(() => _range = null);
                      _reload();
                    },
                    icon: const Icon(Icons.close_rounded, size: 20, color: _muted),
                    tooltip: rt(locale, 'allTime'),
                  ),
                ],
                const Spacer(),
                if (_count > 0)
                  Text(rtf(locale, 'records', _count), style: const TextStyle(fontSize: 12.5, color: _muted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<Widget> _list(String locale) {
    if (_rows.isEmpty) {
      Widget body;
      if (_loading) {
        body = const Padding(
          padding: EdgeInsets.only(top: 60),
          child: Center(child: CircularProgressIndicator(color: _blue)),
        );
      } else if (_error) {
        body = Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Text(rt(locale, 'error'), style: const TextStyle(fontSize: 15, color: Color(0xFFDC2626))),
              const SizedBox(height: 10),
              TextButton(onPressed: _reload, child: Text(rt(locale, 'retry'))),
            ],
          ),
        );
      } else {
        body = Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              const Icon(Icons.history_rounded, size: 48, color: Color(0xFFCBD3DF)),
              const SizedBox(height: 10),
              Text(rt(locale, 'empty'), style: const TextStyle(fontSize: 15, color: _muted)),
            ],
          ),
        );
      }
      return [SliverToBoxAdapter(child: body)];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _rowCard(_rows[i], locale),
            childCount: _rows.length,
          ),
        ),
      ),
      if (_hasMore || _loading)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))),
          ),
        ),
    ];
  }

  Widget _rowCard(Map<String, dynamic> row, String locale) {
    final source = '${row['source'] ?? 'other'}';
    final style = _sourceStyle[source] ?? _sourceStyle['other']!;
    final amount = asInt(row['amount']);
    final currency = '${row['currency'] ?? ''}';
    final balance = row['balance_after'];
    final description = '${row['description'] ?? ''}'.trim();
    const tabKeys = {'score': 'tabScore', 'coin': 'tabCoin', 'som': 'tabSom', 'gol': 'tabGol'};

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: const Color(0xFF0E1A4C).withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: style.$2, borderRadius: BorderRadius.circular(12)),
                child: Icon(style.$1, size: 21, color: style.$3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rt(locale, 'src_$source'),
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: _ink),
                ),
              ),
              Text(
                '${amount > 0 ? '+' : '−'}${fmtMoney(amount.abs())}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: amount < 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155), height: 1.35)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF4F6FA), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _currencyIcon(currency, 15),
                    const SizedBox(width: 5),
                    Text(rt(locale, tabKeys[currency] ?? 'tabAll'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(fmtWhen(row['created_at'], locale),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: _muted)),
              ),
              if (balance != null)
                Text.rich(TextSpan(children: [
                  TextSpan(text: '${rt(locale, 'balance')}: ', style: const TextStyle(fontSize: 12, color: _muted)),
                  TextSpan(
                    text: fmtMoney(balance),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _ink),
                  ),
                ])),
            ],
          ),
        ],
      ),
    );
  }
}

/// Manba → (ikonka, fon, rang) — saytdagi bilan bir xil
const Map<String, (IconData, Color, Color)> _sourceStyle = {
  'daily_login': (Icons.event_available_rounded, Color(0xFFE8F0FF), Color(0xFF1D6BFF)),
  'lesson': (Icons.play_arrow_rounded, Color(0xFFE7F8EE), Color(0xFF16A34A)),
  'weekly_test': (Icons.emoji_events_rounded, Color(0xFFFFF4DD), Color(0xFFD97706)),
  'battle': (Icons.sports_kabaddi_rounded, Color(0xFFFFF0E6), Color(0xFFEA580C)),
  'reward': (Icons.card_giftcard_rounded, Color(0xFFF3E8FF), Color(0xFF9333EA)),
  'fine': (Icons.gpp_maybe_rounded, Color(0xFFFEE8E8), Color(0xFFDC2626)),
  'convert': (Icons.swap_horiz_rounded, Color(0xFFE3F7F7), Color(0xFF0D9488)),
  'shop': (Icons.shopping_cart_rounded, Color(0xFFF1ECFF), Color(0xFF7C3AED)),
  'book': (Icons.menu_book_rounded, Color(0xFFE9EDFF), Color(0xFF4F46E5)),
  'transfer': (Icons.send_rounded, Color(0xFFE4F4FD), Color(0xFF0284C7)),
  'other': (Icons.radio_button_checked_rounded, Color(0xFFF1F5F9), Color(0xFF64748B)),
};

/// Valyuta belgisi: gol — futbol to'pi, qolganlari ilovadagi 3D rasmlar
Widget _currencyIcon(String currency, double size, {bool onDark = false}) {
  const images = {
    'score': 'assets/images/stat_ball.webp',
    'coin': 'assets/images/stat_coins.webp',
    'som': 'assets/images/stat_money.webp',
  };
  final image = images[currency];
  if (image == null) {
    return Icon(Icons.sports_soccer_rounded, size: size, color: onDark ? Colors.white : _ink);
  }
  return Image.asset(image, width: size, height: size, fit: BoxFit.contain);
}
