import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/core/widgets/custom_animated_btn.dart';
import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/parent_information_screen.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:my_flutter_template/router/name_routes.dart';

class ParentCardsLocalization {
  static final Map<String, Map<String, String>> _localizedValues = {
    'active': {
      'uz': 'Faol',
      'ru': 'Активный',
    },
    'inactive': {
      'uz': 'Faol emas',
      'ru': 'Неактивный',
    },
    'class': {
      'uz': 'Sinf',
      'ru': 'Класс',
    },
    'classLabel': {
      'uz': 'sinf',
      'ru': 'класс',
    },
    'subject': {
      'uz': 'Fan (O\'zbek)',
      'ru': 'Предмет (Узбекский)',
    },
    'registrationDate': {
      'uz': 'Ro\'yxatdan o\'tgan sana',
      'ru': 'Дата регистрации',
    },
    'lastLogin': {
      'uz': 'So\'nggi kirish',
      'ru': 'Последний вход',
    },
    'subscriptionEndDate': {
      'uz': 'Obuna tugash sanasi',
      'ru': 'Дата окончания подписки',
    },
    'daysRemaining': {
      'uz': 'kun qoldi',
      'ru': 'дней осталось',
    },
    'lastPayment': {
      'uz': 'So\'nggi to\'lov',
      'ru': 'Последний платеж',
    },
    'som': {
      'uz': 'so\'m',
      'ru': 'сум',
    },
    'loadingError': {
      'uz': 'Ma\'lumotlarni yuklashda xatolik',
      'ru': 'Ошибка при загрузке данных',
    },
    'errorOccurred': {
      'uz': 'Xatolik yuz berdi',
      'ru': 'Произошла ошибка',
    },
    'retry': {
      'uz': 'Qayta urinish',
      'ru': 'Попробовать снова',
    },
    'noStudents': {
      'uz': 'Hozircha o\'quvchilar yo\'q',
      'ru': 'Пока нет учеников',
    },
    'addChild': {
      'uz': 'Farzand qo\'shish',
      'ru': 'Добавить ребенка',
    },
    'id': {
      'uz': 'ID',
      'ru': 'ID',
    },
  };

  static String get(String key, String locale) {
    return _localizedValues[key]?[locale] ?? _localizedValues[key]?['uz'] ?? key;
  }
}

// Parent Model
class Parent {
  final int id;
  final String fullName;
  final String identification;
  final String classNum;
  final String subjectNameUz;
  final bool status;
  final String registrationDate;
  final String registrationTime;
  final String lastLoginTime;
  final double lastPaymentAmount; // int -> double ga o'zgardi
  final String subscriptionEndDate;
  final int remainingDays;

  Parent({
    required this.id,
    required this.fullName,
    required this.identification,
    required this.classNum,
    required this.subjectNameUz,
    required this.status,
    required this.registrationDate,
    required this.registrationTime,
    required this.lastLoginTime,
    required this.lastPaymentAmount,
    required this.subscriptionEndDate,
    required this.remainingDays,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      identification: json['identification'] ?? '',
      classNum: json['class_num'] ?? '',
      subjectNameUz: json['subject_name_uz'] ?? '',
      status: json['status'] ?? false,
      registrationDate: json['registration_date'] ?? '',
      registrationTime: json['registration_time'] ?? '',
      lastLoginTime: json['last_login_time'] ?? '',
      lastPaymentAmount: (json['last_payment_amount'] ?? 0).toDouble(), // To'g'rilandi
      subscriptionEndDate: json['subscription_end_date'] ?? '',
      remainingDays: json['remaining_days'] ?? 0,
    );
  }
}

class ParentCardsWidget extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const ParentCardsWidget({
    super.key,
    this.refreshNotifier,
  });

  @override
  State<ParentCardsWidget> createState() => _ParentCardsWidgetState();
}

class _ParentCardsWidgetState extends State<ParentCardsWidget> {
  List<Parent> students = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchParents();

