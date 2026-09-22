import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../router/app_routes.dart';
import '../../../../router/name_routes.dart';

class SubjectDetailArguments {
  final String id;
  final String subjectName;

  SubjectDetailArguments({
    required this.id,
    required this.subjectName,
  });
}

// class BookCard extends StatefulWidget {
//   final String subtitle;
//   final String imagePath;
//   final String id;
//
//   const BookCard({
//     super.key,
//     required this.subtitle,
//     required this.imagePath,
//     required this.id,
//   });
//
//   @override
//   State<BookCard> createState() => _BookCardState();
// }
//
// class _BookCardState extends State<BookCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   bool _isPressed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   static const Color iosBlue = CupertinoColors.systemBlue;
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return GestureDetector(
//       onTapDown: (_) {
//         setState(() => _isPressed = true);
//         _animationController.forward();
//       },
//       onTapUp: (_) {
//         setState(() => _isPressed = false);
//         _animationController.reverse();
//         Navigator.pushNamed(
//           mainRootNavigatorKey.currentContext!,
//           Routes.subjectDetail,
//           arguments: SubjectDetailArguments(
//             id: widget.id,
//           ),
//         );
//       },
//       onTapCancel: () {
//         setState(() => _isPressed = false);
//         _animationController.reverse();
//       },
//       child: AnimatedBuilder(
//         animation: _scaleAnimation,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _scaleAnimation.value,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: CupertinoColors.systemBackground,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: CupertinoColors.systemGrey.withOpacity(0.15),
//                     spreadRadius: 0,
//                     blurRadius: 20,
//                     offset: const Offset(0, 8),
//                   ),
//                   BoxShadow(
//                     color: CupertinoColors.systemGrey.withOpacity(0.08),
//                     spreadRadius: 0,
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Kitob rasmi qismi
//                     Expanded(
//                       flex: 8,
//                       child: Stack(
//                         children: [
//                           // Gradient orqa fon
//                           Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   iosBlue.withOpacity(0.1),
//                                   iosBlue.withOpacity(0.05),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           // Kitob rasmi
//                           widget.imagePath.startsWith('http')
//                               ? Image.network(
//                             widget.imagePath,
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             height: double.infinity,
//                             loadingBuilder: (context, child, progress) {
//                               if (progress == null) return child;
//                               return Center(
//                                 child: CupertinoActivityIndicator(
//                                   radius: screenHeight * 0.015,
//                                 ),
//                               );
//                             },
//                             errorBuilder: (context, error, stackTrace) {
//                               return _buildFallbackIcon(screenHeight);
//                             },
//                           )
//                               : _buildFallbackIcon(screenHeight),
//                           // Yumshoq overlay
//                           Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: [
//                                   Colors.transparent,
//                                   Colors.black.withOpacity(0.05),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Tugma qismi
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
//                       child: Container(
//                         width: double.infinity,
//                         height: screenHeight * 0.038,
//                         decoration: BoxDecoration(
//                           color: iosBlue,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Center(
//                           child: Text(
//                             widget.subtitle,
//                             style: TextStyle(
//                               fontSize: screenHeight * 0.014,
//                               fontWeight: FontWeight.w600,
//                               color: CupertinoColors.white,
//                               letterSpacing: -0.2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildFallbackIcon(double screenHeight) {
//     return Center(
//       child: Container(
//         width: screenHeight * 0.1,
//         height: screenHeight * 0.1,
//         decoration: BoxDecoration(
//           color: iosBlue.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(screenHeight * 0.05),
//         ),
//         child: Icon(
//           CupertinoIcons.book_fill,
//           size: screenHeight * 0.045,
//           color: iosBlue,
//         ),
//       ),
//     );
//   }
// }
