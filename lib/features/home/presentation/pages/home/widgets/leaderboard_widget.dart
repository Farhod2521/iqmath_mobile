import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'package:my_flutter_template/features/home/presentation/page_parts/home_localizations.dart';
import '../../../../../../injector_container.dart';

class LeaderboardWidget extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const LeaderboardWidget({
    super.key,
    this.refreshNotifier,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  bool _isLoading = true;
  String? _error;
  String _selectedTab = 'coin';

  Map<String, dynamic>? _leaderboardData;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
    widget.refreshNotifier?.addListener(_onRefresh);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.iqmath.uz/api/v1/func_student/student/rating/app'),
        headers: {
          'Authorization': '${sl<LocalSource>().getAccessToken()}',
          'Content-Type': 'application/json',
        },
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data == null || data.isEmpty) {
          setState(() {
            _leaderboardData = null;
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _leaderboardData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'error';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'internet';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getCurrentLeaderboard() {
    if (_leaderboardData == null) return [];

    final currentData = _leaderboardData![_selectedTab];
    if (currentData == null) return [];

    final List<dynamic> top3 = currentData['top_3'] ?? [];

    return top3.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return {
        'rank': index + 1,
        'name': item['full_name'] ?? '',
        'value': _selectedTab == 'score'
            ? item['score']
            : _selectedTab == 'coin'
            ? item['coin']
            : item['som'],
      };
    }).toList();
  }

  int _getMyRank() {
    if (_leaderboardData == null) return 0;
    final currentData = _leaderboardData![_selectedTab];
    return currentData?['my_rank'] ?? 0;
  }

  int _getMyValue() {
    if (_leaderboardData == null) return 0;
    final currentData = _leaderboardData![_selectedTab];
    return currentData?['my_value'] ?? 0;
  }

  String _getValueLabel(String? locale) {
    switch (_selectedTab) {
      case 'score':
        return locale == 'ru' ? 'балл' : 'ball';
      case 'coin':
        return locale == 'ru' ? 'монеты' : 'tanga';
      case 'som':
        return locale == 'ru' ? 'сум' : 'so\'m';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'ru' ? 'Лидеры' : 'A\'lochilarimiz',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildTabButton(
                  'coin',
                  locale == 'ru' ? 'Монеты' : 'Tanga',
                  locale,
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  'score',
                  locale == 'ru' ? 'Балл' : 'Ball',
                  locale,
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  'som',
                  locale == 'ru' ? 'Сум' : 'So\'m',
                  locale,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        _error == 'error'
                            ? (locale == 'ru'
                            ? 'Ошибка загрузки данных'
                            : 'Ma\'lumot yuklanmadi')
                            : (locale == 'ru'
                            ? 'Нет интернета'
                            : 'Internet yo\'q'),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _fetchLeaderboard,
                        child: Text(
                          locale == 'ru' ? 'Попробовать снова' : 'Qayta urinish',
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_leaderboardData == null || _getCurrentLeaderboard().isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      locale == 'ru' ? 'Данных пока нет' : 'Ma\'lumotlar hali yo\'q',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ..._getCurrentLeaderboard().map((leader) {
                        final rank = leader['rank'] as int;
                        Color rankColor = rank == 1
                            ? const Color(0xFFFFD54F)
                            : rank == 2
                            ? const Color(0xFF90A4AE)
                            : const Color(0xFFFF8A65);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: rankColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    "$rank",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  leader['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ),
                              Text(
                                "${leader['value']} ${_getValueLabel(locale)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      if (_getMyRank() > 0)
                        Column(
                          children: [
                            const Divider(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4FC3F7).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${_getMyRank()}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4FC3F7),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      locale == 'ru' ? 'Вы' : 'Siz',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4FC3F7),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${_getMyValue()} ${_getValueLabel(locale)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF718096),
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
        );
      },
    );
  }

  Widget _buildTabButton(String tab, String label, String? locale) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4FC3F7) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF4FC3F7) : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF718096),
              ),
            ),
          ),
        ),
      ),
    );
  }
}