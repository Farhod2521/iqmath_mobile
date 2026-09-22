import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:my_flutter_template/router/name_routes.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/parent_information_screen.dart';

class ParentSubjectLocalization {
  static final Map<String, Map<String, String>> _localizedValues = {
    'subjectResults': {
      'uz': 'Fan natijalari',
      'ru': 'Результаты по предметам',
    },
    'active': {
      'uz': 'Faol',
      'ru': 'Активный',
    },
    'inactive': {
      'uz': 'Faol emas',
      'ru': 'Неактивный',
    },
    'classSubject': {
      'uz': 'Sinf / Fan',
      'ru': 'Класс / Предмет',
    },
    'registered': {
      'uz': 'Ro\'yxatdan o\'tgan',
      'ru': 'Зарегистрирован',
    },
    'lastLogin': {
      'uz': 'So\'nggi kirish',
      'ru': 'Последний вход',
    },
    'subscription': {
      'uz': 'Obuna',
      'ru': 'Подписка',
    },
    'daysRemaining': {
      'uz': 'kun qoldi',
      'ru': 'дней осталось',
    },
    'hideDetails': {
      'uz': 'Yashirish',
      'ru': 'Скрыть',
    },
    'showDetails': {
      'uz': 'Batafsil ko\'rish',
      'ru': 'Подробнее',
    },
    'paymentInfo': {
      'uz': 'To\'lov ma\'lumotlari',
      'ru': 'Информация о платежах',
    },
    'lastPayment': {
      'uz': 'So\'nggi to\'lov',
      'ru': 'Последний платеж',
    },
    'paymentDate': {
      'uz': 'To\'lov sanasi',
      'ru': 'Дата платежа',
    },
    'som': {
      'uz': 'so\'m',
      'ru': 'сум',
    },
  };

  static String get(String key, String locale) {
    return _localizedValues[key]?[locale] ??
        _localizedValues[key]?['uz'] ??
        key;
  }
}

class ParentSubjectPage extends StatefulWidget {
  const ParentSubjectPage({super.key});

  @override
  State<ParentSubjectPage> createState() => _ParentSubjectPageState();
}

class _ParentSubjectPageState extends State<ParentSubjectPage> {
  List<ParentResults> students = [];
  bool isLoading = true;
  Set<int> expandedIndices = {};

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    const url = "https://api.iqmath.uz/api/v1/auth/parent/confirm-child/list/";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        students = data.map((e) => ParentResults.fromJson(e)).toList();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching students: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title:
            Text(ParentSubjectLocalization.get('subjectResults', locale)),
          ),
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final student = students[index];
                      final isExpanded = expandedIndices.contains(index);
                      return _buildParentCard(
                          student, index, isExpanded, locale);
                    },
                    childCount: students.length,
                  ),
                ),
              ),
              const SliverGap(80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParentCard(
      ParentResults student,
      int index,
      bool isExpanded,
      String locale,
      ) {
    return GestureDetector(
      onTap: () {
        // Kartaga bosilganda ParentInformationScreen ga o'tish
        Navigator.pushNamed(
          context,
          Routes.parentStudentsDiagnostics,
          arguments: student.id.toString(),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      // Avatar (initial)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4285F4),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name + ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              student.identification,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: student.status
                              ? const Color(0xFFD4F4DD)
                              : const Color(0xFFFFE4E4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          student.status
                              ? ParentSubjectLocalization.get('active', locale)
                              : ParentSubjectLocalization.get('inactive', locale),
                          style: TextStyle(
                            color: student.status
                                ? const Color(0xFF0F9D58)
                                : const Color(0xFFDB4437),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info rows
                  _buildInfoRow(
                    "${ParentSubjectLocalization.get('classSubject', locale)}:",
                    "${student.classNum} / ${student.subjectName}",
                    locale,
                  ),
                  const SizedBox(height: 8),

                  _buildInfoRow(
                    "${ParentSubjectLocalization.get('registered', locale)}:",
                    "${student.registeredDate} ${student.registeredTime}",
                    locale,
                  ),
                  const SizedBox(height: 8),

                  _buildInfoRow(
                    "${ParentSubjectLocalization.get('lastLogin', locale)}:",
                    student.lastEntry,
                    locale,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${ParentSubjectLocalization.get('subscription', locale)}:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Flexible(
                        child: RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1F1F1F),
                            ),
                            children: [
                              TextSpan(text: student.subscriptionEndDate),
                              TextSpan(
                                text:
                                " (${student.remainingDays} ${ParentSubjectLocalization.get('daysRemaining', locale)})",
                                style: TextStyle(
                                  color: student.remainingDays > 100
                                      ? const Color(0xFF0F9D58)
                                      : student.remainingDays > 30
                                      ? Colors.orange
                                      : const Color(0xFFDB4437),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            // Expand button - GestureDetector bilan alohida
            GestureDetector(
              onTap: () {
                // Faqat expand/collapse tugmasiga bosilganda ishlaydi
                setState(() {
                  if (isExpanded) {
                    expandedIndices.remove(index);
                  } else {
                    expandedIndices.add(index);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isExpanded
                          ? ParentSubjectLocalization.get('hideDetails', locale)
                          : ParentSubjectLocalization.get('showDetails', locale),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF4285F4),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (isExpanded)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ParentSubjectLocalization.get('paymentInfo', locale),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ParentSubjectLocalization.get(
                                    'lastPayment', locale),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${student.lastPaymentAmount.toStringAsFixed(0)} ${ParentSubjectLocalization.get('som', locale)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ParentSubjectLocalization.get(
                                    'paymentDate', locale),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                student.lastPaymentAmount == 0
                                    ? "—"
                                    : student.registeredDate,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String locale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class ParentResults {
  final int id;
  final String name;
  final String identification;
  final String classNum;
  final String subjectName;
  final bool status;
  final String registeredDate;
  final String registeredTime;
  final String lastEntry;
  final double lastPaymentAmount;
  final String subscriptionEndDate;
  final int remainingDays;

  ParentResults({
    required this.id,
    required this.name,
    required this.identification,
    required this.classNum,
    required this.subjectName,
    required this.status,
    required this.registeredDate,
    required this.registeredTime,
    required this.lastEntry,
    required this.lastPaymentAmount,
    required this.subscriptionEndDate,
    required this.remainingDays,
  });

  factory ParentResults.fromJson(Map<String, dynamic> json) {
    return ParentResults(
      id: json['id'],
      name: json['full_name'] ?? '',
      identification: json['identification'] ?? '',
      classNum: json['class_num'] ?? '',
      subjectName: json['subject_name_uz'] ?? '',
      status: json['status'] ?? false,
      registeredDate: json['registration_date'] ?? '',
      registeredTime: json['registration_time'] ?? '',
      lastEntry: json['last_login_time'] ?? '',
      lastPaymentAmount: (json['last_payment_amount'] ?? 0).toDouble(),
      subscriptionEndDate: json['subscription_end_date'] ?? '',
      remainingDays: json['remaining_days'] ?? 0,
    );
  }
}