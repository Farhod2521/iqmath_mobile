import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/widgets/upper_text_formatter.dart';
import 'package:my_flutter_template/features/home/data/models/payment_data_response.dart';
import 'package:my_flutter_template/features/home/presentation/page_parts/home_localizations.dart';
import 'package:my_flutter_template/features/screen_lock/presentation/widgets/upper_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../../../../../../injector_container.dart';
import '../../../../data/models/subscription_plan.dart';

class TarifRejasiScreen extends StatefulWidget {
  const TarifRejasiScreen({super.key});

  @override
  State<TarifRejasiScreen> createState() => _TarifRejasiScreenState();
}

class _TarifRejasiScreenState extends State<TarifRejasiScreen> {
  List<SubscriptionPlan> plans = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchSubscriptionPlans();
  }

  Future<void> fetchSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/payments/plans/'),
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          plans = data
              .map((json) => SubscriptionPlan.fromJson(json))
              .where((plan) => plan.isActive)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'internet';
        isLoading = false;
      });
    }
  }

  // ───────────────────────── UI ─────────────────────────
  static const _kInk = Color(0xFF0F172A);
  static const _kMuted = Color(0xFF64748B);
  static const _kBlue = Color(0xFF1D6BFF);
  static const _kPurple = Color(0xFF8B5CF6);
  static const _kGreen = Color(0xFF16A34A);
  static const _kBg = Color(0xFFF3F6FC);

  int? _selectedMonths;

  /// Bazadagi tariflarning oylari (1, 3, 6, 12 ...), o'sish tartibida
  List<int> get _monthOptions {
    final list = plans.map((p) => p.months).toSet().toList()..sort();
    return list;
  }

  /// Tab ustidagi "-6%" — shu muddatni olsa 1 oylikka nisbatan qancha tejaladi.
  /// 1 oylik tarif bo'lmasa — eng katta chegirma foizi.
  int _tabSaving(int months) {
    if (months <= 1) return 0;
    int best = 0;
    for (final p in plans.where((p) => p.months == months)) {
      final base = plans.where((b) => b.months == 1 && _isPro(b) == _isPro(p));
      if (base.isNotEmpty && base.first.salePrice > 0) {
        final full = base.first.salePrice * months;
        final s = ((1 - p.salePrice / full) * 100).round();
        if (s > best) best = s;
      } else if (p.discountPercent > best) {
        best = p.discountPercent;
      }
    }
    return best;
  }

  bool _isPro(SubscriptionPlan p) {
    final name = '${p.nameUz ?? ''} ${p.nameRu ?? ''}'.toLowerCase();
    return name.contains('pro');
  }

  String _money(num v) => v.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');

  String _som(String? locale) => locale == 'ru' ? 'сум' : "so'm";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale;

        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _topBar(locale),
                Expanded(child: _body(locale)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(String? locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: _kInk, size: 26),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              PaymentTranslations.t('selectPlan', locale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _kInk,
                fontWeight: FontWeight.w800,
                fontSize: 21,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(String? locale) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: _kBlue));
    }
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                errorMessage == 'error'
                    ? PaymentTranslations.t('errorLoadingData', locale)
                    : PaymentTranslations.t('internetError', locale),
                textAlign: TextAlign.center,
                style: const TextStyle(color: _kMuted, fontSize: 16),
              ),
              const SizedBox(height: 24),
              _primaryButton(
                label: PaymentTranslations.t('retryButton', locale),
                onTap: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  fetchSubscriptionPlans();
                },
                showArrow: false,
              ),
            ],
          ),
        ),
      );
    }

    final options = _monthOptions;
    if (options.isEmpty) return const SizedBox.shrink();
    final selected =
        options.contains(_selectedMonths) ? _selectedMonths! : options.first;
    final visible = plans.where((p) => p.months == selected).toList()
      ..sort((a, b) => (_isPro(a) ? 1 : 0).compareTo(_isPro(b) ? 1 : 0));

    return RefreshIndicator(
      onRefresh: fetchSubscriptionPlans,
      color: _kBlue,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          _monthTabs(options, selected, locale),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Column(
              key: ValueKey(selected),
              children: [
                for (final plan in visible) ...[
                  _planCard(plan, locale),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          ),
          _securePayment(locale),
        ],
      ),
    );
  }

  Widget _monthTabs(List<int> options, int selected, String? locale) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: options.map((m) {
          final on = m == selected;
          final saving = _tabSaving(m);
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selectedMonths = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                height: 46,
                decoration: BoxDecoration(
                  gradient: on
                      ? const LinearGradient(
                          colors: [Color(0xFF2F7BFF), Color(0xFF1558E8)])
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: on
                      ? [
                          BoxShadow(
                            color: _kBlue.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          locale == 'ru' ? '$m мес' : '$m oylik',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: on ? Colors.white : _kInk,
                          ),
                        ),
                        if (saving > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: on
                                  ? Colors.white.withOpacity(0.22)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-$saving%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: on ? Colors.white : _kGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _planCard(SubscriptionPlan plan, String? locale) {
    final pro = _isPro(plan);
    final name = (locale == 'ru' ? plan.nameRu : plan.nameUz) ??
        plan.nameUz ??
        (pro ? 'Start Pro' : 'Start');
    final tagline = pro
        ? (locale == 'ru'
            ? 'Больше возможностей, выше результат'
            : "Ko'proq imkoniyat, yuqori natija")
        : (locale == 'ru'
            ? 'Идеальный выбор для старта'
            : 'Boshlash uchun ideal tanlov');
    final original = double.tryParse(plan.pricePerMonth) ?? 0;
    final hasDiscount = plan.discountPercent > 0 && original > plan.salePrice;
    final badge = plan.category != null
        ? (locale == 'ru' ? plan.category!.titleRu : plan.category!.titleUz)
        : null;

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: pro
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFF4F1FF),
                  Color(0xFFEFF5FF)
                ],
              )
            : null,
        color: pro ? null : Colors.white,
        boxShadow: [
          BoxShadow(
            color: (pro ? _kPurple : const Color(0xFF1E3A8A))
                .withOpacity(pro ? 0.14 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Illyustratsiya (o'ng yuqori)
          Positioned(
            right: 8,
            top: pro ? 44 : 14,
            child: IgnorePointer(
              child: Image.asset(
                pro ? 'assets/images/join_trophy.png' : 'assets/images/1.png',
                width: pro ? 150 : 140,
                height: pro ? 150 : 140,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 8, 16, 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF2F7BFF), Color(0xFF1558E8)]),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(26),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: Colors.white, size: 17),
                    const SizedBox(width: 6),
                    Text(
                      badge,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, badge != null ? 26 : 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikonka + nom
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: pro
                            ? const LinearGradient(colors: [
                                Color(0xFF8B5CF6),
                                Color(0xFFA78BFA)
                              ])
                            : null,
                        color: pro ? null : const Color(0xFFEAF1FF),
                      ),
                      child: Icon(
                        pro
                            ? Icons.workspace_premium_outlined
                            : Icons.view_in_ar_rounded,
                        color: pro ? Colors.white : _kBlue,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 110),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: _kInk,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Text(
                              tagline,
                              style: const TextStyle(
                                  fontSize: 13, color: _kMuted, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Muddat chipi
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          size: 16, color: _kBlue),
                      const SizedBox(width: 6),
                      Text(
                        locale == 'ru'
                            ? plan.monthsDisplayRu
                            : plan.monthsDisplay,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _kInk),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Eski narx + chegirma
                if (hasDiscount)
                  Row(
                    children: [
                      Text(
                        '${_money(original)} ${_som(locale)}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF94A3B8),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${plan.discountPercent}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 2),
                // Narx
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_money(plan.salePrice)} ${_som(locale)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: _kInk,
                      letterSpacing: -1,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Imkoniyatlar
                ...plan.benefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: b.isSelected
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFE2E8F0),
                            ),
                            child: Icon(
                              b.isSelected
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              color: b.isSelected
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              locale == 'ru' ? b.titleRu : b.titleUz,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: b.isSelected
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                color: b.isSelected
                                    ? _kInk
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 10),
                pro
                    ? _primaryButton(
                        label: _buyLabel(locale),
                        onTap: () =>
                            _showPaymentBottomSheet(context, plan, locale),
                      )
                    : _outlineButton(
                        label: _buyLabel(locale),
                        onTap: () =>
                            _showPaymentBottomSheet(context, plan, locale),
                      ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!pro) return card;
    // Pro karta — ko'k→binafsha gradient ramka
    return Container(
      padding: const EdgeInsets.all(1.6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27.6),
        gradient: const LinearGradient(
          colors: [Color(0xFF60A5FA), Color(0xFFA78BFA), Color(0xFFF0ABFC)],
        ),
      ),
      child: card,
    );
  }

  String _buyLabel(String? locale) =>
      locale == 'ru' ? 'Купить тариф' : 'Tarifni sotib olish';

  Widget _primaryButton(
      {required String label,
      required VoidCallback onTap,
      bool showArrow = true}) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1D6BFF), Color(0xFF8B5CF6)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: _kBlue.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8)),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                if (showArrow) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlineButton({required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _kBlue, width: 1.6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: _kBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_rounded, color: _kBlue, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _securePayment(String? locale) {
    Widget cardChip(String text, Color bg, Color fg) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Text(text,
              style: TextStyle(
                  color: fg,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2)),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.verified_user_outlined,
                color: _kBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale == 'ru' ? 'Безопасная оплата' : "Xavfsiz to'lov",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: _kInk),
                ),
                const SizedBox(height: 2),
                Text(
                  locale == 'ru'
                      ? 'Платежи защищены SSL'
                      : "To'lovlaringiz SSL orqali himoyalangan",
                  style: const TextStyle(fontSize: 12.5, color: _kMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              cardChip('UZCARD', const Color(0xFFEFF4FF),
                  const Color(0xFF1E3A8A)),
              const SizedBox(height: 6),
              cardChip(
                  'HUMO', const Color(0xFF0F2A44), const Color(0xFFF5C451)),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentBottomSheet(
      BuildContext context, SubscriptionPlan plan, String? locale) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => CouponDialog(plan: plan, locale: locale),
    );
  }
}

class SubscriptionPlan {
  final int id;
  final String? nameUz;
  final String? nameRu;
  final PlanCategory? category;
  final int months;
  final String monthsDisplay;
  final String monthsDisplayRu;
  final int discountPercent;
  final String pricePerMonth;
  final double salePrice;
  final List<Benefit> benefits;
  final bool isActive;
  final bool isPurchased;
  final String createdAt;
  final String updatedAt;

  SubscriptionPlan({
    required this.id,
    this.nameUz,
    this.nameRu,
    this.category,
    required this.months,
    required this.monthsDisplay,
    required this.monthsDisplayRu,
    required this.discountPercent,
    required this.pricePerMonth,
    required this.salePrice,
    required this.benefits,
    required this.isActive,
    required this.isPurchased,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      nameUz: json['name_uz'],
      nameRu: json['name_ru'],
      category: json['category'] != null
          ? PlanCategory.fromJson(json['category'])
          : null,
      months: json['months'],
      monthsDisplay: json['months_display'] ?? '${json['months']} oylik',
      monthsDisplayRu: json['months_display_ru'] ?? _generateRussianDisplay(json['months']),
      discountPercent: json['discount_percent'] ?? 0,
      pricePerMonth: json['price_per_month'],
      salePrice: (json['sale_price'] is int)
          ? (json['sale_price'] as int).toDouble()
          : json['sale_price'],
      benefits: (json['benefits'] as List)
          .map((benefit) => Benefit.fromJson(benefit))
          .toList(),
      isActive: json['is_active'] ?? true,
      isPurchased: json['is_purchased'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  static String _generateRussianDisplay(int months) {
    String word;
    if (months == 1) {
      word = 'месяц';
    } else if (months >= 2 && months <= 4) {
      word = 'месяца';
    } else {
      word = 'месяцев';
    }
    return '$months $word';
  }

  String getFormattedSalePrice() {
    return salePrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  String getFormattedOriginalPrice() {
    final originalPrice = double.parse(pricePerMonth);
    return originalPrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  String getFormattedPricePerMonth() {
    final originalPrice = double.parse(pricePerMonth);
    return '${originalPrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )} so\'m';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_uz': nameUz,
      'name_ru': nameRu,
      'category': category?.toJson(),
      'months': months,
      'months_display': monthsDisplay,
      'months_display_ru': monthsDisplayRu,
      'discount_percent': discountPercent,
      'price_per_month': pricePerMonth,
      'sale_price': salePrice,
      'benefits': benefits.map((b) => b.toJson()).toList(),
      'is_active': isActive,
      'is_purchased': isPurchased,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PlanCategory {
  final int id;
  final String titleUz;
  final String titleRu;

  PlanCategory({
    required this.id,
    required this.titleUz,
    required this.titleRu,
  });

  factory PlanCategory.fromJson(Map<String, dynamic> json) {
    return PlanCategory(
      id: json['id'],
      titleUz: json['title_uz'],
      titleRu: json['title_ru'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_uz': titleUz,
      'title_ru': titleRu,
    };
  }
}

class Benefit {
  final int id;
  final String titleUz;
  final String titleRu;
  final String description;
  final bool isSelected;

  Benefit({
    required this.id,
    required this.titleUz,
    required this.titleRu,
    required this.description,
    required this.isSelected,
  });

  factory Benefit.fromJson(Map<String, dynamic> json) {
    return Benefit(
      id: json['id'],
      titleUz: json['title_uz'],
      titleRu: json['title_ru'],
      description: json['description'] ?? '',
      isSelected: json['is_selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_uz': titleUz,
      'title_ru': titleRu,
      'description': description,
      'is_selected': isSelected,
    };
  }
}

// Kupon Dialog Widget
class CouponDialog extends StatefulWidget {
  final SubscriptionPlan plan;
  final String? locale;

  const CouponDialog({
    Key? key,
    required this.plan,
    this.locale,
  }) : super(key: key);

  @override
  State<CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<CouponDialog> {
  final TextEditingController _couponController = TextEditingController();
  bool isCheckingCoupon = false;
  String? couponMessage;
  bool? isCouponActive;
  Map<String, dynamic>? couponData;
  String? appliedCouponCode;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PaymentTranslations.t('coupons', widget.locale),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                      Icon(Icons.close, color: Colors.grey[700], size: 22),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                PaymentTranslations.t('enterPromoCode', widget.locale),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),

              // Plan Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border:
                  Border.all(color: const Color(0xFFE9ECEF), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.locale == 'ru'
                                  ? widget.plan.monthsDisplayRu
                                  : widget.plan.monthsDisplay,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.locale == 'ru'
                                  ? 'Подписка на ${widget.plan.months} ${_getMonthWord(widget.plan.months)}'
                                  : '${widget.plan.months} oylik obuna',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.plan.getFormattedSalePrice()} ${PaymentTranslations.t('som', widget.locale)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (widget.plan.discountPercent > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.plan.getFormattedPricePerMonth(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Benefits in dialog
                    if (widget.plan.benefits.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: widget.plan.benefits.map((benefit) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    benefit.isSelected
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: benefit.isSelected
                                        ? const Color(0xFF00D9B5)
                                        : Colors.grey[400],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.locale == 'ru'
                                          ? benefit.titleRu
                                          : benefit.titleUz,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: benefit.isSelected
                                            ? Colors.black
                                            : Colors.grey[500],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Coupon Input
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B8AFF).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  onChanged: (value) {
                    if (couponMessage != null) {
                      setState(() {
                        couponMessage = null;
                        isCouponActive = null;
                        couponData = null;
                        appliedCouponCode = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: PaymentTranslations.t('promoCode', widget.locale),
                    hintStyle: TextStyle(
                      color: Colors.grey[350],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF6B8AFF),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),

              // Coupon Message
              if (couponMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCouponActive == true
                        ? const Color(0xFF00D9B5).withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCouponActive == true
                          ? const Color(0xFF00D9B5)
                          : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCouponActive == true
                            ? Icons.check_circle
                            : Icons.error_outline,
                        color: isCouponActive == true
                            ? const Color(0xFF00D9B5)
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          couponMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isCouponActive == true
                                ? const Color(0xFF00D9B5)
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Kupon qo'llanganda ko'rsatish
              if (couponData != null && isCouponActive == true) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00D9B5).withOpacity(0.1),
                        const Color(0xFF00D9B5).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00D9B5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_offer,
                            color: Color(0xFF00D9B5),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            PaymentTranslations.t(
                                'couponApplied', widget.locale),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00D9B5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        PaymentTranslations.t('originalPrice', widget.locale),
                        '${_formatPrice(couponData!['original_price'])} ${PaymentTranslations.t('som', widget.locale)}',
                        isStrikethrough: true,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        PaymentTranslations.t('promoCode', widget.locale),
                        couponData!['code'],
                        color: const Color(0xFF6B8AFF),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        PaymentTranslations.t('discountPercent', widget.locale),
                        '${couponData!['discount_percent']}%',
                        color: const Color(0xFF00D9B5),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        PaymentTranslations.t('discountAmount', widget.locale),
                        '-${_formatPrice(couponData!['saved_amount'])} ${PaymentTranslations.t('som', widget.locale)}',
                        color: const Color(0xFF00D9B5),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFF00D9B5).withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            PaymentTranslations.t('finalPrice', widget.locale),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${_formatPrice(couponData!['sale_price'])} ${PaymentTranslations.t('som', widget.locale)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00D9B5),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Check Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isCheckingCoupon
                      ? null
                      : () {
                    _checkCoupon();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8AFF),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    shadowColor: const Color(0xFF6B8AFF).withOpacity(0.3),
                  ),
                  child: isCheckingCoupon
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    PaymentTranslations.t('checkCoupon', widget.locale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Back Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    PaymentTranslations.t('back', widget.locale),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[700],
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Payment Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isCheckingCoupon
                      ? null
                      : () {
                    _initiatePayment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9B5),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isCheckingCoupon
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    PaymentTranslations.t(
                        'proceedToPayment', widget.locale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthWord(int months) {
    if (months == 1) return 'месяц';
    if (months >= 2 && months <= 4) return 'месяца';
    return 'месяцев';
  }

  Widget _buildInfoRow(String label, String value,
      {bool isStrikethrough = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color ?? Colors.black,
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
            decorationColor: Colors.grey[400],
            decorationThickness: 2,
          ),
        ),
      ],
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    double priceValue =
    price is String ? double.parse(price) : price.toDouble();
    return priceValue.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  void _initiatePayment() async {
    setState(() {
      isCheckingCoupon = true;
    });

    var token = sl<LocalSource>().getAccessToken();

    try {
      Map<String, dynamic> requestBody = {
        'subscription_id': widget.plan.id,
      };

      if (appliedCouponCode != null && appliedCouponCode!.isNotEmpty) {
        requestBody['coupon_code'] = appliedCouponCode;
      }

      final response = await http.post(
        Uri.parse('https://api.iqmath.uz/api/v1/payments/initiate-payment/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final paymentResponse = PaymentDataResponse.fromJson(data);

        final deeplink = paymentResponse.paymentData.data.deeplink;

        setState(() {
          isCheckingCoupon = false;
        });

        Navigator.pop(context);

        final uri = Uri.parse(deeplink);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showMessage(
              PaymentTranslations.t('paymentOpenError', widget.locale));
        }
      } else {
        setState(() {
          isCheckingCoupon = false;
        });
        _showMessage(PaymentTranslations.t('paymentInitError', widget.locale));
      }
    } catch (e) {
      setState(() {
        isCheckingCoupon = false;
      });
      debugPrint(e.toString());
      _showMessage(PaymentTranslations.t('internetError', widget.locale));
    }
  }

  void _checkCoupon() async {
    String couponCode = _couponController.text.trim();
    if (couponCode.isEmpty) {
      setState(() {
        couponMessage = PaymentTranslations.t('enterCouponCode', widget.locale);
        isCouponActive = false;
      });
      return;
    }

    setState(() {
      isCheckingCoupon = true;
      couponMessage = null;
      isCouponActive = null;
      couponData = null;
      appliedCouponCode = null;
    });

    var token = sl<LocalSource>().getAccessToken();

    try {
      final response = await http.post(
        Uri.parse('https://api.iqmath.uz/api/v1/payments/check-coupon/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'code': couponCode,
          'subscription_id': widget.plan.id,
        }),
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          isCheckingCoupon = false;
          isCouponActive = data['active'] ?? false;
          couponMessage = isCouponActive == true
              ? PaymentTranslations.t('couponSuccess', widget.locale)
              : (data['message'] ??
              PaymentTranslations.t('couponInvalid', widget.locale));

          if (isCouponActive == true) {
            couponData = data;
            appliedCouponCode = couponCode;
          }
        });
      } else {
        final data = json.decode(response.body);
        setState(() {
          isCheckingCoupon = false;
          isCouponActive = false;
          couponMessage = data['message'] ??
              PaymentTranslations.t('couponCheckError', widget.locale);
        });
      }
    } catch (e) {
      setState(() {
        isCheckingCoupon = false;
        couponMessage = PaymentTranslations.t('internetError', widget.locale);
        isCouponActive = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6B8AFF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}