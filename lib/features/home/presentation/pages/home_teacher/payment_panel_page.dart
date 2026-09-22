import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/injector_container.dart';

class PaymentLocalization {
  static final Map<String, Map<String, String>> _localizedValues = {
    'withdrawMoney': {
      'uz': 'Pul yechish',
      'ru': 'Вывод средств',
    },
    'currentBalance': {
      'uz': 'Joriy balans',
      'ru': 'Текущий баланс',
    },
    'enterAmount': {
      'uz': 'Summani kiriting',
      'ru': 'Введите сумму',
    },
    'minimal': {
      'uz': 'Minimal',
      'ru': 'Минимальная',
    },
    'maximal': {
      'uz': 'Maksimal',
      'ru': 'Максимальная',
    },
    'withdraw': {
      'uz': 'Yechib olish',
      'ru': 'Вывести',
    },
    'totalEarned': {
      'uz': 'Jami ishlangan',
      'ru': 'Всего заработано',
    },
    'withdrawn': {
      'uz': 'Yechib olingan',
      'ru': 'Выведено',
    },
    'pending': {
      'uz': 'Jarayonda',
      'ru': 'В процессе',
    },
    'balance': {
      'uz': 'Balans',
      'ru': 'Баланс',
    },
    'noData': {
      'uz': 'Ma\'lumot topilmadi',
      'ru': 'Данные не найдены',
    },
    'withdrawalHistory': {
      'uz': 'Yechib olishlar tarixi',
      'ru': 'История выводов',
    },
    'errorLoading': {
      'uz': 'Ma\'lumotlarni yuklashda xatolik',
      'ru': 'Ошибка при загрузке данных',
    },
    'error': {
      'uz': 'Xatolik',
      'ru': 'Ошибка',
    },
    'minimalAmount': {
      'uz': 'Minimal summa',
      'ru': 'Минимальная сумма',
    },
    'notEnoughBalance': {
      'uz': 'Balansingizda yetarli mablag\' yo\'q',
      'ru': 'Недостаточно средств на балансе',
    },
    'requestSent': {
      'uz': 'So\'rov yuborildi',
      'ru': 'Запрос отправлен',
    },
    'som': {
      'uz': 'so\'m',
      'ru': 'сум',
    },
  };

  static String get(String key, String locale) {
    return _localizedValues[key]?[locale] ?? _localizedValues[key]?['uz'] ?? key;
  }
}

class PaymentData {
  final int totalEarned;
  final int withdrawn;
  final int pending;
  final int balance;
  final List withdrawals;

  PaymentData({
    required this.totalEarned,
    required this.withdrawn,
    required this.pending,
    required this.balance,
    required this.withdrawals,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      totalEarned: json['total_earned'] ?? 0,
      withdrawn: json['withdrawn'] ?? 0,
      pending: json['pending'] ?? 0,
      balance: json['balance'] ?? 0,
      withdrawals: json['withdrawals'] ?? [],
    );
  }
}

class PaymentPanelPage extends StatefulWidget {
  const PaymentPanelPage({super.key});

  @override
  State<PaymentPanelPage> createState() => _PaymentPanelPageState();
}

class _PaymentPanelPageState extends State<PaymentPanelPage> {
  final TextEditingController _amountController = TextEditingController();
  final int minAmount = 1000;
  PaymentData? _paymentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentData();
  }

  Future<void> _fetchPaymentData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/tutor/tutor/payments/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _paymentData = PaymentData.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(PaymentLocalization.get('errorLoading',
                  context.read<AppBloc>().state.appLocale ?? 'uz')),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${PaymentLocalization.get('error',
                context.read<AppBloc>().state.appLocale ?? 'uz')}: $e'),
          ),
        );
      }
    }
  }

  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );
  }

  void _setMaxAmount() {
    if (_paymentData != null) {
      _amountController.text = _paymentData!.balance.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              PaymentLocalization.get('withdrawMoney', locale),
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _fetchPaymentData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Top card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          PaymentLocalization.get('withdrawMoney', locale),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Balance
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16),
                            children: [
                              TextSpan(
                                text: '${PaymentLocalization.get('currentBalance', locale)}: ',
                                style: const TextStyle(color: Color(0xFF757575)),
                              ),
                              TextSpan(
                                text: "${_formatMoney(_paymentData?.balance ?? 0)} ${PaymentLocalization.get('som', locale)}",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Input label
                        Text(
                          PaymentLocalization.get('enterAmount', locale),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Input field
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: const TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 20,
                              ),
                              suffixText: PaymentLocalization.get('som', locale),
                              suffixStyle: const TextStyle(
                                color: Color(0xFF757575),
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Min/Max info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${PaymentLocalization.get('minimal', locale)}: ${_formatMoney(minAmount)} ${PaymentLocalization.get('som', locale)}',
                              style: const TextStyle(
                                color: Color(0xFF757575),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: _setMaxAmount,
                              child: Text(
                                PaymentLocalization.get('maximal', locale),
                                style: const TextStyle(
                                  color: Color(0xFF5B8DEF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final amount = int.tryParse(_amountController.text) ?? 0;
                              if (amount < minAmount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${PaymentLocalization.get('minimalAmount', locale)} ${_formatMoney(minAmount)} ${PaymentLocalization.get('som', locale)}',
                                    ),
                                  ),
                                );
                              } else if (amount > (_paymentData?.balance ?? 0)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      PaymentLocalization.get('notEnoughBalance', locale),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      PaymentLocalization.get('requestSent', locale),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8FA9D8),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              PaymentLocalization.get('withdraw', locale),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Stats grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                PaymentLocalization.get('totalEarned', locale),
                                "${_formatMoney(_paymentData?.totalEarned ?? 0)} ${PaymentLocalization.get('som', locale)}",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                PaymentLocalization.get('withdrawn', locale),
                                "${_formatMoney(_paymentData?.withdrawn ?? 0)} ${PaymentLocalization.get('som', locale)}",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                PaymentLocalization.get('pending', locale),
                                "${_formatMoney(_paymentData?.pending ?? 0)} ${PaymentLocalization.get('som', locale)}",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                PaymentLocalization.get('balance', locale),
                                "${_formatMoney(_paymentData?.balance ?? 0)} ${PaymentLocalization.get('som', locale)}",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom card
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (_paymentData?.withdrawals.isEmpty ?? true)
                            ? PaymentLocalization.get('noData', locale)
                            : PaymentLocalization.get('withdrawalHistory', locale),
                        style: const TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}