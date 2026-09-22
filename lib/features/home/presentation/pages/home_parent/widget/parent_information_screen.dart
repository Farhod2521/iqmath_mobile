import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_template/core/app_bloc/app_bloc.dart';
import 'package:my_flutter_template/core/local_source/local_source.dart';
import 'dart:convert';
import 'package:my_flutter_template/router/name_routes.dart';

import '../../../../../../../injector_container.dart';

class ParentInfoLocalization {
  static final Map<String, Map<String, String>> _localizedValues = {
    'active': {
      'uz': 'Faol',
      'ru': 'Активный',
    },
    'inactive': {
      'uz': 'Faol emas',
      'ru': 'Неактивный',
    },
    'bySubjects': {
      'uz': 'Fanlar bo\'yicha',
      'ru': 'По предметам',
    },
    'diagnostics': {
      'uz': 'Diagnostika',
      'ru': 'Диагностика',
    },
    'errorOccurred': {
      'uz': 'Xatolik yuz berdi',
      'ru': 'Произошла ошибка',
    },
    'loadingError': {
      'uz': 'Ma\'lumotlarni yuklashda xatolik',
      'ru': 'Ошибка при загрузке данных',
    },
    'retry': {
      'uz': 'Qayta urinish',
      'ru': 'Попробовать снова',
    },
    'subjectsNotFound': {
      'uz': 'Fanlar topilmadi',
      'ru': 'Предметы не найдены',
    },
    'diagnosticsNotFound': {
      'uz': 'Diagnostika ma\'lumotlari topilmadi',
      'ru': 'Данные диагностики не найдены',
    },
    'id': {
      'uz': 'ID',
      'ru': 'ID',
    },
    'class': {
      'uz': 'sinf',
      'ru': 'класс',
    },
  };

  static String get(String key, String locale) {
    return _localizedValues[key]?[locale] ??
        _localizedValues[key]?['uz'] ??
        key;
  }
}

class ParentInformationScreen extends StatefulWidget {
  final ParentInformationScreenArgs args;

  const ParentInformationScreen({
    super.key,
    required this.args,
  });

  @override
  State<ParentInformationScreen> createState() =>
      _ParentInformationScreenState();
}

class _ParentInformationScreenState extends State<ParentInformationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Compact Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          // Compact Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2196F3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                widget.args.fullName.isNotEmpty
                                    ? widget.args.fullName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.args.fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: widget.args.status
                                            ? const Color(0xFF4CAF50)
                                            : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.args.status
                                          ? ParentInfoLocalization.get(
                                              'active', locale)
                                          : ParentInfoLocalization.get(
                                              'inactive', locale),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${ParentInfoLocalization.get('id', locale)}: ${widget.args.identifier}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Minimal TabBar
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          labelColor: const Color(0xFF1A1A1A),
                          unselectedLabelColor: Colors.grey.shade600,
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(
                                text: ParentInfoLocalization.get(
                                    'bySubjects', locale)),
                            Tab(
                                text: ParentInfoLocalization.get(
                                    'diagnostics', locale)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SubjectsListView(studentId: widget.args.studentId),
                      DiagnosticsListView(studentId: widget.args.studentId),
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
}

// Fanlar bo'yicha tab
class SubjectsListView extends StatefulWidget {
  final String studentId;

  const SubjectsListView({super.key, required this.studentId});

  @override
  State<SubjectsListView> createState() => _SubjectsListViewState();
}

