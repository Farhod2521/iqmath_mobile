import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/features/subject/presentation/localization/subject_localization.dart';

import '../../../../core/app_bloc/app_bloc.dart';
import '../../../../core/local_source/local_source.dart';
import '../../../../injector_container.dart';
import '../../data/models/chapter_model.dart';
import '../widget/book_card_widget.dart';
import '../widget/chapter_card.dart';

class SubjectDetailPage extends StatefulWidget {
  final SubjectDetailArguments args;

  const SubjectDetailPage({
    super.key,
    required this.args,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  List<ChapterModel> chapters = [];
  bool isLoading = true;
  String? errorType; // 'error' or 'internet'

  @override
  void initState() {
    super.initState();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    var token = sl<LocalSource>().getAccessToken();
    try {
      setState(() {
        isLoading = true;
        errorType = null;
      });
      final response = await http.get(
        Uri.parse(
            'https://api.iqmath.uz/api/v1/func_student/my-chapter/${widget.args.id}/'),
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json',
        },
      );
      alice.onHttpResponse(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          chapters = data.map((item) => ChapterModel.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorType = 'error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorType = 'internet';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final locale = state.appLocale;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          appBar: AppBar(
            backgroundColor: CupertinoColors.white.withOpacity(0.9),
            elevation: 0,
            centerTitle: true,
            title: Text(
              '${widget.args.subjectName} | ${SubjectDetailTranslations.t('chapters', locale)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.back,
                  size: 28, color: CupertinoColors.systemBlue),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: isLoading
                ? const Center(child: CupertinoActivityIndicator(radius: 20))
                : errorType != null
                ? _buildErrorView(locale)
                : _buildChapterList(),
          ),
        );
      },
    );
  }

  Widget _buildErrorView(String? locale) {
    final errorMessage = errorType == 'error'
        ? SubjectDetailTranslations.t('errorOccurred', locale)
        : SubjectDetailTranslations.t('checkInternet', locale);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                CupertinoIcons.wifi_slash,
                size: 50,
                color: CupertinoColors.systemGrey2,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              SubjectDetailTranslations.t('pleaseRetry', locale),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 32),
            CupertinoButton(
              onPressed: fetchChapters,
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              child: Text(
                SubjectDetailTranslations.t('reload', locale),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterList() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: fetchChapters,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return ChapterCard(
                  chapter: chapters[index],
                  subjectName: widget.args.subjectName,
                );
              },
              childCount: chapters.length,
            ),
          ),
        ),
      ],
    );
  }
}