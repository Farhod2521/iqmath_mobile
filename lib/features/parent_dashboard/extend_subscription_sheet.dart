import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/constants.dart';
import '../../core/app_bloc/app_bloc.dart';
import '../../core/widgets/dash_ui.dart';
import '../../core/widgets/top_notification.dart';
import '../../injector_container.dart';
import 'parent_texts.dart';

/// Ota-ona farzandi obunasini uzaytiradi: tarif → (promokod) → to'lov sahifasi
void showExtendSubscription(BuildContext context, {required int childId}) {
  final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
  showDashSheet(
    context,
    title: pt(locale, 'extTitle'),
    subtitle: pt(locale, 'extSubtitle'),
    icon: Icons.workspace_premium_rounded,
    iconColor: DashColors.amber,
    builder: (sheetContext) => _ExtendBody(childId: childId, locale: locale),
  );
}

class _ExtendBody extends StatefulWidget {
  const _ExtendBody({required this.childId, required this.locale});

  final int childId;
  final String locale;

  @override
  State<_ExtendBody> createState() => _ExtendBodyState();
}

class _ExtendBodyState extends State<_ExtendBody> {
  final Dio _dio = sl<Dio>();
  final _promo = TextEditingController();
  List<Map<String, dynamic>>? _plans;
  bool _error = false;
  int? _selectedId;
  Map<String, dynamic>? _coupon;
  bool _checking = false;
  bool _paying = false;

  String get locale => widget.locale;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = false);
    try {
      final res = await _dio.get('${Constants.baseUrl}/payments/plans/');
      final list = asMapList(res.data is Map ? res.data['data'] ?? res.data['results'] : res.data);
      if (mounted) {
        setState(() {
          _plans = list;
          _selectedId = list.isEmpty ? null : asInt(list.first['id']);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  Map<String, dynamic>? get _selected =>
      _plans?.firstWhere((p) => asInt(p['id']) == _selectedId, orElse: () => _plans!.first);

  String? _errorText(Object e) {
    if (e is DioException && e.response?.data is Map) {
      final body = e.response!.data as Map;
      return '${body['error'] ?? body['message'] ?? body['detail'] ?? ''}'.trim().isEmpty
          ? null
          : '${body['error'] ?? body['message'] ?? body['detail']}';
    }
    return null;
  }

  Future<void> _applyPromo() async {
    final code = _promo.text.trim();
    final plan = _selected;
    if (code.isEmpty || plan == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _checking = true);
    try {
      final res = await _dio.post('${Constants.baseUrl}/payments/check-coupon/', data: {
        'code': code,
        'subscription_id': plan['id'],
        'student_id': widget.childId,
      });
      final body = asMap(res.data);
      if (body['active'] == true) {
        setState(() => _coupon = {...body, 'code': body['code'] ?? code});
        if (mounted) TopNotification.showSuccess(context, message: pt(locale, 'extApplied'));
      } else {
        setState(() => _coupon = null);
        if (mounted) TopNotification.showError(context, message: '${body['message'] ?? pt(locale, 'extInvalid')}');
      }
    } catch (e) {
      setState(() => _coupon = null);
      if (mounted) TopNotification.showError(context, message: _errorText(e) ?? pt(locale, 'extInvalid'));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _pay() async {
    final plan = _selected;
    if (plan == null) return;
    setState(() => _paying = true);
    try {
      final res = await _dio.post('${Constants.baseUrl}/payments/initiate-payment/', data: {
        'subscription_id': plan['id'],
        'student_id': widget.childId,
        if (_coupon?['code'] != null) 'coupon_code': _coupon!['code'],
      });
      final body = asMap(res.data);
      final url = body['checkout_url'] ?? asMap(asMap(body['payment_data'])['data'])['checkout_url'];
      if (url == null || '$url'.isEmpty) throw Exception('no url');
      await launchUrl(Uri.parse('$url'), mode: LaunchMode.externalApplication);
      if (mounted) {
        TopNotification.showInfo(context, message: pt(locale, 'extOpened'));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) TopNotification.showError(context, message: _errorText(e) ?? pt(locale, 'extPayError'));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return ErrorRetry(message: pt(locale, 'loadError'), retryLabel: pt(locale, 'retry'), onRetry: _load);
    }
    final plans = _plans;
    if (plans == null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: DashColors.primary)),
      );
    }
    if (plans.isEmpty) return EmptyNote(text: pt(locale, 'extEmpty'));

    final selected = _selected!;
    final price = asNum(selected['sale_price']);
    final total = _coupon != null ? asNum(_coupon!['sale_price'] ?? price).round() : price.round();
    final som = pt(locale, 'som');

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        for (final plan in plans) ...[
          _PlanTile(
            plan: plan,
            locale: locale,
            selected: asInt(plan['id']) == _selectedId,
            onTap: () => setState(() {
              _selectedId = asInt(plan['id']);
              _coupon = null;
            }),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Text(pt(locale, 'extPromoTitle'),
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: DashColors.ink)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DashTextField(
                controller: _promo,
                hint: pt(locale, 'extPromoPlaceholder'),
                onSubmitted: (_) => _applyPromo(),
              ),
            ),
            const SizedBox(width: 8),
            DashButton(
              label: pt(locale, 'extApply'),
              loading: _checking,
              height: 48,
              color: DashColors.primarySoft,
              textColor: DashColors.primary,
              onTap: _applyPromo,
            ),
          ],
        ),
        if (_coupon != null) ...[
          const SizedBox(height: 8),
          Pill(
            text: '${pt(locale, 'extApplied')}: ${_coupon!['code']}',
            icon: Icons.check_circle_rounded,
            color: DashColors.green,
            background: DashColors.greenSoft,
            fontSize: 12,
          ),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFD), borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Expanded(
                child: Text(pt(locale, 'extTotal'), style: const TextStyle(fontSize: 13, color: DashColors.muted)),
              ),
              if (total < price) ...[
                Text('${fmtMoney(price)} ',
                    style: const TextStyle(
                        fontSize: 12, color: DashColors.subtle, decoration: TextDecoration.lineThrough)),
              ],
              Text('${fmtMoney(total)} $som',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DashColors.navy)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        DashButton(
          label: pt(locale, 'extPay'),
          icon: Icons.lock_rounded,
          loading: _paying,
          height: 50,
          onTap: _pay,
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan, required this.locale, required this.selected, required this.onTap});

  final Map<String, dynamic> plan;
  final String locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final discount = asInt(plan['discount_percent']);
    final som = pt(locale, 'som');
    final name = pickLang(plan, 'name', locale);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF4F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? DashColors.primary : const Color(0xFFE5EAF2), width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? DashColors.primary : DashColors.subtle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name.isNotEmpty ? name : pt(locale, 'extMonths', {'n': asInt(plan['months'])}),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: DashColors.ink),
                        ),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(width: 6),
                        Pill(text: '-$discount%', color: DashColors.red, background: DashColors.redSoft),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${fmtMoney(plan['price_per_month'])} $som ${pt(locale, 'extPerMonth')}',
                      style: const TextStyle(fontSize: 12, color: DashColors.muted)),
                ],
              ),
            ),
            Text('${fmtMoney(plan['sale_price'])} $som',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: DashColors.navy)),
          ],
        ),
      ),
    );
  }
}
