import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/features/home/presentation/page_parts/home_localizations.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home/widgets/payment_screen.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'dart:convert';

import '../../../../../../core/local_source/local_source.dart';
import '../../../../../../injector_container.dart';

class TarifCard extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const TarifCard({
    super.key,
    required this.refreshNotifier,
  });

  @override
  State<TarifCard> createState() => _TarifCardState();
}

class _TarifCardState extends State<TarifCard> {
  bool isLoading = true;
  String? error;
  List<SubscriptionPlan> plans = [];
  final PageController _pageController = PageController(
    viewportFraction: 1.0,
  );
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchPlans();
    widget.refreshNotifier?.addListener(_onRefresh);
  }

  @override
  void dispose() {
    _pageController.dispose();
    widget.refreshNotifier?.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    var token = sl<LocalSource>().getAccessToken();
    final headers = {
      'Authorization': '$token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/payments/plans/'),
        headers: headers,
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          plans = data.map((json) => SubscriptionPlan.fromJson(json)).toList();
          isLoading = false;
          error = null;
        });
      } else {
        setState(() {
          error = 'error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'internet';
        isLoading = false;
      });
    }
  }

  String formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;

        if (isLoading) {
          return _buildLoadingCard();
        }

        if (error != null) {
          return _buildErrorCard(locale ?? 'uz');
        }

        if (plans.isEmpty) {
          return _buildEmptyCard(locale ?? 'uz');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  locale == 'uz' ? 'Tarifflar' : 'Тарифы',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1B69),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 310,
              child: PageView.builder(
                controller: _pageController,
                padEnds: false,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 6,   // birinchi karta — chap margin yo'q
                      right: index == plans.length - 1 ? 0 : 6, // oxirgi karta — o'ng margin yo'q
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _buildPlanCard(plans[index], locale ?? 'uz'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                plans.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? const Color(0xFF6B4CE6)
                        : const Color(0xFF6B4CE6).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, String locale) {
    final isPopular = plan.category?.titleUz == 'Popular' ||
        plan.category?.titleUz == 'Best Value';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B4CE6),
            Color(0xFF4A2FB8),
            Color(0xFF2D1B69),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative circles background
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Category badge
          if (plan.category != null)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPopular
                        ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                        : [const Color(0xFF00E676), const Color(0xFF00C853)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPopular ? Icons.star : Icons.local_fire_department,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locale == 'uz'
                          ? plan.category!.titleUz
                          : plan.category!.titleRu,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Plan name with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locale == 'uz'
                            ? (plan.nameUz ?? '')
                            : (plan.nameRu ?? ''),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price with currency
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatAmount(plan.salePrice),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        TarifTranslations.t('som', locale),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Duration with icon
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locale == 'uz'
                          ? plan.monthsDisplay
                          : plan.monthsDisplayRu,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // Original price & discount
                if (plan.discountPercent > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${formatAmount(double.parse(plan.pricePerMonth))} ${TarifTranslations.t('som', locale)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.white.withOpacity(0.6),
                            decorationThickness: 2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E676), Color(0xFF00C853)],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '-${plan.discountPercent}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Benefits
                if (plan.benefits.isNotEmpty)
                  ...List.generate(
                    plan.benefits.length > 2 ? 2 : plan.benefits.length,
                        (index) {
                      final benefit = plan.benefits[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 1),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF00E676),
                                size: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                locale == 'uz'
                                    ? benefit.titleUz
                                    : benefit.titleRu,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                  height: 1.2,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const Spacer(),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: plan.isPurchased
                          ? null
                          : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: plan.isPurchased
                          ? Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      )
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: plan.isPurchased
                          ? null
                          : () {
                        final ctx = mainRootNavigatorKey.currentContext!;
                        final locale = ctx.read<AppBloc>().state.appLocale;
                        showDialog(
                          context: ctx,
                          barrierColor: Colors.black.withOpacity(0.5),
                          builder: (context) => CouponDialog(
                            plan: plan,
                            locale: locale,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: plan.isPurchased
                            ? Colors.white.withOpacity(0.5)
                            : const Color(0xFF4A2FB8),
                        disabledBackgroundColor: Colors.transparent,
                        disabledForegroundColor:
                        Colors.white.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            plan.isPurchased
                                ? TarifTranslations.t('paid', locale)
                                : TarifTranslations.t('payment', locale),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (!plan.isPurchased) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildLoadingCard() {
    return Container(
      height: 310,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B4CE6),
            Color(0xFF4A2FB8),
            Color(0xFF2D1B69),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white.withOpacity(0.8),
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String locale) {
    final errorMessage = error == 'error'
        ? TarifTranslations.t('errorLoadingData', locale)
        : TarifTranslations.t('internetError', locale);

    return Container(
      height: 310,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B4CE6),
            Color(0xFF4A2FB8),
            Color(0xFF2D1B69),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  error = null;
                });
                fetchPlans();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4A2FB8),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                TarifTranslations.t('retryButton', locale),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String locale) {
    return Container(
      height: 310,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B4CE6),
            Color(0xFF4A2FB8),
            Color(0xFF2D1B69),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                color: Colors.white.withOpacity(0.6),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                TarifTranslations.t('noPlansAvailable', locale),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}