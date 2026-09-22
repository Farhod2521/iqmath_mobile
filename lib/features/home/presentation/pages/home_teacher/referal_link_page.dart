import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/profile_page.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReferalLinkPage extends StatefulWidget {
  const ReferalLinkPage({super.key});

  @override
  State<ReferalLinkPage> createState() => _ReferalLinkPageState();
}

class _ReferalLinkPageState extends State<ReferalLinkPage> {
  String referralCode =
      'https://iqmath.uz/?referral_code=${sl<LocalSource>().getReferralCode()}';

  List<ReferralTransaction> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReferralTransactions();
  }

  Future<void> _fetchReferralTransactions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/tutor/tutor/referral-transactions/'),
        headers: {
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          transactions = data.map((json) => ReferralTransaction.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Ma\'lumotlarni yuklashda xatolik';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Internet bilan bog\'liqlik muammosi';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Havola orqali qo\'shilganlar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          floatingActionButton: transactions.isNotEmpty
              ? FloatingActionButton.extended(
            onPressed: () {
              _showReferralBottomSheet(locale);
            },
            backgroundColor: const Color(0xFF5B8DEF),
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            label: const Text(
              'O\'quvchi taklif qilish',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              : null,
          body: RefreshIndicator(
            onRefresh: _fetchReferralTransactions,
            color: const Color(0xFF5B8DEF),
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5B8DEF),
              ),
            )
                : errorMessage != null
                ? _buildErrorState()
                : transactions.isEmpty
                ? _buildEmptyState(locale)
                : _buildTransactionsList(),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Xatolik yuz berdi',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchReferralTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Qayta urinish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8DEF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String locale) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        const SizedBox(height: 80),
        Container(
          width: 140,
          height: 140,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F0F0),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 70,
                color: Color(0xFF9E9E9E),
              ),
              Positioned(
                right: 35,
                top: 30,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9E9E9E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Taklif qilingan do'stlar mavjud emas!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          "Do'stlaringizni taklif qiling va ularni ro'yxatdan o'tkazing",
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF757575),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showReferralBottomSheet(locale);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B8DEF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.link,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Referal link',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(transaction, index);
      },
    );
  }

  Widget _buildTransactionCard(ReferralTransaction transaction, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Card click action
            _showTransactionDetails(transaction);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Number and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B8DEF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '№${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5B8DEF),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.usedAt,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Student Name
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B8DEF).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF5B8DEF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        transaction.studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Payment Amount
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF5B8DEF).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To\'lov summasi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                transaction.paymentAmount,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF5B8DEF),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'so\'m',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5B8DEF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(ReferralTransaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tranzaksiya tafsilotlari',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('ID', '#${transaction.id}'),
            const SizedBox(height: 16),
            _buildDetailRow('O\'quvchi ID', '#${transaction.student}'),
            const SizedBox(height: 16),
            _buildDetailRow('O\'quvchi nomi', transaction.studentName),
            const SizedBox(height: 16),
            _buildDetailRow('To\'lov summasi', '${transaction.paymentAmount} so\'m'),
            const SizedBox(height: 16),
            _buildDetailRow('Bonus summasi', '${transaction.bonusAmount} so\'m'),
            const SizedBox(height: 16),
            _buildDetailRow('Sana', transaction.usedAt),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8DEF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Yopish',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _showReferralBottomSheet(String locale) {
    showModalBottomSheet(
      context: mainRootNavigatorKey.currentContext!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                size: 48,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              ProfileLocalization.get('inviteFriendsTitle', locale),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.color.primaryColor1.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    ProfileLocalization.get('yourReferralCode', locale),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sl<LocalSource>().getReferralCode() ?? '',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.color.primaryColor1,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _copyReferralCode(innerContext, locale);
                    },
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    label: Text(ProfileLocalization.get('copy', locale)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: context.color.primaryColor1,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                          color: context.color.primaryColor1, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _shareReferralCode(locale);
                    },
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: Text(ProfileLocalization.get('share', locale)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _copyReferralCode(BuildContext context, String locale) {
    Clipboard.setData(ClipboardData(text: referralCode));
    HapticFeedback.mediumImpact();

    Navigator.pop(context);

    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Text(ProfileLocalization.get('referralCodeCopied', locale)),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareReferralCode(String locale) {
    Share.share(
      referralCode,
      subject: ProfileLocalization.get('shareSubject', locale),
    );
  }
}

// Model class for Referral Transaction
class ReferralTransaction {
  final int id;
  final int student;
  final String studentName;
  final String paymentAmount;
  final String bonusAmount;
  final String usedAt;

  ReferralTransaction({
    required this.id,
    required this.student,
    required this.studentName,
    required this.paymentAmount,
    required this.bonusAmount,
    required this.usedAt,
  });

  factory ReferralTransaction.fromJson(Map<String, dynamic> json) {
    return ReferralTransaction(
      id: json['id'] ?? 0,
      student: json['student'] ?? 0,
      studentName: json['student_name'] ?? '',
      paymentAmount: json['payment_amount'] ?? '0.00',
      bonusAmount: json['bonus_amount'] ?? '0.00',
      usedAt: json['used_at'] ?? '',
    );
  }
}