class _SubjectsListViewState extends State<SubjectsListView>
    with AutomaticKeepAliveClientMixin {
  List<ParentSubjectData> subjects = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
          Uri.parse(
              'https://api.iqmath.uz/api/v1/func_student/students/${widget.studentId}/subjects/'),
          headers: {
            'Accept': 'application/json',
            'Authorization': '${sl<LocalSource>().getAccessToken()}',
          });
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          subjects =
              data.map((json) => ParentSubjectData.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
        setState(() {
          errorMessage =
              '${ParentInfoLocalization.get('errorOccurred', locale)}: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
      setState(() {
        errorMessage =
            '${ParentInfoLocalization.get('loadingError', locale)}: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchSubjects,
                  child: Text(ParentInfoLocalization.get('retry', locale)),
                ),
              ],
            ),
          );
        }

        if (subjects.isEmpty) {
          return Center(
            child: Text(
              ParentInfoLocalization.get('subjectsNotFound', locale),
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          );
        }

        return Container(
          color: Colors.grey.shade50,
          child: RefreshIndicator(
            onRefresh: fetchSubjects,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SubjectCard(
                    subject: subjects[index],
                    studentId: widget.studentId,
                    locale: locale,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Diagnostika tab
class DiagnosticsListView extends StatefulWidget {
  final String studentId;

  const DiagnosticsListView({super.key, required this.studentId});

  @override
  State<DiagnosticsListView> createState() => _DiagnosticsListViewState();
}

class _DiagnosticsListViewState extends State<DiagnosticsListView>
    with AutomaticKeepAliveClientMixin {
  List<ParentSubjectData> diagnostics = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchDiagnostics();
  }

  Future<void> fetchDiagnostics() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
          Uri.parse(
              'https://api.iqmath.uz/api/v1/func_student/diagnost/students/${widget.studentId}/subjects/'),
          headers: {
            'Accept': 'application/json',
            'Authorization': '${sl<LocalSource>().getAccessToken()}',
          });
      alice.onHttpResponse(response);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          diagnostics =
              data.map((json) => ParentSubjectData.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
        setState(() {
          errorMessage =
              '${ParentInfoLocalization.get('errorOccurred', locale)}: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      final locale = context.read<AppBloc>().state.appLocale ?? 'uz';
      setState(() {
        errorMessage =
            '${ParentInfoLocalization.get('loadingError', locale)}: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final locale = appState.appLocale ?? 'uz';

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchDiagnostics,
                  child: Text(ParentInfoLocalization.get('retry', locale)),
                ),
              ],
            ),
          );
        }

        if (diagnostics.isEmpty) {
          return Center(
            child: Text(
              ParentInfoLocalization.get('diagnosticsNotFound', locale),
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          );
        }

        return Container(
          color: Colors.grey.shade50,
          child: RefreshIndicator(
            onRefresh: fetchDiagnostics,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: diagnostics.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SubjectCard(
                    subject: diagnostics[index],
                    studentId: widget.studentId,
                    locale: locale,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class SubjectCard extends StatelessWidget {
  final ParentSubjectData subject;
  final String studentId;
  final String locale;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.studentId,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Fan nomi
            Expanded(
              flex: 3,
              child: Text(
                locale == 'ru' ? subject.nameRu : subject.nameUz,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            // Sinf
            SizedBox(
              width: 60,
              child: Text(
                '${subject.className}-${ParentInfoLocalization.get('class', locale)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Gap(12),
            // O'zlashtirish progress
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: subject.masteryPercent / 100,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${subject.masteryPercent}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Ko'z icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.parentAssimilation,
                    arguments: ParentAssimilationScreenArgs(
                      studentId: studentId,
                      subjectId: subject.id.toString(),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParentAssimilationScreenArgs {
  final String studentId;
  final String subjectId;

  ParentAssimilationScreenArgs({
    required this.studentId,
    required this.subjectId,
  });
}

class ParentSubjectData {
  final int id;
  final String nameUz;
  final String nameRu;
  final String className;
  final String classUz;
  final String classRu;
  final String imageUz;
  final String imageRu;
  final double masteryPercent;

  ParentSubjectData({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.className,
    required this.classUz,
    required this.classRu,
    required this.imageUz,
    required this.imageRu,
    required this.masteryPercent,
  });

  factory ParentSubjectData.fromJson(Map<String, dynamic> json) {
    return ParentSubjectData(
      id: json['id'],
      nameUz: json['name_uz'],
      nameRu: json['name_ru'],
      className: json['class_name'],
      classUz: json['class_uz'],
      classRu: json['class_ru'],
      imageUz: json['image_uz'],
      imageRu: json['image_ru'],
      masteryPercent: (json['mastery_percent'] as num).toDouble(),
    );
  }
}

class ParentInformationScreenArgs {
  final String studentId;
  final String fullName;
  final String identifier;
  final bool status;

  ParentInformationScreenArgs({
    required this.studentId,
    required this.fullName,
    required this.identifier,
    required this.status,
  });
}
