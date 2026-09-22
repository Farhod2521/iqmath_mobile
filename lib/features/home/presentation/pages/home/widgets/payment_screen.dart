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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              PaymentTranslations.t('selectPlan', locale),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          body: isLoading
              ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B7CFF)))
              : errorMessage != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  errorMessage == 'error'
                      ? PaymentTranslations.t(
                      'errorLoadingData', locale)
                      : PaymentTranslations.t(
                      'internetError', locale),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    fetchSubscriptionPlans();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7CFF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                      PaymentTranslations.t('retryButton', locale)),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: fetchSubscriptionPlans,
            color: const Color(0xFF5B7CFF),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPricingCard(
                    context: context,
                    plan: plans[index],
                    locale: locale,
                    onTap: () {
                      _showPaymentBottomSheet(
                          context, plans[index], locale);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
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

  Widget _buildPricingCard({
    required BuildContext context,
    required SubscriptionPlan plan,
    required String? locale,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 2,
              color: const Color(0xFF5B7CFF).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan name with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B7CFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF5B7CFF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    locale == 'ru' ? plan.monthsDisplayRu : plan.monthsDisplay,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Duration subtitle
              Text(
                locale == 'ru'
                    ? 'Подписка на ${plan.months} ${_getMonthWord(plan.months, true)}'
                    : '${plan.months} oylik obuna',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.getFormattedSalePrice(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      PaymentTranslations.t('som', locale),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              // Original price (strikethrough)
              if (plan.discountPercent > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '${plan.getFormattedOriginalPrice()} ${PaymentTranslations.t('som', locale)}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[400],
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Benefits
              ...plan.benefits.map((benefit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: benefit.isSelected
                              ? const Color(0xFF10B981)
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          benefit.isSelected ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          locale == 'ru' ? benefit.titleRu : benefit.titleUz,
                          style: TextStyle(
                            fontSize: 16,
                            color: benefit.isSelected
                                ? Colors.black
                                : Colors.grey[500],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              // Buy button
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B7CFF), Color(0xFFA855F7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      PaymentTranslations.t('buyPlan', locale),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Top badge (Best or Discount)
        if (plan.category != null)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B7CFF), Color(0xFFA855F7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  locale == 'ru'
                      ? plan.category!.titleRu
                      : plan.category!.titleUz,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        // Top-right discount badge
        if (plan.discountPercent > 0)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B7CFF), Color(0xFFA855F7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFFF6B35),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '-${plan.discountPercent}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _getMonthWord(int months, bool isRussian) {
    if (!isRussian) return 'oy';
    if (months == 1) return 'месяц';
    if (months >= 2 && months <= 4) return 'месяца';
    return 'месяцев';
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