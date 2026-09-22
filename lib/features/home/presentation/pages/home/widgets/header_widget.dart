import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/features/home/presentation/page_parts/home_localizations.dart';
import 'dart:convert';

import '../../../../../../core/local_source/local_source.dart';
import '../../../../../../injector_container.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _coinController;
  late AnimationController _pulseController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _coinAnimation;
  late Animation<double> _pulseAnimation;

  String studentName = '';
  int userPoints = 0;
  int userCoins = 0;
  int userBalance = 0;
  bool isLoading = true;

  static const int streakDays = 15;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    var token = sl<LocalSource>().getAccessToken();

    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/func_student/my-score/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
      debugPrint('Token ACCESS: $token');
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          studentName = data['student'] ?? '';
          userPoints = data['score'] ?? 0;
          userCoins = data['coin'] ?? 0;
          userBalance = data['sum'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _coinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _rotationController, curve: Curves.linear));

    _coinAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _coinController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _rotationController.repeat();
    _coinController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _coinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatBalance(int balance) {
    String s = balance.toString();
    String result = '';
    int count = 0;

    for (int i = s.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ' $result';
        count = 0;
      }
      result = s[i] + result;
      count++;
    }
    return result;
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    Animation<double>? animation,
    bool pulse = false,
    required Color start,
    required Color end,
  }) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [start, end]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          animation != null
              ? AnimatedBuilder(
                  animation: animation,
                  builder: (_, child) {
                    return Transform.rotate(
                      angle: animation.value,
                      child: child,
                    );
                  },
                  child: _icon(icon),
                )
              : _icon(icon),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        ],
      ),
    );

    return pulse
        ? AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) =>
                Transform.scale(scale: _pulseAnimation.value, child: child),
            child: content,
          )
        : content;
  }

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;

        return Container(
          padding: const EdgeInsets.fromLTRB(14,14,14,18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4FC3F7),
                Color(0xFF29B6F6),
                Color(0xFF1976D2),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (_, child) => Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: child,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              CupertinoIcons.book_fill,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                HomeHeaderLocalizations.t('appTitle', locale),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                HomeHeaderLocalizations.t('appSubtitle', locale),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.95),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: CupertinoIcons.star_fill,
                            value: userPoints.toString(),
                            label: HomeHeaderLocalizations.t('points', locale),
                            pulse: true,
                            start: const Color(0xFFFF6B6B),
                            end: const Color(0xFFEE5A6F),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildStatCard(
                            icon: CupertinoIcons.money_dollar_circle_fill,
                            value: userCoins.toString(),
                            label: HomeHeaderLocalizations.t('coins', locale),
                            animation: _coinAnimation,
                            start: const Color(0xFFFFA726),
                            end: const Color(0xFFFB8C00),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildStatCard(
                            icon: CupertinoIcons.money_dollar,
                            value: _formatBalance(userBalance),
                            label: HomeHeaderLocalizations.t('balance', locale),
                            start: const Color(0xFF26C6DA),
                            end: const Color(0xFF00ACC1),
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 12),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 14, vertical: 10),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withOpacity(0.25),
                    //     borderRadius: BorderRadius.circular(16),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.all(6),
                    //         decoration: BoxDecoration(
                    //           color: const Color(0xFFFF6B35).withOpacity(0.2),
                    //           shape: BoxShape.circle,
                    //         ),
                    //         child: const Icon(
                    //           CupertinoIcons.flame_fill,
                    //           color: Color(0xFFFF6B35),
                    //           size: 18,
                    //         ),
                    //       ),
                    //       const SizedBox(width: 8),
                    //       Text(
                    //         "$streakDays ${HomeHeaderLocalizations.t('streak', locale)}",
                    //         style: const TextStyle(
                    //           fontSize: 13,
                    //           fontWeight: FontWeight.w700,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
        );
      },
    );
  }
}
