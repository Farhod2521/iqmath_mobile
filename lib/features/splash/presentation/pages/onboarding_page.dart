import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';

import '../../../../router/name_routes.dart' show Routes;
import '../../../auth/presentation/page_args/auth_args.dart';

class OnboardingData {
  final String titleUz;
  final String titleRu;
  final String descriptionUz;
  final String descriptionRu;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.titleUz,
    required this.titleRu,
    required this.descriptionUz,
    required this.descriptionRu,
    required this.icon,
    required this.color,
  });

  String getTitle(String locale) {
    return locale == 'ru' ? titleRu : titleUz;
  }

  String getDescription(String locale) {
    return locale == 'ru' ? descriptionRu : descriptionUz;
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  PageController pageController = PageController();
  int currentIndex = 0;

  final List<OnboardingData> pages = [
    OnboardingData(
      titleUz: "Ta'limni Osonlashtiring",
      titleRu: "Упростите обучение",
      descriptionUz:
          "Zamonaviy texnologiyalar yordamida ta'limni yanada qiziqarli va samarali qiling",
      descriptionRu:
          "Сделайте обучение более интересным и эффективным с помощью современных технологий",
      icon: Icons.school,
      color: const Color(0xFF6C63FF),
    ),
    OnboardingData(
      titleUz: "Har Qadamni Kuzatib Boring",
      titleRu: "Отслеживайте каждый шаг",
      descriptionUz:
          "O'qish jarayoningizning har bir bosqichini nazorat qiling va rivojlanishingizni ko'ring",
      descriptionRu:
          "Контролируйте каждый этап процесса обучения и следите за своим прогрессом",
      icon: Icons.track_changes,
      color: const Color(0xFF50C878),
    ),
    OnboardingData(
      titleUz: "Muvaffaqiyatga Erishing",
      titleRu: "Достигайте успеха",
      descriptionUz:
          "Maqsadlaringizga erishish uchun kerakli barcha vositalar bir joyda jamlangan",
      descriptionRu:
          "Все необходимые инструменты для достижения ваших целей собраны в одном месте",
      icon: Icons.emoji_events,
      color: const Color(0xFFFF6B6B),
    ),
  ];

  String _getSkipText(String locale) {
    return locale == 'ru' ? 'Пропустить' : 'O\'tkazib yuborish';
  }

  String _getBackText(String locale) {
    return locale == 'ru' ? 'Назад' : 'Orqaga';
  }

  String _getNextText(String locale) {
    return locale == 'ru' ? 'Далее' : 'Keyingisi';
  }

  String _getStartText(String locale) {
    return locale == 'ru' ? 'Начать' : 'Boshlash';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final currentLocale = state.appLocale ?? 'uz'; // 'uz' yoki 'ru'

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Skip tugmasi
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (currentIndex < pages.length - 1)
                        InkWell(
                          onTap: () => _goToLastPage(),
                          borderRadius: BorderRadius.circular(8),
                          splashColor: Colors.grey.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(
                              _getSkipText(currentLocale),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPageWidget(
                        data: pages[index],
                        locale: currentLocale,
                      );
                    },
                  ),
                ),

                // Pastki qism - Indikator va tugmalar
                Container(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      // Sahifa indikatori
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: currentIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: currentIndex == index
                                  ? pages[currentIndex].color
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Tugmalar
                      Row(
                        children: [
                          // Orqaga tugmasi
                          if (currentIndex > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _previousPage(),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(
                                      color: pages[currentIndex].color),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _getBackText(currentLocale),
                                  style: TextStyle(
                                    color: pages[currentIndex].color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          if (currentIndex > 0) const SizedBox(width: 16),

                          // Keyingi/Boshlash tugmasi
                          Expanded(
                            flex: currentIndex == 0 ? 1 : 1,
                            child: ElevatedButton(
                              onPressed: () => _nextPage(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pages[currentIndex].color,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currentIndex == pages.length - 1
                                        ? _getStartText(currentLocale)
                                        : _getNextText(currentLocale),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
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
      },
    );
  }

  void _nextPage() {
    if (currentIndex < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Onboarding tugadi
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (currentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToLastPage() {
    pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _finishOnboarding() {
    Navigator.pushNamed(
      context,
      Routes.auth,
      arguments: AuthPageArgs(),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingData data;
  final String locale;

  const OnboardingPageWidget({
    super.key,
    required this.data,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animatsiyali ikon
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 120,
              color: data.color,
            ),
          ),

          const SizedBox(height: 60),

          // Sarlavha
          Text(
            data.getTitle(locale),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 24),

          // Tavsif
          Text(
            data.getDescription(locale),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
