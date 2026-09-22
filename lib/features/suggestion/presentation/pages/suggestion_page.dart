import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_template/core/theme/colors/app_colors.dart';
import 'package:my_flutter_template/core/widgets/custom_animated_btn.dart';
import 'package:my_flutter_template/features/profile/presentation/pages/diagnostic_history_page.dart';
import 'package:my_flutter_template/features/suggestion/data/models/subject_model.dart';
import 'package:my_flutter_template/features/suggestion/presentation/widget/suggestion_chapter_widget.dart';
import 'package:my_flutter_template/generated/l10n.dart';
import 'package:my_flutter_template/router/app_routes.dart';
import 'dart:convert';

import '../../../../core/local_source/local_source.dart';
import '../../../../generated/assets.dart';
import '../../../../injector_container.dart';
import '../../../../router/name_routes.dart';
import '../../../subject/presentation/widget/topic_card.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gap(4),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF007AFF),
                    Color(0xFF5856D6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF007AFF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                Assets.svgSuggestion,
                color: context.color.white,
                width: 28,
                height: 28,
              ),
            ),
            SizedBox(width: 12),
            Text(
              localization.diagnostics_history,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.black,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size(
            double.infinity,
            8,
          ),
          child: SizedBox.shrink(),
        ),
        backgroundColor: CupertinoColors.white,
        automaticBackgroundVisibility: false,
      ),
      child: SafeArea(
        bottom: false,
        child: DiagnosticHistoryPage(),
      ),
    );
  }
}

