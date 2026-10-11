import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../core/widgets/soft_back_button.dart';
import '../../../../injector_container.dart';

const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _primary = Color(0xFF2563EB);
const _multicardCheck = 'https://checkout.multicard.uz/check/';

String _tr(String locale, String key) {
  const uz = {
    'title': "To'lovlarim",
    'subtitle': "Obuna to'lovlari tarixi",
    'total': "Jami to'langan",
    'count': "To'lovlar soni",
    'empty': "Hozircha to'lovlar yo'q",
    'error': "Ma'lumotni yuklab bo'lmadi",
    'retry': 'Qayta urinish',
    'details': 'Batafsil',
    'monthPlan': 'oylik obuna',
    'success': 'Muvaffaqiyatli',
    'pending': 'Kutilmoqda',
    'receipt': "To'lov cheki",
    'successPay': "Muvaffaqiyatli to'lov",
    'pendingPay': "To'lov kutilmoqda",
    'date': 'Sana',
    'plan': 'Tarif',
    'gateway': "To'lov tizimi",
    'card': 'Karta',
    'payer': "To'lovchi",
    'byParent': "Ota-ona to'lagan",
    'student': "O'quvchi",
    'coupon': 'Promokod',
    'discount': 'Chegirma',
    'original': 'Asl narx',
    'transaction': 'Tranzaksiya ID',
    'invoice': 'Invoys ID',
    'openCheck': 'Chekni ochish',
    'copy': 'Havolani nusxalash',
    'copied': 'Nusxa olindi',
    'som': "so'm",
  };
  const ru = {
    'title': 'Мои платежи',
    'subtitle': 'История оплат подписки',
    'total': 'Всего оплачено',
    'count': 'Платежей',
    'empty': 'Платежей пока нет',
    'error': 'Не удалось загрузить данные',
    'retry': 'Повторить',
    'details': 'Подробнее',
    'monthPlan': 'мес. подписка',
    'success': 'Успешно',
    'pending': 'В ожидании',
    'receipt': 'Чек оплаты',
    'successPay': 'Успешная оплата',
    'pendingPay': 'Оплата в ожидании',
    'date': 'Дата',
    'plan': 'Тариф',
    'gateway': 'Платёжная система',
    'card': 'Карта',
    'payer': 'Плательщик',
    'byParent': 'Оплатил родитель',
    'student': 'Ученик',
    'coupon': 'Промокод',
    'discount': 'Скидка',
    'original': 'Цена без скидки',
    'transaction': 'ID транзакции',
    'invoice': 'ID инвойса',
    'openCheck': 'Открыть чек',
    'copy': 'Копировать ссылку',
    'copied': 'Скопировано',
    'som': 'сум',
  };
  return (locale == 'ru' ? ru : uz)[key] ?? key;
}

