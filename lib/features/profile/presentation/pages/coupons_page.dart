import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';

// ==================== LOCALIZATION CLASS ====================
class CouponsLocalization {
  final String locale;

  CouponsLocalization(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'title': 'Kuponlar',
      'noCoupons': 'Kuponlar yo\'q',
      'noCouponsDescription': 'Birinchi kuponingizni yarating va boshqaring',
      'createFirstCoupon': 'Birinchi kuponni yarating',
      'newCoupon': 'Yangi kupon',
      'discount': 'Chegirma:',
      'validFrom': 'Boshlanish sanasi:',
      'validUntil': 'Tugash sanasi:',
      'status': 'Holati:',
      'active': 'Faol',
      'inactive': 'Nofaol',
      'delete': 'O\'chirish',
      'deleteTitle': 'O\'chirish',
      'deleteConfirmation': 'Kuponni o\'chirishni xohlaysizmi?',
      'cancel': 'Bekor qilish',
      'deleting': 'O\'chirilmoqda...',
      'deletedSuccess': 'Kupon muvaffaqiyatli o\'chirildi',
      'creating': 'Kupon yaratilmoqda...',
      'createdSuccess': 'Kupon muvaffaqiyatli yaratildi',
      'copiedSuccess': 'Kupon kodi nusxalandi:',
      'unknownError': 'Noma\'lum xatolik yuz berdi',
      'networkError': 'Internetga ulanishda xatolik:',
    },
    'ru': {
      'title': 'Купоны',
      'noCoupons': 'Нет купонов',
      'noCouponsDescription': 'Создайте и управляйте своим первым купоном',
      'createFirstCoupon': 'Создать первый купон',
      'newCoupon': 'Новый купон',
      'discount': 'Скидка:',
      'validFrom': 'Дата начала:',
      'validUntil': 'Дата окончания:',
      'status': 'Статус:',
      'active': 'Активный',
      'inactive': 'Неактивный',
      'delete': 'Удалить',
      'deleteTitle': 'Удаление',
      'deleteConfirmation': 'Вы хотите удалить купон?',
      'cancel': 'Отмена',
      'deleting': 'Удаление...',
      'deletedSuccess': 'Купон успешно удален',
      'creating': 'Создание купона...',
      'createdSuccess': 'Купон успешно создан',
      'copiedSuccess': 'Код купона скопирован:',
      'unknownError': 'Произошла неизвестная ошибка',
      'networkError': 'Ошибка подключения к интернету:',
    },
  };

  String translate(String key) {
    return _localizedValues[locale]?[key] ?? _localizedValues['uz']![key]!;
  }

  // Getters
  String get title => translate('title');

  String get noCoupons => translate('noCoupons');

  String get noCouponsDescription => translate('noCouponsDescription');

  String get createFirstCoupon => translate('createFirstCoupon');

  String get newCoupon => translate('newCoupon');

  String get discount => translate('discount');

  String get validFrom => translate('validFrom');

  String get validUntil => translate('validUntil');

  String get status => translate('status');

  String get active => translate('active');

  String get inactive => translate('inactive');

  String get delete => translate('delete');

  String get deleteTitle => translate('deleteTitle');

  String get deleteConfirmation => translate('deleteConfirmation');

  String get cancel => translate('cancel');

  String get deleting => translate('deleting');

  String get deletedSuccess => translate('deletedSuccess');

  String get creating => translate('creating');

  String get createdSuccess => translate('createdSuccess');

  String get copiedSuccess => translate('copiedSuccess');

  String get unknownError => translate('unknownError');

  String get networkError => translate('networkError');
}

// ==================== COUPON MODEL ====================
class Coupon {
  final int id;
  final String code;
  final int discountPercent;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;

