import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/injector_container.dart';

// ==================== LOCALIZATION CLASS ====================
class CouponUsersLocalization {
  final String locale;

  CouponUsersLocalization(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'title': 'Kupondan foydalanganlar',
      'noUsers': 'Kupondan foydalanga o\'quvchilar yo\'q',
      'noUsersDescription': 'Bu sahifada kupondan foydalangan o\'quvchilar ro\'yxati chiqadi',
      'errorOccurred': 'Xatolik yuz berdi',
      'retryButton': 'Qayta urinish',
      'loadingError': 'Ma\'lumotlarni yuklashda xatolik:',
      'networkError': 'Tarmoq xatosi:',
      'coupon': 'Kupon:',
      'payment': 'To\'lov',
      'cashback': 'Cashback',
      'date': 'Sana',
      'som': 'so\'m',
    },
    'ru': {
      'title': 'Использовавшие купон',
      'noUsers': 'Нет учеников, использовавших купон',
      'noUsersDescription': 'На этой странице отображается список учеников, использовавших купон',
      'errorOccurred': 'Произошла ошибка',
      'retryButton': 'Повторить попытку',
      'loadingError': 'Ошибка загрузки данных:',
      'networkError': 'Сетевая ошибка:',
      'coupon': 'Купон:',
      'payment': 'Оплата',
      'cashback': 'Кэшбэк',
      'date': 'Дата',
      'som': 'сум',
    },
  };

  String translate(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues['uz']![key]!;
  }

  // Getters
  String get title => translate('title');
  String get noUsers => translate('noUsers');
  String get noUsersDescription => translate('noUsersDescription');
  String get errorOccurred => translate('errorOccurred');
  String get retryButton => translate('retryButton');
  String get loadingError => translate('loadingError');
  String get networkError => translate('networkError');
  String get coupon => translate('coupon');
  String get payment => translate('payment');
  String get cashback => translate('cashback');
  String get date => translate('date');
  String get som => translate('som');
}

// ==================== MAIN PAGE ====================
class CouponUsersPage extends StatefulWidget {
  const CouponUsersPage({super.key});

  @override
  State<CouponUsersPage> createState() => _CouponUsersPageState();
}

class _CouponUsersPageState extends State<CouponUsersPage> {
  List<Map<String, dynamic>> couponHistory = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCouponTransactions();
  }

  CouponUsersLocalization _getLocalization() {
    final appState = context.read<AppBloc>().state;
    return CouponUsersLocalization(appState.appLocale??'uz');
  }

  Future<void> fetchCouponTransactions() async {
    var token = sl<LocalSource>().getAccessToken();
    final l10n = _getLocalization();

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/universal/coupon-transaction/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          couponHistory = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        try {
          final errorData = json.decode(response.body);
          setState(() {
            errorMessage = errorData['error'] ??
                '${l10n.loadingError} ${response.statusCode}';
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            errorMessage = '${l10n.loadingError} ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = '${l10n.networkError} $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final l10n = CouponUsersLocalization(state.appLocale??'uz');

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const SizedBox.shrink(),
            title: Text(l10n.title),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? _buildErrorState(l10n)
              : couponHistory.isEmpty
              ? _buildEmptyState(l10n)
              : RefreshIndicator(
            onRefresh: fetchCouponTransactions,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: couponHistory.length,
              itemBuilder: (context, index) {
                final item = couponHistory[index];
                return _buildCouponCard(item, index + 1, l10n);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(CouponUsersLocalization l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? l10n.errorOccurred,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchCouponTransactions,
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(CouponUsersLocalization l10n) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noUsers,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noUsersDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(
      Map<String, dynamic> item,
      int index,
      CouponUsersLocalization l10n,
      ) {
    final usedAt = DateTime.parse(item['used_at']);
    final formattedDate =
        "${usedAt.year}-${usedAt.month.toString().padLeft(2, '0')}-${usedAt.day.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "$index",
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['student_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${l10n.coupon} ${item['coupon_code']}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    l10n.payment,
                    "${item['payment_amount']} ${l10n.som}",
                    Colors.blue.shade700,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildInfoColumn(
                    l10n.cashback,
                    "${item['cashback_amount']} ${l10n.som}",
                    Colors.green.shade700,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildInfoColumn(
                    l10n.date,
                    formattedDate,
                    Colors.orange.shade700,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}