/// 299000 -> "299 000"
String _money(num value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _two(int v) => v.toString().padLeft(2, '0');

String _dateTime(DateTime? d) {
  if (d == null) return '—';
  final l = d.toLocal();
  return '${_two(l.day)}.${_two(l.month)}.${l.year}, ${_two(l.hour)}:${_two(l.minute)}';
}

const _gatewayLabels = {
  'multicard': 'Multicard',
  'click': 'Click',
  'payme': 'Payme',
  'uzum': 'Uzum',
  'uzcard': 'Uzcard',
  'humo': 'Humo',
  'visa': 'Visa',
  'mastercard': 'Mastercard',
};

class PaymentRecord {
  final int id;
  final num amount;
  final num? originalAmount;
  final int discountPercent;
  final int months;
  final String status;
  final String gateway;
  final String cardPan;
  final String paidBy;
  final String payerName;
  final String couponCode;
  final String transactionId;
  final String invoiceUuid;
  final String receiptUrl;
  final DateTime? date;

  PaymentRecord.fromJson(Map<String, dynamic> j)
      : id = (j['id'] as num?)?.toInt() ?? 0,
        amount = num.tryParse('${j['amount']}') ?? 0,
        originalAmount = num.tryParse('${j['original_amount']}'),
        discountPercent = (j['discount_percent'] as num?)?.toInt() ?? 0,
        months = (j['subscription_months'] as num?)?.toInt() ?? 1,
        status = '${j['status'] ?? 'pending'}',
        gateway = _gatewayLabels['${j['payment_gateway']}'.toLowerCase()] ??
            '${j['payment_gateway'] ?? ''}',
        cardPan = '${j['card_pan'] ?? ''}',
        paidBy = '${j['paid_by'] ?? 'student'}',
        payerName = '${j['payer_name'] ?? ''}',
        couponCode = '${j['coupon_code'] ?? ''}',
        transactionId = '${j['transaction_id'] ?? ''}',
        invoiceUuid = '${j['invoice_uuid'] ?? ''}',
        receiptUrl = '${j['receipt_url'] ?? ''}',
        date = DateTime.tryParse('${j['payment_date'] ?? j['created_at'] ?? ''}');

  /// Ota-ona API'si (`parent/children/<id>/payments/` → `history`) elementi
  PaymentRecord.fromHistory(Map<String, dynamic> j)
      : id = (j['id'] as num?)?.toInt() ?? 0,
        amount = num.tryParse('${j['amount']}') ?? 0,
        originalAmount = num.tryParse('${j['original_amount']}'),
        discountPercent = (j['discount_percent'] as num?)?.toInt() ?? 0,
        months = (j['months'] as num?)?.toInt() ?? 1,
        status = '${j['status'] ?? 'pending'}',
        gateway = '${j['gateway'] ?? ''}',
        cardPan = '${j['card_pan'] ?? ''}',
        paidBy = '${j['paid_by'] ?? 'student'}',
        payerName = '${j['payer_name'] ?? ''}',
        couponCode = '${j['coupon_code'] ?? ''}',
        transactionId = '${j['transaction_id'] ?? ''}',
        invoiceUuid = '${j['invoice_uuid'] ?? ''}',
        receiptUrl = '${j['receipt_url'] ?? ''}',
        date = DateTime.tryParse('${j['date'] ?? ''}');

  bool get isSuccess => status == 'success';

  /// Chek havolasi invoys ID'dan yasaladi (saytdagi bilan bir xil)
  String get checkUrl => invoiceUuid.isNotEmpty ? '$_multicardCheck$invoiceUuid' : receiptUrl;
}

/// To'lov chekini pastki oynada ko'rsatadi
void showPaymentReceipt(BuildContext context, PaymentRecord item, String locale) {
  HapticFeedback.lightImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PaymentReceiptSheet(item: item, locale: locale),
  );
}

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  List<PaymentRecord>? _items;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = false;
      _items = null;
    });
    try {
      final token = sl<LocalSource>().getAccessToken();
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/payments/my-payments/'),
        headers: {'Content-Type': 'application/json', 'Authorization': '$token'},
      );
      if (response.statusCode != 200) throw Exception();
      final list = (jsonDecode(utf8.decode(response.bodyBytes)) as List)
          .whereType<Map>()
          .map((e) => PaymentRecord.fromJson(Map<String, dynamic>.from(e)))
          // Muvaffaqiyatsiz to'lovlar ko'rsatilmaydi (saytdagi kabi)
          .where((p) => p.status != 'failed')
          .toList();
      if (mounted) setState(() => _items = list);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale ?? 'uz';
        return Scaffold(
          backgroundColor: const Color(0xFFF5F8FE),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F0FC), Color(0xFFF5F8FE)],
                stops: [0.0, 0.45],
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    Row(
                      children: [
                        const SoftBackButton(size: 52),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_tr(locale, 'title'),
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _ink)),
                              Text(_tr(locale, 'subtitle'),
                                  style: const TextStyle(fontSize: 14, color: _muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ..._content(locale),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _content(String locale) {
    if (_error) {
      return [
        const SizedBox(height: 60),
        Center(child: Text(_tr(locale, 'error'), style: const TextStyle(color: _muted))),
        const SizedBox(height: 12),
        Center(
          child: TextButton(onPressed: _load, child: Text(_tr(locale, 'retry'))),
        ),
      ];
    }
    if (_items == null) {
      return const [
        SizedBox(height: 80),
        Center(child: CircularProgressIndicator(color: _primary)),
      ];
    }
    if (_items!.isEmpty) {
      return [
        const SizedBox(height: 70),
        const Icon(Icons.receipt_long_rounded, size: 64, color: Color(0xFFBFD3FF)),
        const SizedBox(height: 12),
        Center(
          child: Text(_tr(locale, 'empty'),
              style: const TextStyle(fontSize: 15, color: _muted, fontWeight: FontWeight.w600)),
        ),
      ];
    }
    final paid = _items!.where((p) => p.isSuccess);
    final total = paid.fold<num>(0, (sum, p) => sum + p.amount);
    return [
      _summary(locale, total, paid.length),
      const SizedBox(height: 16),
      for (final item in _items!) ...[
        PaymentCard(item: item, locale: locale, onDetails: () => _showReceipt(item, locale)),
        const SizedBox(height: 12),
      ],
    ];
  }

  Widget _summary(String locale, num total, int count) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_tr(locale, 'total'),
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('${_money(total)} ${_tr(locale, 'som')}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('$count',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(_tr(locale, 'count'),
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReceipt(PaymentRecord item, String locale) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentReceiptSheet(item: item, locale: locale),
    );
  }
}

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key, required this.item, required this.locale, required this.onDetails});

  final PaymentRecord item;
  final String locale;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final ok = item.isSuccess;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0E1A4C).withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ok ? const Color(0xFFE7F8EF) : const Color(0xFFFFF4DE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: ok ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.months} ${_tr(locale, 'monthPlan')}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
                    const SizedBox(height: 2),
                    Text(_dateTime(item.date), style: const TextStyle(fontSize: 12.5, color: _muted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_money(item.amount)} ${_tr(locale, 'som')}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ok ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _tr(locale, ok ? 'success' : 'pending'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ok ? const Color(0xFF15803D) : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEF1F6)),
          const SizedBox(height: 10),
          Row(
            children: [
              if (item.gateway.isNotEmpty) ...[
                const Icon(Icons.credit_card_rounded, size: 16, color: _muted),
                const SizedBox(width: 6),
                Text(item.gateway, style: const TextStyle(fontSize: 13, color: _muted, fontWeight: FontWeight.w600)),
              ],
              if (item.paidBy == 'parent') ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EBFF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_tr(locale, 'byParent'),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                ),
              ],
              const Spacer(),
              InkWell(
                onTap: onDetails,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_rounded, size: 16, color: _primary),
                      const SizedBox(width: 6),
                      Text(_tr(locale, 'details'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaymentReceiptSheet extends StatelessWidget {
  const PaymentReceiptSheet({super.key, required this.item, required this.locale});

  final PaymentRecord item;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final ok = item.isSuccess;
    final som = _tr(locale, 'som');
    final discount = (item.originalAmount ?? 0) - item.amount;
    final rows = <List<String>>[
      [_tr(locale, 'date'), _dateTime(item.date)],
      [_tr(locale, 'plan'), '${item.months} ${_tr(locale, 'monthPlan')}'],
      if (item.gateway.isNotEmpty) [_tr(locale, 'gateway'), item.gateway],
      if (item.cardPan.isNotEmpty) [_tr(locale, 'card'), item.cardPan],
      [
        _tr(locale, 'payer'),
        item.paidBy == 'parent' ? '${item.payerName} · ${_tr(locale, 'byParent')}' : item.payerName,
      ],
      if (item.couponCode.isNotEmpty) [_tr(locale, 'coupon'), item.couponCode],
      if (discount > 0) ...[
        [_tr(locale, 'original'), '${_money(item.originalAmount!)} $som'],
        [_tr(locale, 'discount'), '−${_money(discount)} $som'],
      ],
      if (item.transactionId.isNotEmpty) [_tr(locale, 'transaction'), item.transactionId],
      if (item.invoiceUuid.isNotEmpty) [_tr(locale, 'invoice'), item.invoiceUuid],
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(height: 18),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ok ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                ),
                child: Icon(
                  ok ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  size: 36,
                  color: ok ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 12),
              Text(_tr(locale, ok ? 'successPay' : 'pendingPay'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _muted)),
              const SizedBox(height: 4),
              Text('${_money(item.amount)} $som',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _ink)),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEEF1F6)),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) const Divider(height: 1, color: Color(0xFFEEF1F6)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 118,
                              child: Text(rows[i][0], style: const TextStyle(fontSize: 13, color: _muted)),
                            ),
                            Expanded(
                              child: Text(
                                rows[i][1],
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _ink),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.checkUrl.isNotEmpty) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => launchUrl(Uri.parse(item.checkUrl), mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new_rounded, size: 20),
                    label: Text(_tr(locale, 'openCheck'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: item.checkUrl));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_tr(locale, 'copied')), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18, color: _primary),
                  label: Text(_tr(locale, 'copy'),
                      style: const TextStyle(color: _primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