  Coupon({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      discountPercent: json['discount_percent'],
      validFrom: DateTime.parse(json['valid_from']),
      validUntil: DateTime.parse(json['valid_until']),
      isActive: json['is_active'],
    );
  }
}

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  List<Coupon> coupons = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  CouponsLocalization _getLocalization() {
    final appState = context.read<AppBloc>().state;
    return CouponsLocalization(appState.appLocale ?? 'uz');
  }

  Future<void> _loadCoupons() async {
    var token = sl<LocalSource>().getAccessToken();
    final l10n = _getLocalization();

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/universal/coupon-generate/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        setState(() {
          coupons = [];

          // Response ichida 'coupon' obyekti bo'lsa
          if (responseData is Map && responseData.containsKey('coupon')) {
            final couponData =
                Map<String, dynamic>.from(responseData['coupon'] as Map);
            coupons = [Coupon.fromJson(couponData)];
          }
          // Agar to'g'ridan-to'g'ri list bo'lsa
          else if (responseData is List) {
            coupons = responseData
                .map((json) =>
                    Coupon.fromJson(Map<String, dynamic>.from(json as Map)))
                .toList();
          }
          // Agar bitta obyekt bo'lsa (coupon kalit so'zsiz)
          else if (responseData is Map &&
              !responseData.containsKey('message')) {
            final couponData = Map<String, dynamic>.from(responseData);
            coupons = [Coupon.fromJson(couponData)];
          }

          isLoading = false;
        });

        // Agar message bo'lsa, uni ko'rsatamiz (optional)
        if (responseData is Map &&
            responseData.containsKey('message') &&
            mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(responseData['message'])),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });

        // Error holatida response body'ni parse qilamiz
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['detail'] ?? errorData['message'] ?? l10n.unknownError;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(errorMessage)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (parseError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.unknownError)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${l10n.networkError} ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  void _copyCouponCode(String code) {
    final l10n = _getLocalization();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('${l10n.copiedSuccess} $code'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteCoupon(int id) async {
    var token = sl<LocalSource>().getAccessToken();
    final l10n = _getLocalization();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTitle),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(l10n.deleting),
            ],
          ),
          duration: const Duration(seconds: 30),
          behavior: SnackBarBehavior.floating,
        ),
      );

      try {
        final response = await http.delete(
          Uri.parse('https://api.iqmath.uz/api/v1/universal/coupon-generate/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token',
          },
        );
        alice.onHttpResponse(response);

        ScaffoldMessenger.of(context).clearSnackBars();

        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            coupons.removeWhere((coupon) => coupon.id == id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(l10n.deletedSuccess),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          try {
            final errorData = json.decode(response.body);
            final errorMessage = errorData['detail'] ??
                errorData['message'] ??
                l10n.unknownError;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(errorMessage)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } catch (parseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.unknownError)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${l10n.networkError} ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _createCoupon() async {
    var token = sl<LocalSource>().getAccessToken();
    final l10n = _getLocalization();

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(l10n.creating),
          ],
        ),
        duration: const Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final response = await http.post(
        Uri.parse('https://api.iqmath.uz/api/v1/universal/coupon-generate/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
      alice.onHttpResponse(response);

      ScaffoldMessenger.of(context).clearSnackBars();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadCoupons();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(response.body.contains('message')
                      ? json.decode(response.body)['message']
                      : l10n.createdSuccess),
                  // Text(l10n.createdSuccess),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['detail'] ?? errorData['message'] ?? l10n.unknownError;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(errorMessage)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (parseError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.unknownError)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${l10n.networkError} ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddCouponDialog() {
    _createCoupon();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final l10n = CouponsLocalization(state.appLocale ?? 'uz');

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(l10n.title),
            elevation: 0,
            leading: const SizedBox.shrink(),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : coupons.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
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
                                Icons.add,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              l10n.noCoupons,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noCouponsDescription,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _showAddCouponDialog,
                              icon: const Icon(Icons.add),
                              label: Text(l10n.createFirstCoupon),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCoupons,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: coupons.length,
                        itemBuilder: (context, index) {
                          final coupon = coupons[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Kupon kodi va amallar
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          coupon.code,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      IconButton(
                                        onPressed: () =>
                                            _copyCouponCode(coupon.code),
                                        icon: const Icon(Icons.copy, size: 20),
                                        color: Colors.grey[600],
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () =>
                                            _deleteCoupon(coupon.id),
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Chegirma
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.discount,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${coupon.discountPercent}%',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Boshlanish sanasi
                                  _buildInfoRow(
                                    l10n.validFrom,
                                    formatDate(coupon.validFrom),
                                  ),
                                  const SizedBox(height: 12),

                                  // Tugash sanasi
                                  _buildInfoRow(
                                    l10n.validUntil,
                                    formatDate(coupon.validUntil),
                                  ),
                                  const SizedBox(height: 16),

                                  // Holati
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.status,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: coupon.isActive
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          coupon.isActive
                                              ? l10n.active
                                              : l10n.inactive,
                                          style: TextStyle(
                                            color: coupon.isActive
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          floatingActionButton: coupons.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _showAddCouponDialog,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.newCoupon),
                )
              : null,
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