// class SuggestionPage extends StatefulWidget {
//   const SuggestionPage({super.key});
//
//   @override
//   State<SuggestionPage> createState() => _SuggestionPageState();
// }
//
// class _SuggestionPageState extends State<SuggestionPage> {
//   List<SubjectSuggestion> subjects = [];
//   Map<String, List<SubjectSuggestion>> categorizedSubjects = {};
//   bool isLoading = true;
//   String? errorMessage;
//   String selectedFilter = 'Hammasi';
//   final List<String> filters = ['Hammasi', 'Boshlangan', 'Boshlanmagan'];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchSubjects();
//   }
//
//   Future<void> _fetchSubjects() async {
//     var token = sl<LocalSource>().getAccessToken();
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://api.iqmath.uz/api/v1/func_student/my-diagnost-subjects/'),
//         headers: {
//           'Authorization': '$token',
//         },
//       );
//       alice.onHttpResponse(response);
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           subjects =
//               data.map((json) => SubjectSuggestion.fromJson(json)).toList();
//           _categorizeSubjects();
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Ma\'lumotlarni yuklashda xatolik yuz berdi';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Internet bilan bog\'lanishda muammo';
//         isLoading = false;
//       });
//       debugPrint('Error: $e');
//     }
//   }
//
//   void _categorizeSubjects() {
//     categorizedSubjects.clear();
//
//     List<SubjectSuggestion> filteredList;
//     if (selectedFilter == 'Hammasi') {
//       filteredList = subjects;
//     } else if (selectedFilter == 'Boshlangan') {
//       filteredList = subjects.where((s) => s.progressPercent > 0).toList();
//     } else {
//       filteredList = subjects.where((s) => s.progressPercent == 0).toList();
//     }
//
//     // Faqat diagnostic qabul qilgan fanlarni filterlash
//     filteredList = filteredList.where((s) => s.hasTakenDiagnostic).toList();
//
//     for (var subject in filteredList) {
//       if (!categorizedSubjects.containsKey(subject.nameUz)) {
//         categorizedSubjects[subject.nameUz] = [];
//       }
//       categorizedSubjects[subject.nameUz]!.add(subject);
//     }
//   }
//
//   void _applyFilter(String filter) {
//     setState(() {
//       selectedFilter = filter;
//       _categorizeSubjects();
//     });
//   }
//
//   Future<void> _refreshData() async {
//     setState(() {
//       errorMessage = null;
//     });
//     await _fetchSubjects();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       backgroundColor: CupertinoColors.systemGroupedBackground,
//       navigationBar: CupertinoNavigationBar(
//         leading: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Gap(4),
//             Container(
//               padding: EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF007AFF),
//                     Color(0xFF5856D6),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Color(0xFF007AFF).withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: SvgPicture.asset(
//                 Assets.svgSuggestion,
//                 color: context.color.white,
//                 width: 28,
//                 height: 28,
//               ),
//             ),
//             SizedBox(width: 12),
//             Text(
//               'Tavsiya',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w600,
//                 color: CupertinoColors.black,
//                 letterSpacing: 0.3,
//               ),
//             ),
//           ],
//         ),
//         bottom: PreferredSize(
//           preferredSize: Size(
//             double.infinity,
//             8,
//           ),
//           child: SizedBox.shrink(),
//         ),
//         backgroundColor: CupertinoColors.white,
//         automaticBackgroundVisibility: false,
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: isLoading && subjects.isEmpty
//             ? const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CupertinoActivityIndicator(radius: 16),
//                     SizedBox(height: 16),
//                     Text(
//                       'Yuklanmoqda...',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: CupertinoColors.secondaryLabel,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             : errorMessage != null && subjects.isEmpty
//                 ? _buildErrorView()
//                 : CustomScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(
//                       parent: BouncingScrollPhysics(),
//                     ),
//                     slivers: [
//                       CupertinoSliverRefreshControl(
//                         onRefresh: _refreshData,
//                       ),
//
//                       // Filter chips
//                       SliverToBoxAdapter(
//                         child: _buildFilterChips(),
//                       ),
//
//                       // Content
//                       if (categorizedSubjects.isEmpty)
//                         SliverFillRemaining(
//                           child: _buildEmptyView(),
//                         )
//                       else
//                         ...categorizedSubjects.entries.map((entry) {
//                           return SliverToBoxAdapter(
//                             child: CategorySection(
//                               categoryTitle: entry.key,
//                               books: entry.value,
//                               onOpenChapter: _openChapterSelection,
//                             ),
//                           );
//                         }),
//
//                       const SliverGap(100),
//                     ],
//                   ),
//       ),
//     );
//   }
//
//   Widget _buildFilterChips() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: filters.map((filter) {
//           final isSelected = selectedFilter == filter;
//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: GestureDetector(
//               onTap: () {
//                 HapticFeedback.lightImpact();
//                 _applyFilter(filter);
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   gradient: isSelected
//                       ? const LinearGradient(
//                           colors: [
//                             Color(0xFF007AFF),
//                             Color(0xFF0051D5),
//                           ],
//                         )
//                       : null,
//                   color: isSelected ? null : CupertinoColors.systemBackground,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: isSelected
//                         ? Colors.transparent
//                         : CupertinoColors.separator,
//                     width: 1.5,
//                   ),
//                   boxShadow: isSelected
//                       ? [
//                           BoxShadow(
//                             color: const Color(0xFF007AFF).withOpacity(0.4),
//                             blurRadius: 12,
//                             offset: const Offset(0, 4),
//                           ),
//                         ]
//                       : [],
//                 ),
//                 child: Text(
//                   filter,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: isSelected
//                         ? CupertinoColors.white
//                         : CupertinoColors.label,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildErrorView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     const Color(0xFFFF3B30).withOpacity(0.2),
//                     const Color(0xFFFF3B30).withOpacity(0.05),
//                   ],
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 CupertinoIcons.exclamationmark_triangle_fill,
//                 size: 40,
//                 color: Color(0xFFFF3B30),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               errorMessage!,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: CupertinoColors.label,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Iltimos, qaytadan urinib ko\'ring',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: CupertinoColors.secondaryLabel,
//               ),
//             ),
//             const SizedBox(height: 24),
//             CupertinoButton(
//               onPressed: _refreshData,
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//               borderRadius: BorderRadius.circular(12),
//               color: const Color(0xFF007AFF),
//               child: const Text(
//                 'Qaytadan yuklash',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     CupertinoColors.systemGrey.withOpacity(0.2),
//                     CupertinoColors.systemGrey.withOpacity(0.05),
//                   ],
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 CupertinoIcons.book_fill,
//                 size: 50,
//                 color: CupertinoColors.systemGrey,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Darsliklar topilmadi',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: CupertinoColors.label,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               selectedFilter == 'Hammasi'
//                   ? 'Hozircha sizga tayinlangan darsliklar yo\'q'
//                   : 'Bu filtrga mos darsliklar topilmadi',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: CupertinoColors.secondaryLabel,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _openChapterSelection(String id) {
//     var token = sl<LocalSource>().getAccessToken();
//     showChapterBottomSheet(
//       context: context,
//       authToken: token ?? '',
//       onTopicSelected: (int topicId) {},
//       id: id,
//     );
//   }
// }
//
// // Category Section Widget
// class CategorySection extends StatelessWidget {
//   final String categoryTitle;
//   final List<SubjectSuggestion> books;
//   final Function(String) onOpenChapter;
//
//   const CategorySection({
//     super.key,
//     required this.categoryTitle,
//     required this.books,
//     required this.onOpenChapter,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final cardHeight = (screenHeight * 0.36) - 30;
//     final cardWidth = screenWidth * 0.45;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Category header
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//           child: Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Color(0xFF007AFF),
//                       Color(0xFF0051D5),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   categoryTitle,
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                     color: CupertinoColors.label,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       CupertinoIcons.book_fill,
//                       size: 20,
//                       color: const Color(0xFF007AFF),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       '${books.length}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Horizontal books list
//         SizedBox(
//           height: cardHeight + 40,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             itemCount: books.length,
//             itemBuilder: (context, index) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16),
//                 child: SizedBox(
//                   width: cardWidth,
//                   height: cardHeight,
//                   child: SuggestionBookCard(
//                     subject: books[index],
//                     onTap: () {
//                       HapticFeedback.mediumImpact();
//                       onOpenChapter(books[index].id.toString());
//                     },
//                     onTapRefresh: () async {
//                       HapticFeedback.mediumImpact();
//                       await Navigator.pushNamed(
//                         mainRootNavigatorKey.currentContext!,
//                         Routes.questions,
//                         arguments: QuestionPageArguments(
//                           topic: null,
//                           isDiagnostic: true,
//                           taskName: books[index].nameUz,
//                           subjectId: books[index].id.toString(),
//                         ),
//                       ).then(
//                         (value) {
//                           if (value as bool) {
//                             onOpenChapter(books[index].id.toString());
//                           }
//                         },
//                       );
//                     },
//                     onTapBook: () async {
//                       HapticFeedback.mediumImpact();
//                       await Navigator.pushNamed(
//                         mainRootNavigatorKey.currentContext!,
//                         Routes.questions,
//                         arguments: QuestionPageArguments(
//                           topic: null,
//                           isDiagnostic: true,
//                           taskName: books[index].nameUz,
//                           subjectId: books[index].id.toString(),
//                         ),
//                       ).then(
//                         (value) {
//                           if (value as bool) {
//                             onOpenChapter(books[index].id.toString());
//                           }
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class SuggestionBookCard extends StatefulWidget {
//   final SubjectSuggestion subject;
//   final VoidCallback onTap;
//   final VoidCallback onTapRefresh;
//   final VoidCallback onTapBook;
//
//   const SuggestionBookCard({
//     super.key,
//     required this.subject,
//     required this.onTap,
//     required this.onTapRefresh,
//     required this.onTapBook,
//   });
//
//   @override
//   State<SuggestionBookCard> createState() => _SuggestionBookCardState();
// }
//
// class _SuggestionBookCardState extends State<SuggestionBookCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   bool _isRefreshPressed = false;
//   bool _isEyePressed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   List<Color> _getButtonGradient() {
//     return [const Color(0xFF007AFF), const Color(0xFF0051D5)];
//   }
//
//   List<Color> _getProgressGradient(int progress) {
//     if (progress == 0) {
//       return [const Color(0xFF8E8E93), const Color(0xFF636366)];
//     } else if (progress < 30) {
//       return [const Color(0xFFFF6B6B), const Color(0xFFFF3B30)];
//     } else if (progress < 60) {
//       return [const Color(0xFFFFB444), const Color(0xFFFF9500)];
//     } else if (progress < 90) {
//       return [const Color(0xFFFFD60A), const Color(0xFFFFCC00)];
//     } else {
//       return [const Color(0xFF34C759), const Color(0xFF30B350)];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final imageUrl = widget.subject.imageUz.isNotEmpty
//         ? 'https://api.iqmath.uz${widget.subject.imageUz}'
//         : '';
//     final progress = widget.subject.progressPercent.toInt();
//     final progressGradient = _getProgressGradient(progress);
//     final buttonGradient = _getButtonGradient();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // Image card - not tappable
//         Expanded(
//           child: CustomAnimatedButton(
//             onTap: widget.onTap,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: CupertinoColors.systemBackground,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: CupertinoColors.systemGrey.withOpacity(0.15),
//                     blurRadius: 20,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 children: [
//                   // Gradient background
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           buttonGradient[0].withOpacity(0.1),
//                           buttonGradient[0].withOpacity(0.05),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // Book image
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: Stack(
//                       children: [
//                         Positioned.fill(
//                           child: imageUrl.startsWith('http')
//                               ? Image.network(
//                                   imageUrl,
//                                   fit: BoxFit.cover,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   alignment: const Alignment(0, -0.5),
//                                   loadingBuilder:
//                                       (context, child, loadingProgress) {
//                                     if (loadingProgress == null) return child;
//                                     return Center(
//                                       child: CupertinoActivityIndicator(
//                                         radius: screenHeight * 0.015,
//                                       ),
//                                     );
//                                   },
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return _buildFallbackIcon(
//                                         screenHeight, buttonGradient);
//                                   },
//                                 )
//                               : _buildFallbackIcon(
//                                   screenHeight, buttonGradient),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Gradient overlay
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.05),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // Class badge - bottom
//                   Positioned(
//                     left: 12,
//                     right: 12,
//                     bottom: 12,
//                     child: Container(
//                       height: 36,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: buttonGradient,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: buttonGradient[0].withOpacity(0.4),
//                             blurRadius: 12,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.subject.classUz,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: CupertinoColors.white,
//                             letterSpacing: -0.2,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         // Action buttons below card
//         const SizedBox(height: 8),
//
//         // Action buttons row
//         Row(
//           children: [
//             // Refresh button
//             GestureDetector(
//               onTapDown: (_) => setState(() => _isRefreshPressed = true),
//               onTapUp: (_) {
//                 setState(() => _isRefreshPressed = false);
//                 HapticFeedback.lightImpact();
//                 widget.onTapRefresh();
//                 // Refresh action
//               },
//               onTapCancel: () => setState(() => _isRefreshPressed = false),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 150),
//                 height: 32,
//                 width: 32,
//                 decoration: BoxDecoration(
//                   color: _isRefreshPressed
//                       ? CupertinoColors.systemGrey5
//                       : CupertinoColors.systemGrey6,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _isRefreshPressed
//                           ? buttonGradient[0].withOpacity(0.2)
//                           : CupertinoColors.systemGrey.withOpacity(0.1),
//                       blurRadius: _isRefreshPressed ? 8 : 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   CupertinoIcons.refresh_thick,
//                   size: 16,
//                   color: buttonGradient[0],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//
//             // Eye button
//             GestureDetector(
//               onTapDown: (_) => setState(() => _isEyePressed = true),
//               onTapUp: (_) {
//                 setState(() => _isEyePressed = false);
//                 HapticFeedback.lightImpact();
//                 widget.onTap();
//               },
//               onTapCancel: () => setState(() => _isEyePressed = false),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 150),
//                 height: 32,
//                 width: 32,
//                 decoration: BoxDecoration(
//                   color: _isEyePressed
//                       ? CupertinoColors.systemGrey5
//                       : CupertinoColors.systemGrey6,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _isEyePressed
//                           ? buttonGradient[0].withOpacity(0.2)
//                           : CupertinoColors.systemGrey.withOpacity(0.1),
//                       blurRadius: _isEyePressed ? 8 : 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   CupertinoIcons.eye_fill,
//                   size: 16,
//                   color: buttonGradient[0],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//
//             // Progress bar
//             Expanded(
//               child: Container(
//                 height: 6,
//                 decoration: BoxDecoration(
//                   color: CupertinoColors.systemGrey5,
//                   borderRadius: BorderRadius.circular(3),
//                   boxShadow: [
//                     BoxShadow(
//                       color: CupertinoColors.systemGrey.withOpacity(0.05),
//                       blurRadius: 2,
//                       offset: const Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(3),
//                   child: TweenAnimationBuilder<double>(
//                     duration: const Duration(milliseconds: 800),
//                     curve: Curves.easeOutCubic,
//                     tween: Tween<double>(
//                       begin: 0.0,
//                       end: progress / 100,
//                     ),
//                     builder: (context, value, child) {
//                       return FractionallySizedBox(
//                         alignment: Alignment.centerLeft,
//                         widthFactor: value,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: progressGradient,
//                             ),
//                             borderRadius: BorderRadius.circular(3),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: progressGradient[0].withOpacity(0.3),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 1),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//
//             // Progress percentage
//             Text(
//               '$progress%',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: progressGradient[0],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFallbackIcon(double screenHeight, List<Color> colors) {
//     return Center(
//       child: Container(
//         width: screenHeight * 0.1,
//         height: screenHeight * 0.1,
//         decoration: BoxDecoration(
//           color: colors[0].withOpacity(0.15),
//           borderRadius: BorderRadius.circular(screenHeight * 0.05),
//         ),
//         child: Icon(
//           CupertinoIcons.book_fill,
//           size: screenHeight * 0.045,
//           color: colors[0],
//         ),
//       ),
//     );
//   }
// }