    // Refresh notifier ga tinglovchi qo'shish
    widget.refreshNotifier?.addListener(_onRefresh);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    fetchParents();
  }

  Future<void> fetchParents() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/auth/parent/confirm-child/list/'),
        headers: {
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
          'Content-Type': 'application/json',
        },
      );

      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          students = jsonData.map((json) => Parent.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
        setState(() {
          errorMessage =
          '${ParentCardsLocalization.get('loadingError', locale)}: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
      setState(() {
        errorMessage = '${ParentCardsLocalization.get('errorOccurred', locale)}: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        if (isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: fetchParents,
                    icon: const Icon(Icons.refresh),
                    label: Text(ParentCardsLocalization.get('retry', locale)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (students.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                ParentCardsLocalization.get('noStudents', locale),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        return Column(
          children:
          students.map((student) => _buildParentCard(student, locale)).toList(),
        );
      },
    );
  }

  Widget _buildParentCard(Parent student, String locale) {
    return CustomAnimatedButton(
      onTap: () {
        Navigator.pushNamed(
          mainRootNavigatorKey.currentContext!,
          Routes.parentInfo,
          arguments: ParentInformationScreenArgs(
            fullName: student.fullName,
            studentId: student.id.toString(),
            identifier: student.identification,
            status: student.status,
          ),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header qismi (Avatar, Ism va Status)
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4285F4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        student.fullName.isNotEmpty
                            ? student.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Ism va ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ParentCardsLocalization.get('id', locale)}: ${student.identification}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: student.status
                          ? const Color(0xFFD4F4DD)
                          : const Color(0xFFFFE4E4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.status
                          ? ParentCardsLocalization.get('active', locale)
                          : ParentCardsLocalization.get('inactive', locale),
                      style: TextStyle(
                        color: student.status
                            ? const Color(0xFF0F9D58)
                            : const Color(0xFFDB4437),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Sinf va Fan
              Text(
                '${ParentCardsLocalization.get('class', locale)}: ${student.classNum} ${ParentCardsLocalization.get('classLabel', locale)}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${ParentCardsLocalization.get('subject', locale)}: ${student.subjectNameUz}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Container(
                height: 1,
                color: Colors.grey[200],
              ),
              const SizedBox(height: 16),
              // Ma'lumotlar
              _buildInfoRow(
                '${ParentCardsLocalization.get('registrationDate', locale)}:',
                '${student.registrationDate} (${student.registrationTime})',
                locale,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                '${ParentCardsLocalization.get('lastLogin', locale)}:',
                student.lastLoginTime,
                locale,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${ParentCardsLocalization.get('subscriptionEndDate', locale)}:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Text(
                    student.subscriptionEndDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${student.remainingDays} ${ParentCardsLocalization.get('daysRemaining', locale)})',
                    style: TextStyle(
                      fontSize: 14,
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
              const SizedBox(height: 8),
              _buildInfoRow(
                '${ParentCardsLocalization.get('lastPayment', locale)}:',
                '${student.lastPaymentAmount.toStringAsFixed(0)} ${ParentCardsLocalization.get('som', locale)}', // To'g'rilandi
                locale,
              ),
            ],
          ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F1F1F),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class AddChildFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddChildFloatingButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: FloatingActionButton.extended(
            onPressed: onPressed,
            backgroundColor: const Color(0xFF4285F4),
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add, size: 24),
            label: Text(
              ParentCardsLocalization.get('addChild', locale),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
// import 'package:my_flutter_template/core/local_source/local_source.dart';
// import 'package:my_flutter_template/core/widgets/custom_animated_btn.dart';
// import 'package:my_flutter_template/features/home/presentation/pages/home_parent/widget/parent_information_screen.dart';
// import 'package:my_flutter_template/injector_container.dart';
// import 'package:my_flutter_template/router/app_routes.dart';
// import 'package:my_flutter_template/router/name_routes.dart';
//
// class ParentCardsLocalization {
//   static final Map<String, Map<String, String>> _localizedValues = {
//     'active': {
//       'uz': 'Faol',
//       'ru': 'Активный',
//     },
//     'inactive': {
//       'uz': 'Faol emas',
//       'ru': 'Неактивный',
//     },
//     'class': {
//       'uz': 'Sinf',
//       'ru': 'Класс',
//     },
//     'classLabel': {
//       'uz': 'sinf',
//       'ru': 'класс',
//     },
//     'subject': {
//       'uz': 'Fan (O\'zbek)',
//       'ru': 'Предмет (Узбекский)',
//     },
//     'registrationDate': {
//       'uz': 'Ro\'yxatdan o\'tgan sana',
//       'ru': 'Дата регистрации',
//     },
//     'lastLogin': {
//       'uz': 'So\'nggi kirish',
//       'ru': 'Последний вход',
//     },
//     'subscriptionEndDate': {
//       'uz': 'Obuna tugash sanasi',
//       'ru': 'Дата окончания подписки',
//     },
//     'daysRemaining': {
//       'uz': 'kun qoldi',
//       'ru': 'дней осталось',
//     },
//     'lastPayment': {
//       'uz': 'So\'nggi to\'lov',
//       'ru': 'Последний платеж',
//     },
//     'som': {
//       'uz': 'so\'m',
//       'ru': 'сум',
//     },
//     'loadingError': {
//       'uz': 'Ma\'lumotlarni yuklashda xatolik',
//       'ru': 'Ошибка при загрузке данных',
//     },
//     'errorOccurred': {
//       'uz': 'Xatolik yuz berdi',
//       'ru': 'Произошла ошибка',
//     },
//     'retry': {
//       'uz': 'Qayta urinish',
//       'ru': 'Попробовать снова',
//     },
//     'noStudents': {
//       'uz': 'Hozircha o\'quvchilar yo\'q',
//       'ru': 'Пока нет учеников',
//     },
//     'addChild': {
//       'uz': 'Farzand qo\'shish',
//       'ru': 'Добавить ребенка',
//     },
//     'id': {
//       'uz': 'ID',
//       'ru': 'ID',
//     },
//     'hideDetails': {
//       'uz': 'Yashirish',
//       'ru': 'Скрыть',
//     },
//     'showDetails': {
//       'uz': 'Batafsil ko\'rish',
//       'ru': 'Подробнее',
//     },
//     'paymentInfo': {
//       'uz': 'To\'lov ma\'lumotlari',
//       'ru': 'Информация о платежах',
//     },
//     'paymentDate': {
//       'uz': 'To\'lov sanasi',
//       'ru': 'Дата платежа',
//     },
//   };
//
//   static String get(String key, String locale) {
//     return _localizedValues[key]?[locale] ?? _localizedValues[key]?['uz'] ?? key;
//   }
// }
//
// // Parent Model
// class Parent {
//   final int id;
//   final String fullName;
//   final String identification;
//   final String classNum;
//   final String subjectNameUz;
//   final bool status;
//   final String registrationDate;
//   final String registrationTime;
//   final String lastLoginTime;
//   final double lastPaymentAmount;
//   final String subscriptionEndDate;
//   final int remainingDays;
//
//   Parent({
//     required this.id,
//     required this.fullName,
//     required this.identification,
//     required this.classNum,
//     required this.subjectNameUz,
//     required this.status,
//     required this.registrationDate,
//     required this.registrationTime,
//     required this.lastLoginTime,
//     required this.lastPaymentAmount,
//     required this.subscriptionEndDate,
//     required this.remainingDays,
//   });
//
//   factory Parent.fromJson(Map<String, dynamic> json) {
//     return Parent(
//       id: json['id'] ?? 0,
//       fullName: json['full_name'] ?? '',
//       identification: json['identification'] ?? '',
//       classNum: json['class_num'] ?? '',
//       subjectNameUz: json['subject_name_uz'] ?? '',
//       status: json['status'] ?? false,
//       registrationDate: json['registration_date'] ?? '',
//       registrationTime: json['registration_time'] ?? '',
//       lastLoginTime: json['last_login_time'] ?? '',
//       lastPaymentAmount: (json['last_payment_amount'] ?? 0).toDouble(),
//       subscriptionEndDate: json['subscription_end_date'] ?? '',
//       remainingDays: json['remaining_days'] ?? 0,
//     );
//   }
// }
//
// class ParentCardsWidget extends StatefulWidget {
//   final ValueNotifier<int>? refreshNotifier;
//
//   const ParentCardsWidget({
//     super.key,
//     this.refreshNotifier,
//   });
//
//   @override
//   State<ParentCardsWidget> createState() => _ParentCardsWidgetState();
// }
//
// class _ParentCardsWidgetState extends State<ParentCardsWidget> {
//   List<Parent> students = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   Set<int> expandedIndices = {};
//
//   @override
//   void initState() {
//     super.initState();
//     fetchParents();
//     widget.refreshNotifier?.addListener(_onRefresh);
//   }
//
//   @override
//   void dispose() {
//     widget.refreshNotifier?.removeListener(_onRefresh);
//     super.dispose();
//   }
//
//   void _onRefresh() {
//     fetchParents();
//   }
//
//   Future<void> fetchParents() async {
//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = '';
//       });
//
//       final response = await http.get(
//         Uri.parse(
//             'https://api.iqmath.uz/api/v1/auth/parent/confirm-child/list/'),
//         headers: {
//           'Authorization': '${sl<LocalSource>().getAccessToken()}',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       alice.onHttpResponse(response);
//
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         setState(() {
//           students = jsonData.map((json) => Parent.fromJson(json)).toList();
//           isLoading = false;
//         });
//       } else {
//         final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
//         setState(() {
//           errorMessage =
//           '${ParentCardsLocalization.get('loadingError', locale)}: ${response.statusCode}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
//       setState(() {
//         errorMessage =
//         '${ParentCardsLocalization.get('errorOccurred', locale)}: $e';
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AppBloc, AppState>(
//       builder: (context, appState) {
//         final locale = appState.appLocale ?? 'uz';
//
//         if (isLoading) {
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(32.0),
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }
//
//         if (errorMessage.isNotEmpty) {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(32.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 64,
//                     color: Colors.grey[400],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     errorMessage,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: fetchParents,
//                     icon: const Icon(Icons.refresh),
//                     label: Text(ParentCardsLocalization.get('retry', locale)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4285F4),
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//
//         if (students.isEmpty) {
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(32.0),
//               child: Text(
//                 ParentCardsLocalization.get('noStudents', locale),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),
//           );
//         }
//
//         return Column(
//           children: students
//               .asMap()
//               .entries
//               .map((entry) => _buildParentCard(
//             entry.value,
//             entry.key,
//             expandedIndices.contains(entry.key),
//             locale,
//           ))
//               .toList(),
//         );
//       },
//     );
//   }
//
//   Widget _buildParentCard(Parent student, int index, bool isExpanded, String locale) {
//     return CustomAnimatedButton(
//       onTap: () {
//         Navigator.pushNamed(
//           mainRootNavigatorKey.currentContext!,
//           Routes.parentInfo,
//           arguments: ParentInformationScreenArgs(
//             fullName: student.fullName,
//             studentId: student.id.toString(),
//             identifier: student.identification,
//             status: student.status,
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header qismi (Avatar, Ism va Status)
//                   Row(
//                     children: [
//                       // Avatar
//                       Container(
//                         width: 56,
//                         height: 56,
//                         decoration: const BoxDecoration(
//                           color: Color(0xFF4285F4),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             student.fullName.isNotEmpty
//                                 ? student.fullName[0].toUpperCase()
//                                 : '?',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       // Ism va ID
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               student.fullName,
//                               style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFF1F1F1F),
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '${ParentCardsLocalization.get('id', locale)}: ${student.identification}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Status badge
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: student.status
//                               ? const Color(0xFFD4F4DD)
//                               : const Color(0xFFFFE4E4),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           student.status
//                               ? ParentCardsLocalization.get('active', locale)
//                               : ParentCardsLocalization.get('inactive', locale),
//                           style: TextStyle(
//                             color: student.status
//                                 ? const Color(0xFF0F9D58)
//                                 : const Color(0xFFDB4437),
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   // Sinf va Fan
//                   Text(
//                     '${ParentCardsLocalization.get('class', locale)}: ${student.classNum} ${ParentCardsLocalization.get('classLabel', locale)}',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       color: Color(0xFF1F1F1F),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '${ParentCardsLocalization.get('subject', locale)}: ${student.subjectNameUz}',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       color: Color(0xFF1F1F1F),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // Divider
//                   Container(
//                     height: 1,
//                     color: Colors.grey[200],
//                   ),
//                   const SizedBox(height: 16),
//                   // Ma'lumotlar
//                   _buildInfoRow(
//                     '${ParentCardsLocalization.get('registrationDate', locale)}:',
//                     '${student.registrationDate} (${student.registrationTime})',
//                     locale,
//                   ),
//                   const SizedBox(height: 8),
//                   _buildInfoRow(
//                     '${ParentCardsLocalization.get('lastLogin', locale)}:',
//                     student.lastLoginTime,
//                     locale,
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           '${ParentCardsLocalization.get('subscriptionEndDate', locale)}:',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                       ),
//                       Text(
//                         student.subscriptionEndDate,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF1F1F1F),
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '(${student.remainingDays} ${ParentCardsLocalization.get('daysRemaining', locale)})',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: student.remainingDays > 100
//                               ? const Color(0xFF0F9D58)
//                               : student.remainingDays > 30
//                               ? Colors.orange
//                               : const Color(0xFFDB4437),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   _buildInfoRow(
//                     '${ParentCardsLocalization.get('lastPayment', locale)}:',
//                     '${student.lastPaymentAmount.toStringAsFixed(0)} ${ParentCardsLocalization.get('som', locale)}',
//                     locale,
//                   ),
//                 ],
//               ),
//             ),
//
//             // Expand button
//             InkWell(
//               onTap: () {
//                 setState(() {
//                   if (isExpanded) {
//                     expandedIndices.remove(index);
//                   } else {
//                     expandedIndices.add(index);
//                   }
//                 });
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     top: BorderSide(color: Colors.grey[200]!),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       isExpanded
//                           ? ParentCardsLocalization.get('hideDetails', locale)
//                           : ParentCardsLocalization.get('showDetails', locale),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF4285F4),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(
//                       isExpanded
//                           ? Icons.keyboard_arrow_up
//                           : Icons.keyboard_arrow_down,
//                       color: const Color(0xFF4285F4),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Expanded content
//             if (isExpanded)
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(16),
//                     bottomRight: Radius.circular(16),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       ParentCardsLocalization.get('paymentInfo', locale),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 ParentCardsLocalization.get('lastPayment', locale),
//                                 style: TextStyle(color: Colors.grey[600]),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "${student.lastPaymentAmount.toStringAsFixed(0)} ${ParentCardsLocalization.get('som', locale)}",
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 ParentCardsLocalization.get('paymentDate', locale),
//                                 style: TextStyle(color: Colors.grey[600]),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 student.lastPaymentAmount == 0
//                                     ? "—"
//                                     : student.registrationDate,
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value, String locale) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[700],
//             ),
//           ),
//         ),
//         Flexible(
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Color(0xFF1F1F1F),
//             ),
//             textAlign: TextAlign.right,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class AddChildFloatingButton extends StatelessWidget {
//   final VoidCallback? onPressed;
//
//   const AddChildFloatingButton({
//     super.key,
//     this.onPressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AppBloc, AppState>(
//       builder: (context, appState) {
//         final locale = appState.appLocale ?? 'uz';
//         return Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 16,
//           ),
//           child: FloatingActionButton.extended(
//             onPressed: onPressed,
//             backgroundColor: const Color(0xFF4285F4),
//             foregroundColor: Colors.white,
//             elevation: 4,
//             icon: const Icon(Icons.add, size: 24),
//             label: Text(
//               ParentCardsLocalization.get('addChild', locale),
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }