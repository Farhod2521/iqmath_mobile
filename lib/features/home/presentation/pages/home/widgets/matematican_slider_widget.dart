import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'dart:async';
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/injector_container.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'package:http/http.dart' as http;

class MathematicianSliderWidget extends StatefulWidget {
  const MathematicianSliderWidget({super.key});

  @override
  State<MathematicianSliderWidget> createState() =>
      _MathematicianSliderWidgetState();
}

class _MathematicianSliderWidgetState extends State<MathematicianSliderWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  final int _startIndex = 10000;

  List<MathematicianModel> _mathematicians = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.88,
      initialPage: _startIndex,
    );
    _pageController.addListener(_onPageChanged);
    _loadMathematicians();
  }

  void _onPageChanged() {
    if (_mathematicians.isEmpty) return;
    int next = _pageController.page!.round() % _mathematicians.length;
    if (_currentPage != next) {
      setState(() {
        _currentPage = next;
      });
    }
  }

  Future<void> _loadMathematicians() async {
    try {
      final mathematicians = await MathematicianService.getAllMathematicians();
      setState(() {
        _mathematicians = mathematicians;
        _isLoading = false;
      });
      _startAutoPlay();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startAutoPlay() {
    if (_mathematicians.isEmpty) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showMathematicianDetail(
      BuildContext context, MathematicianModel mathematician) async {
    HapticFeedback.mediumImpact();

    MathematicianModel fullData = mathematician;
    if (mathematician.descriptionUz == null ||
        mathematician.descriptionUz!.isEmpty) {
      try {
        fullData =
        await MathematicianService.getMathematicianById(mathematician.id);
      } catch (e) {
        // Xatolik bo'lsa, mavjud ma'lumot bilan davom etamiz
      }
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: mainRootNavigatorKey.currentContext!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MathematicianDetailModal(mathematician: fullData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.color.primaryColor1.withOpacity(0.03),
                Colors.white.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.color.primaryColor1.withOpacity(0.08),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.color.primaryColor1,
                            context.color.primaryColor1.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: context.color.primaryColor1.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale == 'ru'
                                ? 'Великие Математики'
                                : 'Buyuk Matematiklar',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            locale == 'ru'
                                ? 'Уроки истории'
                                : 'Tarixdan saboqlar',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7A7A7A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.color.primaryColor1,
                    ),
                  ),
                )
                    : _errorMessage != null
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: context.color.primaryColor1
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          locale == 'ru'
                              ? 'Ошибка загрузки данных'
                              : 'Ma\'lumot yuklashda xatolik',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.color.primaryColor1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _loadMathematicians,
                          icon: const Icon(Icons.refresh_rounded,
                              size: 18),
                          label: Text(locale == 'ru'
                              ? 'Повторить'
                              : 'Qayta urinish'),
                          style: TextButton.styleFrom(
                            foregroundColor:
                            context.color.primaryColor1,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : _mathematicians.isEmpty
                    ? Center(
                  child: Text(
                    locale == 'ru'
                        ? 'Данные не найдены'
                        : 'Ma\'lumot topilmadi',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.color.primaryColor1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    : PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    final mathematician = _mathematicians[
                    index % _mathematicians.length];
                    return _MathematicianCard(
                      mathematician: mathematician,
                      locale: locale ?? 'uz',
                      onTap: () => _showMathematicianDetail(
                          context, mathematician),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (!_isLoading &&
                  _errorMessage == null &&
                  _mathematicians.isNotEmpty)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _mathematicians.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == index ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: _currentPage == index
                              ? LinearGradient(
                            colors: [
                              context.color.primaryColor1,
                              context.color.primaryColor1
                                  .withOpacity(0.6),
                            ],
                          )
                              : null,
                          color: _currentPage != index
                              ? context.color.primaryColor1.withOpacity(0.2)
                              : null,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MathematicianCard extends StatelessWidget {
  final MathematicianModel mathematician;
  final String locale;
  final VoidCallback onTap;

  const _MathematicianCard({
    required this.mathematician,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.color.primaryColor1.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Container(
                    width: 150,
                    height: double.infinity,
                    color: context.color.primaryColor1.withOpacity(0.1),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          mathematician.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color:
                              context.color.primaryColor1.withOpacity(0.1),
                              child: Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: context.color.primaryColor1
                                    .withOpacity(0.3),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color:
                              context.color.primaryColor1.withOpacity(0.1),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      context.color.primaryColor1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mathematician.getTitle(locale),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: context.color.primaryColor1
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  mathematician.getSubtitle(locale),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: context.color.primaryColor1,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                  maxLines: 8,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color:
                              context.color.primaryColor1.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                mathematician.getLifeYears(locale),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.color.primaryColor1
                                      .withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    context.color.primaryColor1,
                                    context.color.primaryColor1
                                        .withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    locale == 'ru' ? 'Подробнее' : 'Batafsil',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MathematicianDetailModal extends StatelessWidget {
  final MathematicianModel mathematician;

  const _MathematicianDetailModal({required this.mathematician});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rasm va asosiy ma'lumot
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 140,
                                  height: 180,
                                  color: context.color.primaryColor1
                                      .withOpacity(0.1),
                                  child: Image.network(
                                    mathematician.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: context.color.primaryColor1
                                            .withOpacity(0.1),
                                        child: Icon(
                                          Icons.person_rounded,
                                          size: 60,
                                          color: context.color.primaryColor1
                                              .withOpacity(0.3),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mathematician.getTitle(locale),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3142),
                                        letterSpacing: -0.5,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.color.primaryColor1
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: context.color.primaryColor1,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            mathematician.getLifeYears(locale),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color:
                                              context.color.primaryColor1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Mutaxassisligi
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.color.primaryColor1.withOpacity(0.08),
                                  context.color.primaryColor1.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.color.primaryColor1.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  color: context.color.primaryColor1,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    mathematician.getSubtitle(locale),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.color.primaryColor1,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Biografiya sarlavhasi
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      context.color.primaryColor1,
                                      context.color.primaryColor1.withOpacity(0.5),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                locale == 'ru' ? 'Биография' : 'Biografiya',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Biografiya matni
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              mathematician.getDescription(locale) ??
                                  (locale == 'ru'
                                      ? 'Информация загружается...'
                                      : 'Ma\'lumot yuklanmoqda...'),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF4A4A4A),
                                height: 1.7,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Yopish tugmasi
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.color.primaryColor1,
                                foregroundColor: Colors.white,
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                locale == 'ru' ? 'Закрыть' : 'Yopish',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class MathematicianModel {
  final int id;
  final String titleUz;
  final String titleRu;
  final String subtitleUz;
  final String subtitleRu;
  final String lifeYearsUz;
  final String lifeYearsRu;
  final String image;
  final String? descriptionUz;
  final String? descriptionRu;
  final String? createdAt;

  MathematicianModel({
    required this.id,
    required this.titleUz,
    required this.titleRu,
    required this.subtitleUz,
    required this.subtitleRu,
    required this.lifeYearsUz,
    required this.lifeYearsRu,
    required this.image,
    this.descriptionUz,
    this.descriptionRu,
    this.createdAt,
  });

  String getTitle(String locale) {
    return locale == 'ru' ? titleRu : titleUz;
  }

  String getSubtitle(String locale) {
    return locale == 'ru' ? subtitleRu : subtitleUz;
  }

  String getLifeYears(String locale) {
    return locale == 'ru' ? lifeYearsRu : lifeYearsUz;
  }

  String? getDescription(String locale) {
    return locale == 'ru' ? descriptionRu : descriptionUz;
  }

  factory MathematicianModel.fromJson(Map<String, dynamic> json) {
    return MathematicianModel(
      id: json['id'] as int,
      titleUz: json['title_uz'] as String,
      titleRu: json['title_ru'] as String,
      subtitleUz: json['subtitle_uz'] as String,
      subtitleRu: json['subtitle_ru'] as String,
      lifeYearsUz: json['life_years_uz'] as String,
      lifeYearsRu: json['life_years_ru'] as String,
      image: json['image'] as String,
      descriptionUz: json['description_uz'] as String?,
      descriptionRu: json['description_ru'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_uz': titleUz,
      'title_ru': titleRu,
      'subtitle_uz': subtitleUz,
      'subtitle_ru': subtitleRu,
      'life_years_uz': lifeYearsUz,
      'life_years_ru': lifeYearsRu,
      'image': image,
      'description_uz': descriptionUz,
      'description_ru': descriptionRu,
      'created_at': createdAt,
    };
  }
}

class MathematicianService {
  static const String baseUrl =
      'https://api.iqmath.uz/api/v1/management/mobile';

  /// Barcha matematiklarni olish
  static Future<List<MathematicianModel>> getAllMathematicians() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mathematicians/'),
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData =
        json.decode(utf8.decode(response.bodyBytes));
        return jsonData
            .map((json) => MathematicianModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Matematiklarni yuklashda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Internet aloqasida xatolik: $e');
    }
  }

  /// Bitta matematikning batafsil ma'lumotini olish
  static Future<MathematicianModel> getMathematicianById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mathematicians/$id/'),
      );
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return MathematicianModel.fromJson(jsonData);
      } else {
        throw Exception(
            'Matematik ma\'lumotini yuklashda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Internet aloqasida xatolik: $e');
    }
  }
}