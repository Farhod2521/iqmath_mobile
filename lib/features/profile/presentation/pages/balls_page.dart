import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';

class BallsLocalization {
  static Map<String, Map<String, String>> translations = {
    'uz': {
      'conversion': 'Ball va Tangalar',
      'loading': 'Yuklanmoqda...',
      'error': 'Xatolik yuz berdi',
      'unexpectedError': 'Kutilmagan xatolik',
      'retry': 'Qayta urinish',
      'totalBalls': 'Jami ballaringiz',
      'ball': 'Ball',
      'totalCoins': 'Jami tangalaringiz',
      'coin': 'Tanga',
      'totalSum': 'Jami summalaringiz',
      'sum': 'So\'m',
      'description': 'IQmath platformasida berilgan topshiriqlarni o\'z vaqtida muvaffaqiyatli bajargan foydalanuvchilar uchun bonuslar beriladi. Ushbu ballarni tez orada qimmatbaho sovg\'alarga almashtirishingiz mumkin bo\'ladi',
    },
    'ru': {
      'conversion': 'Балы и Монеты',
      'loading': 'Загрузка...',
      'error': 'Произошла ошибка',
      'unexpectedError': 'Неожиданная ошибка',
      'retry': 'Повторить',
      'totalBalls': 'Всего баллов',
      'ball': 'Балл',
      'totalCoins': 'Всего монет',
      'coin': 'Монета',
      'totalSum': 'Всего сумма',
      'sum': 'Сум',
      'description': 'Пользователи, которые своевременно и успешно выполняют задания на платформе IQmath, получают бонусы. Вы скоро сможете обменять эти баллы на ценные подарки',
    },
  };

  static String get(String key, String locale) {
    return translations[locale]?[key] ?? translations['uz']![key]!;
  }
}

class BallsPage extends StatefulWidget {
  const BallsPage({super.key});

  @override
  State<BallsPage> createState() => _BallsPageState();
}

class _BallsPageState extends State<BallsPage> {
  final Dio _dio = Dio();
  bool _isLoading = true;
  String _errorMessage = '';

  String studentName = '';
  int score = 0;
  int coin = 0;
  int sum = 0;

  @override
  void initState() {
    super.initState();
    _fetchMyScore();
  }

  Future<void> _fetchMyScore() async {
    var token = sl<LocalSource>().getAccessToken();
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final response = await _dio.get(
        'https://api.iqmath.uz/api/v1/func_student/my-score/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          studentName = data['student'] ?? '';
          score = data['score'] ?? 0;
          coin = data['coin'] ?? 0;
          sum = data['sum'] ?? 0;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'error';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'unexpectedError';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale??'uz';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const SizedBox.shrink(),
            title: Text(BallsLocalization.get('conversion', locale)),
          ),
          body: _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          )
              : _errorMessage.isNotEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  BallsLocalization.get(_errorMessage, locale),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: ElevatedButton(
                    onPressed: _fetchMyScore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      BallsLocalization.get('retry', locale),
                    ),
                  ),
                ),
              ],
            ),
          )
              : Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Ball Card
                      Expanded(
                        child: _CurrencyCard(
                          icon: Icons.circle,
                          iconColor: Colors.amber[700]!,
                          title: BallsLocalization.get(
                              'totalBalls', locale),
                          amount:
                          '$score ${BallsLocalization.get('ball', locale)}',
                          backgroundColor: Colors.grey[900]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tanga Card
                      Expanded(
                        child: _CurrencyCard(
                          icon: Icons.circle,
                          iconColor: Colors.grey[600]!,
                          title: BallsLocalization.get(
                              'totalCoins', locale),
                          amount:
                          '$coin ${BallsLocalization.get('coin', locale)}',
                          backgroundColor: Colors.grey[900]!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // So'm Card (Full width)
                  _CurrencyCard(
                    icon: Icons.star,
                    iconColor: Colors.amber[700]!,
                    title:
                    BallsLocalization.get('totalSum', locale),
                    amount:
                    "$sum ${BallsLocalization.get('sum', locale)}",
                    isWide: true,
                    backgroundColor: Colors.grey[900]!,
                  ),

                  const SizedBox(height: 40),

                  // Trophy and Description
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Trophy Icon
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.amber.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 120,
                                color: Colors.amber[700],
                              ),
                              Positioned(
                                top: 45,
                                child: Icon(
                                  Icons.star,
                                  size: 35,
                                  color: Colors.amber[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Description Text
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            BallsLocalization.get(
                                'description', locale),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 15,
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
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
}

class _CurrencyCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String amount;
  final bool isWide;
  final Color backgroundColor;

  const _CurrencyCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.amount,
    this.isWide = false,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),

          // Amount
          Row(
            children: [
              Icon(
                Icons.circle,
                color: Colors.white.withOpacity(0.4),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}